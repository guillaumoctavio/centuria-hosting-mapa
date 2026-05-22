-- ============================================================
-- CENTURIA — Supabase schema
-- Ejecutar en: Dashboard → SQL Editor → New Query
-- ============================================================

-- Tabla principal de mapas
create table public.maps (
  id          uuid primary key default gen_random_uuid(),
  slug        text unique not null,
  title       text not null,
  description text not null default '',
  geojson_url text not null,
  config      jsonb not null default '{}',
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

-- Auto-actualizar updated_at en cada UPDATE
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger maps_updated_at
  before update on public.maps
  for each row execute function public.set_updated_at();

-- Row Level Security
alter table public.maps enable row level security;

-- Lectura pública (viewer no requiere login)
create policy "Public can read maps"
  on public.maps for select
  using (true);

-- Solo usuarios autenticados pueden escribir
create policy "Auth users can insert"
  on public.maps for insert
  with check (auth.role() = 'authenticated');

create policy "Auth users can update"
  on public.maps for update
  using (auth.role() = 'authenticated');

create policy "Auth users can delete"
  on public.maps for delete
  using (auth.role() = 'authenticated');


-- ============================================================
-- STORAGE — ejecutar por separado o hacer en el Dashboard
-- ============================================================
-- 1. Ir a Storage → New Bucket
-- 2. Nombre: geodata
-- 3. Public bucket: ✓ (ON)
-- 4. Agregar políticas en Storage → geodata → Policies:
--
--    INSERT (upload):
--      Allowed for: Authenticated users
--      Policy: (auth.role() = 'authenticated')
--
--    SELECT (download):
--      Allowed for: Everyone
--      Policy: true
--
-- O ejecutar (puede no funcionar en todos los proyectos):

insert into storage.buckets (id, name, public)
values ('geodata', 'geodata', true)
on conflict do nothing;

create policy "Public read geodata"
  on storage.objects for select
  using (bucket_id = 'geodata');

create policy "Auth upload geodata"
  on storage.objects for insert
  with check (bucket_id = 'geodata' and auth.role() = 'authenticated');

create policy "Auth delete geodata"
  on storage.objects for delete
  using (bucket_id = 'geodata' and auth.role() = 'authenticated');


-- ============================================================
-- USUARIO EDITOR — crear en Dashboard → Authentication → Users
-- ============================================================
-- Click "Invite user" o "Add user" y crear con email + password.
-- No hay signup público — solo los usuarios que vos crees pueden entrar al editor.
