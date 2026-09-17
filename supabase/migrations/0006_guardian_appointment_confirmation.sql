-- ============================================================================
-- Cuidar+ | Confirmação de presença pelo responsável (ADITIVO)
-- Não concede UPDATE amplo em `appointments` (que tem campos clínicos) —
-- expõe apenas uma função RPC restrita que só altera 1 coluna nova, e só
-- quando quem chama é o responsável cadastrado do paciente da consulta.
-- Aplicar manualmente via SQL Editor do Supabase.
-- ============================================================================

alter table public.appointments
  add column if not exists confirmed_by_guardian_at timestamptz;

create or replace function public.confirm_appointment_attendance(p_appointment_id uuid)
returns void as $$
declare
  v_patient_id uuid;
  v_responsible_id uuid;
begin
  select a.patient_id into v_patient_id
  from public.appointments a
  where a.id = p_appointment_id;

  if v_patient_id is null then
    raise exception 'Consulta não encontrada';
  end if;

  select p.responsible_id into v_responsible_id
  from public.patients p
  where p.id = v_patient_id;

  if v_responsible_id is distinct from auth.uid() then
    raise exception 'Você não tem permissão para confirmar esta consulta';
  end if;

  update public.appointments
     set confirmed_by_guardian_at = now()
   where id = p_appointment_id
     and confirmed_by_guardian_at is null;
end;
$$ language plpgsql security definer set search_path = public;

grant execute on function public.confirm_appointment_attendance(uuid) to authenticated;
