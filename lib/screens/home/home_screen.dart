import 'package:flutter/material.dart';

import '../../core/data/care_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/appointment.dart';
import '../../models/journey_event.dart';
import '../../widgets/cuidar_card.dart';
import '../../widgets/error_state.dart';
import '../appointments/appointments_screen.dart';
import '../appointments/widgets/appointment_card.dart';
import 'widgets/care_journey_stepper.dart';

/// Tela inicial: jornada do cuidado (journey_events) + próximos atendimentos
/// (v_agenda) do paciente selecionado.
class HomeScreen extends StatefulWidget {
  final String patientId;

  const HomeScreen({super.key, required this.patientId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = CareRepository();
  late Future<(List<JourneyEvent>, List<Appointment>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<JourneyEvent>, List<Appointment>)> _load() async {
    final journey = await _repository.fetchJourney(widget.patientId);
    final appointments = await _repository.fetchAppointments(widget.patientId);
    return (journey, appointments);
  }

  Future<void> _confirm(Appointment appointment) async {
    await _repository.confirmAppointment(appointment.id);
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<JourneyEvent>, List<Appointment>)>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(
            error: snapshot.error,
            onRetry: () => setState(() => _future = _load()),
          );
        }

        final (journey, appointments) = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _load()),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.all(AppRadii.spaceMd),
                sliver: SliverToBoxAdapter(
                  child: CuidarCard(
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Jornada do Cuidado', style: AppTextStyles.titleMd),
                        const SizedBox(height: 4),
                        Text('Linha do tempo do acompanhamento.', style: AppTextStyles.bodySm),
                        const SizedBox(height: AppRadii.spaceLg),
                        journey.isEmpty
                            ? Text('Nenhum evento registrado ainda.', style: AppTextStyles.bodySm)
                            : CareJourneyStepper(events: journey),
                      ],
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppRadii.spaceMd),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Próximos atendimentos', style: AppTextStyles.titleMd),
                      TextButton(
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => AppointmentsScreen(patientId: widget.patientId)),
                        ),
                        child: const Text('Ver todas'),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppRadii.spaceMd),
                sliver: appointments.isEmpty
                    ? SliverToBoxAdapter(
                        child: Text('Nenhum atendimento agendado.', style: AppTextStyles.body),
                      )
                    : SliverList.separated(
                        itemCount: appointments.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppRadii.spaceMd),
                        itemBuilder: (context, index) {
                          final appointment = appointments[index];
                          return AppointmentCard(
                            appointment: appointment,
                            onConfirm: () => _confirm(appointment),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
