-- Property Inspection Tracker — Supabase schema
-- Run this once in your Supabase project's SQL Editor (Database > SQL Editor > New query).
-- Safe to re-run: it drops and recreates these specific objects only.

-- ─────────────────────────────────────────────
-- Inspectors (per-account list of inspector names)
-- ─────────────────────────────────────────────
create table if not exists inspectors (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now()
);

alter table inspectors enable row level security;

create policy "Users manage their own inspectors"
  on inspectors for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─────────────────────────────────────────────
-- Inspections (top-level report)
-- ─────────────────────────────────────────────
create table if not exists inspections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  address text default '',
  inspection_date date,
  inspector_id uuid references inspectors(id) on delete set null,
  type text default '',
  status text not null default 'draft' check (status in ('draft','completed')),
  completed_at timestamptz,
  tenant_signature text,
  tenant_signed_date date,
  landlord_signature text,
  landlord_signed_date date,
  drive_file_id text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table inspections enable row level security;

create policy "Users manage their own inspections"
  on inspections for all
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

-- ─────────────────────────────────────────────
-- Areas (rooms within an inspection)
-- ─────────────────────────────────────────────
create table if not exists areas (
  id uuid primary key default gen_random_uuid(),
  inspection_id uuid not null references inspections(id) on delete cascade,
  name text not null,
  sort_order int not null default 0
);

alter table areas enable row level security;

create policy "Users manage areas on their own inspections"
  on areas for all
  using (exists (select 1 from inspections i where i.id = inspection_id and i.user_id = auth.uid()))
  with check (exists (select 1 from inspections i where i.id = inspection_id and i.user_id = auth.uid()));

-- ─────────────────────────────────────────────
-- Items (checklist rows within an area)
-- ─────────────────────────────────────────────
create table if not exists items (
  id uuid primary key default gen_random_uuid(),
  area_id uuid not null references areas(id) on delete cascade,
  name text not null,
  condition text default '',
  notes text default '',
  sort_order int not null default 0
);

alter table items enable row level security;

create policy "Users manage items on their own inspections"
  on items for all
  using (exists (
    select 1 from areas a join inspections i on i.id = a.inspection_id
    where a.id = area_id and i.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from areas a join inspections i on i.id = a.inspection_id
    where a.id = area_id and i.user_id = auth.uid()
  ));

-- ─────────────────────────────────────────────
-- Item photos (metadata; actual files live in Supabase Storage)
-- ─────────────────────────────────────────────
create table if not exists item_photos (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references items(id) on delete cascade,
  storage_path text not null,
  created_at timestamptz not null default now()
);

alter table item_photos enable row level security;

create policy "Users manage photos on their own inspections"
  on item_photos for all
  using (exists (
    select 1 from items it join areas a on a.id = it.area_id join inspections i on i.id = a.inspection_id
    where it.id = item_id and i.user_id = auth.uid()
  ))
  with check (exists (
    select 1 from items it join areas a on a.id = it.area_id join inspections i on i.id = a.inspection_id
    where it.id = item_id and i.user_id = auth.uid()
  ));

-- ─────────────────────────────────────────────
-- Keep updated_at current on inspections
-- ─────────────────────────────────────────────
create or replace function set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists inspections_set_updated_at on inspections;
create trigger inspections_set_updated_at
  before update on inspections
  for each row execute function set_updated_at();

-- ─────────────────────────────────────────────
-- Storage bucket for photos (private; accessed via signed URLs / RLS)
-- ─────────────────────────────────────────────
insert into storage.buckets (id, name, public)
values ('inspection-photos', 'inspection-photos', false)
on conflict (id) do nothing;

create policy "Users manage their own photo files"
  on storage.objects for all
  using (bucket_id = 'inspection-photos' and auth.uid()::text = (storage.foldername(name))[1])
  with check (bucket_id = 'inspection-photos' and auth.uid()::text = (storage.foldername(name))[1]);
