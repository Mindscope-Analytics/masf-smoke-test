-- Smoke test de risk-gate: tabla mínima con RLS y grants explícitos.
create table if not exists public.notes (
  id          uuid primary key default gen_random_uuid(),
  owner_id    uuid not null default auth.uid() references auth.users(id) on delete cascade,
  body        text not null,
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);
revoke all on table public.notes from anon, authenticated;
grant select, insert, update, delete on table public.notes to authenticated;
grant all on table public.notes to service_role;
alter table public.notes enable row level security;
create policy "notes: own rows" on public.notes for all to authenticated
  using ((select auth.uid()) = owner_id) with check ((select auth.uid()) = owner_id);
drop trigger if exists trg_notes_updated_at on public.notes;
create trigger trg_notes_updated_at before update on public.notes
  for each row execute function public.set_updated_at();
