-- ============================================================================
-- Cuidar+ | Mural de notícias / blog (ADITIVO — não altera tabelas existentes)
-- Conteúdo institucional público, no espírito do perfil da prefeitura no
-- Instagram: campanhas, avisos, eventos. Aplicar manualmente via SQL Editor.
-- ============================================================================

create table if not exists public.posts (
  id uuid primary key default gen_random_uuid(),
  title text not null,
  subtitle text,
  cover_image_url text,
  body text not null,
  category text not null default 'aviso'
    check (category in ('aviso', 'campanha', 'evento', 'servico')),
  service_id uuid references public.services (id) on delete set null,
  author_id uuid references public.profiles (id) on delete set null,
  status text not null default 'draft'
    check (status in ('draft', 'published', 'archived')),
  published_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists posts_published_idx
  on public.posts (status, published_at desc);

create or replace function public.posts_set_updated_at()
returns trigger as $$
begin
  new.updated_at = now();
  return new;
end;
$$ language plpgsql;

drop trigger if exists posts_set_updated_at on public.posts;
create trigger posts_set_updated_at before update on public.posts
  for each row execute function public.posts_set_updated_at();

alter table public.posts enable row level security;

-- Feed público: qualquer pessoa (inclusive anônima) lê posts publicados.
create policy "posts_select_published_public"
  on public.posts for select
  to anon, authenticated
  using (status = 'published');

-- Staff de coordenação/gestão/admin também vê rascunhos, para revisão.
create policy "posts_select_drafts_staff"
  on public.posts for select
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('coordenacao', 'gestao', 'admin')
    )
  );

create policy "posts_manage_staff_only"
  on public.posts for all
  to authenticated
  using (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('coordenacao', 'gestao', 'admin')
    )
  )
  with check (
    exists (
      select 1 from public.profiles
      where id = auth.uid() and role in ('coordenacao', 'gestao', 'admin')
    )
  );
