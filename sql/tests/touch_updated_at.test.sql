-- touch_updated_at: the server decides updated_at, whatever the client sends.
begin;

create table public.thing (id int primary key, updated_at timestamptz not null default 'epoch');
create trigger thing_touch before insert or update on public.thing
  for each row execute function public.touch_updated_at();

do $$
declare first_value timestamptz; second_value timestamptz;
begin
  insert into public.thing (id, updated_at) values (1, '2000-01-01');
  select updated_at into first_value from public.thing where id = 1;
  assert first_value > now() - interval '1 minute', 'insert ignores the value sent by the client';

  update public.thing set updated_at = '2000-01-01' where id = 1;
  select updated_at into second_value from public.thing where id = 1;
  assert second_value >= first_value, 'update moves updated_at forward, never back';
  assert second_value > now() - interval '1 minute', 'update ignores the value sent by the client';

  raise notice 'RESULT OK';
end $$;

rollback;
