-- Invitation codes: alphabet, length, and the rate limit on failed attempts.
begin;

do $$
declare
  code text;
  u uuid := gen_random_uuid();
  refused boolean := false;
begin
  -- generator
  for i in 1..200 loop
    code := public.generate_invite_code();
    assert length(code) = 10, 'default length is 10';
    assert code ~ '^[ABCDEFGHJKLMNPQRSTUVWXYZ23456789]+$', 'only unambiguous characters';
  end loop;
  assert length(public.generate_invite_code(8)) = 8, 'custom length';
  begin
    perform public.generate_invite_code(17);
  exception when others then
    refused := true;
  end;
  assert refused, 'a length above 16 is refused';
  assert (select count(distinct public.generate_invite_code()) from generate_series(1, 50)) = 50, 'codes are random';

  -- rate limit
  insert into auth.users (id, email) values (u, 'invite-test@example.invalid');
  for i in 1..3 loop
    perform public.record_failed_invite_attempt(u);
  end loop;
  perform public.assert_invite_attempts_allowed(u, 4);  -- 3 failures, limit 4: still allowed
  perform public.record_failed_invite_attempt(u);
  refused := false;
  begin
    perform public.assert_invite_attempts_allowed(u, 4);
  exception when sqlstate 'P0001' then
    refused := true;
  end;
  assert refused, 'the 4th failure blocks further attempts';

  -- attempts older than the window no longer count
  update public.invite_attempt set at = now() - interval '2 hours' where user_id = u;
  perform public.assert_invite_attempts_allowed(u, 4);

  -- clients cannot call the helpers
  assert not has_function_privilege('authenticated', 'public.generate_invite_code(integer)', 'execute'),
    'clients cannot generate codes';
  assert not has_table_privilege('authenticated', 'public.invite_attempt', 'select'),
    'clients cannot read attempts';

  raise notice 'RESULT OK';
end $$;

rollback;
