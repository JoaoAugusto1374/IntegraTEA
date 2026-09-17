# Schema real do Supabase (projeto `ccgwifyqlsbklgiuardc`)

> Este projeto Supabase **já existe em produção** com dados reais (163 pacientes,
> 1469 consultas, 186 na fila, 152 triagens no momento da inspeção). As tabelas
> abaixo foram descobertas via introspecção do OpenAPI do PostgREST (com
> `service_role` key) — não foram criadas por este repositório. Qualquer
> alteração de schema deve ser **aditiva** (novas tabelas/colunas), nunca
> destrutiva, e aplicada manualmente pelo responsável pelo projeto via
> SQL Editor do Supabase (não temos credencial de DDL direta no banco).

## Tabelas

- **patients** — id, cns, cpf, full_name, birth_date, mother_name, responsible_id (FK profiles), aps_reference, social_name, sex, guardian_name, guardian_phone, guardian_relationship, address, neighborhood, school_name, status, merged_into_id (FK patients), created_by (FK profiles), created_at, updated_at
- **profiles** — id, full_name, role (`user_role`), service_id (FK services), email, phone, job_title, specialty_id (FK specialties), active, created_at, updated_at
- **appointments** — id, patient_id, service_id, professional_id, specialty_id, queue_entry_id, scheduled_for, status (`appointment_status`), evolution_notes, absence_reason, objective, summary, duration_minutes, rescheduled_from_id, cancel_reason, attendance_marked_at/by, created_by, version, created_at
- **queue_entries** — id, patient_id, service_id, specialty, specialty_id, priority (`priority_level`), status (`queue_status`), position, entered_at, updated_at, triage_id (FK triages), referral_id (FK referrals), origin, priority_justification, cancel_reason, started_at, finished_at, created_by
- **v_queue_ranked** (view) — queue_entries + patient_name/birth_date/cns, service_name/code/color, specialty_name, wait_days, priority_points, points_per_day, score, queue_position, rank_reason — **usar esta view para exibir a fila**, não a tabela crua
- **v_agenda** (view) — appointments já com patient_name/birth_date, guardian_name/phone, service_name/code/color, professional_name, specialty_name, has_session_record — **usar esta view para listar consultas**
- **triages** — id, patient_id, service_id, professional_id, specialty_id, priority, clinical_notes, need_description, priority_justification, created_at
- **care_plans** — id, patient_id, reference_service_id, coordinator_id, goal, status, review_due_at, created_by, created_at, updated_at
- **care_plan_items** — id, plan_id (FK care_plans), patient_id, description, service_id, responsible_id (FK profiles), due_date, status, completed_at, created_by, created_at, updated_at
- **journey_events** — id, patient_id, service_id, event_type, description, stage, source_table, source_id, metadata (jsonb), created_by, created_at — **fonte da "Jornada do Cuidado" / stepper**
- **care_alerts** — id, patient_id, alert_type, code, title, reason, severity (`alert_severity`), status (`alert_status`), action_recommended, service_id, related_table, related_id, review_notes, reviewed_by/at, dedupe_key, created_at
- **referrals** — id, patient_id, origin_service_id, destination_service_id, specialty_id, reason, priority, status (`referral_status`), response_notes, complement_notes, due_at, created_by, responded_by/at, created_at, updated_at
- **form_definitions** / **form_responses** — formulários dinâmicos (fields/answers em jsonb) usados em triagem/atendimento
- **services** — id, name, code, capacity, description, secretaria, color, address, phone, active
- **specialties** / **service_specialties** — catálogo de especialidades e capacidade mensal por serviço
- **system_parameters** — key/value (jsonb) de configuração
- **audit_logs**, **record_revisions**, **patient_duplicate_candidates** — trilha de auditoria e deduplicação (uso administrativo)

## Enums

- `appointment_status`: agendado, presente, falta_justificada, falta_injustificada, cancelado
- `priority_level`: P1, P2, P3
- `queue_status`: aguardando, em_atendimento, concluido, cancelado
- `alert_severity`: atencao, critico
- `alert_status`: pendente, revisado
- `referral_status`: pendente, aceito, devolvido, complemento_solicitado
- `user_role`: recepcao, profissional, coordenacao, gestao, admin, responsavel

## RLS observada

Leitura anônima (`anon`) retorna **0 linhas em todas as tabelas testadas**,
inclusive catálogos como `services`/`specialties`. Ou seja, o app **precisa de
login real** (Supabase Auth) para qualquer tela funcionar — não há dado
público hoje. As migrations `0004`/`0005` abrem uma exceção pontual: posts
publicados ficam legíveis por `anon`, propositalmente, pois são conteúdo de
divulgação pública (tipo Instagram da prefeitura).

## O que falta e foi adicionado por este repositório

- `notifications` (migration `0004`): notificações in-app por usuário.
- `posts` (migration `0005`): blog/mural de notícias público.

Nenhuma migration deste repositório altera ou remove tabelas existentes.
