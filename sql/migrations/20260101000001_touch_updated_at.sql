-- Keeps `updated_at` truthful: set by the SERVER on every insert / update, whatever the client sent.
--
-- Why clock_timestamp() and not now(): now() is the start of the transaction, so two writes of the same
-- transaction would share one value and a "changed since" sync cursor could skip one of them.
-- Usage (copy into the app's own migration):
--   create trigger <table>_touch before insert or update on public.<table>
--     for each row execute function public.touch_updated_at();
create or replace function public.touch_updated_at() returns trigger
language plpgsql set search_path = ''
as $$
begin
  new.updated_at := clock_timestamp();
  return new;
end;
$$;
