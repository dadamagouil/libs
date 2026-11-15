-- Invitation codes: a readable random generator and a rate limit on failed attempts.

-- Random code without look-alike characters (no 0/O/1/I), `p_length` characters (1 to 16, default 10 = 50 bits).
--
-- Why uuid bytes: gen_random_uuid() is built in, whereas gen_random_bytes() needs pgcrypto, which lives in the
-- `extensions` schema on Supabase and is not visible from a function whose search_path is empty.
-- 256 is a multiple of 32, so `byte % 32` has no modulo bias.
-- Not callable by clients: only server functions (security definer) use it.
create or replace function public.generate_invite_code(p_length integer default 10) returns text
language plpgsql volatile set search_path = ''
as $$
declare
  alphabet constant text := 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
  bytes bytea := uuid_send(gen_random_uuid());
  result text := '';
begin
  if p_length not between 1 and 16 then
    raise exception 'invite code length must be between 1 and 16';
  end if;
  for i in 0..p_length - 1 loop
    result := result || substr(alphabet, (get_byte(bytes, i) % 32) + 1, 1);
  end loop;
  return result;
end;
$$;
revoke all on function public.generate_invite_code(integer) from public, anon, authenticated;

-- Failed code attempts, to slow down guessing. No policy and no grant: server functions only.
create table if not exists public.invite_attempt (
  id      bigint generated always as identity primary key,
  user_id uuid not null references auth.users (id) on delete cascade,
  at      timestamptz not null default now()
);
create index if not exists invite_attempt_user_idx on public.invite_attempt (user_id, at);
alter table public.invite_attempt enable row level security;
revoke all on public.invite_attempt from anon, authenticated;

-- To call from the "join" function BEFORE looking the code up. Raises `too_many_attempts` (P0001) once the user
-- failed `p_max` times within `p_window`. Also forgets attempts older than one day.
create or replace function public.assert_invite_attempts_allowed(
  p_user uuid,
  p_max integer default 10,
  p_window interval default interval '1 hour'
) returns void
language plpgsql security definer set search_path = ''
as $$
begin
  delete from public.invite_attempt where at < now() - interval '1 day';
  if (select count(*) from public.invite_attempt where user_id = p_user and at > now() - p_window) >= p_max then
    raise exception 'too_many_attempts' using errcode = 'P0001';
  end if;
end;
$$;
revoke all on function public.assert_invite_attempts_allowed(uuid, integer, interval) from public, anon, authenticated;

-- To call from the "join" function when the code was invalid, expired or already used.
create or replace function public.record_failed_invite_attempt(p_user uuid) returns void
language sql security definer set search_path = ''
as $$
  insert into public.invite_attempt (user_id) values (p_user);
$$;
revoke all on function public.record_failed_invite_attempt(uuid) from public, anon, authenticated;
