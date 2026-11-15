-- forbid_column_change: a protected column cannot be changed, other columns can.
begin;

create table public.item (id int primary key, group_id int not null, label text);
create trigger item_group_immutable before update on public.item
  for each row execute function public.forbid_column_change('group_id');

do $$
declare refused boolean := false;
begin
  insert into public.item values (1, 10, 'a');

  update public.item set label = 'b' where id = 1;
  assert (select label from public.item where id = 1) = 'b', 'other columns stay editable';

  update public.item set group_id = 10 where id = 1;  -- same value: allowed

  begin
    update public.item set group_id = 11 where id = 1;
  exception when insufficient_privilege then
    refused := true;
  end;
  assert refused, 'changing the protected column is refused with 42501';
  assert (select group_id from public.item where id = 1) = 10, 'the value did not change';

  raise notice 'RESULT OK';
end $$;

rollback;
