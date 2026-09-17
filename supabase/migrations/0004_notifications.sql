-- ============================================================================
-- Cuidar+ | Notificações in-app (ADITIVO — não altera tabelas existentes)
-- Aplicar manualmente via SQL Editor do Supabase.
-- ============================================================================

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references public.profiles (id) on delete cascade,
  patient_id uuid references public.patients (id) on delete set null,
  type text not null,
  title text not null,
  body text,
  related_table text,
  related_id uuid,
  is_read boolean not null default false,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index if not exists notifications_profile_unread_idx
  on public.notifications (profile_id, is_read, created_at desc);

alter table public.notifications enable row level security;

-- Reaproveita a mesma noção de "staff" usada no restante do sistema
-- (roles que não são o responsável/tutor do paciente).
create or replace function public.is_staff_role()
returns boolean as $$
  select exists (
    select 1 from public.profiles
    where id = auth.uid()
      and role in ('recepcao', 'profissional', 'coordenacao', 'gestao', 'admin')
  );
$$ language sql stable security definer set search_path = public;

create policy "notifications_select_own_or_staff"
  on public.notifications for select
  using (profile_id = auth.uid() or public.is_staff_role());

create policy "notifications_update_own_mark_read"
  on public.notifications for update
  using (profile_id = auth.uid())
  with check (profile_id = auth.uid());

create policy "notifications_insert_staff_only"
  on public.notifications for insert
  with check (public.is_staff_role());

create policy "notifications_delete_staff_only"
  on public.notifications for delete
  using (public.is_staff_role());
