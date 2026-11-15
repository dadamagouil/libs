-- Makes a column immutable after insert: the update is refused with "insufficient privilege" (42501).
--
-- Why: ownership columns (group_id, owner_id...) must never move a row to another group; RLS alone does not
-- stop an owner of both groups from re-parenting a row.
-- Usage: the column name is the trigger argument.
--   create trigger <table>_group_immutable before update on public.<table>
--     for each row execute function public.forbid_column_change('group_id');
create or replace function public.forbid_column_change() returns trigger
language plpgsql set search_path = ''
as $$
declare
  col text := tg_argv[0];
begin
  if to_jsonb(new) -> col is distinct from to_jsonb(old) -> col then
    raise exception '% is immutable', col using errcode = '42501';
  end if;
  return new;
end;
$$;
