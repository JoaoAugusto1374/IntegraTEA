import 'package:flutter/material.dart';

import '../../core/data/care_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/appointment.dart';
import '../../models/journey_event.dart';
import '../../models/queue_entry.dart';
import '../../models/referral.dart';
import '../../widgets/cuidar_card.dart';
import '../../widgets/error_state.dart';
import '../appointments/appointments_screen.dart';
import '../appointments/widgets/appointment_card.dart';
import 'widgets/care_journey_stepper.dart';

/// Tela inicial: jornada do cuidado (journey_events) + próximos atendimentos
/// (v_agenda) do paciente selecionado.
class HomeScreen extends StatefulWidget {
  final String patientId;
  final String profileName;

  const HomeScreen({super.key, required this.patientId, required this.profileName});


  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _repository = CareRepository();
  late Future<(List<JourneyEvent>, List<Appointment>, List<QueueEntry>, List<Referral>)> _future;


  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<JourneyEvent>, List<Appointment>, List<QueueEntry>, List<Referral>)> _load() async {
    final journey = await _repository.fetchJourney(widget.patientId);
    final appointments = await _repository.fetchAppointments(widget.patientId);
    final queue = await _repository.fetchQueueStatus(widget.patientId);
    final referrals = await _repository.fetchReferrals(widget.patientId);
    return (journey, appointments, queue, referrals);
  }

  Future<void> _confirm(Appointment appointment) async {
    await _repository.confirmAppointment(appointment.id);
    setState(() => _future = _load());
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<JourneyEvent>, List<Appointment>, List<QueueEntry>, List<Referral>)>(
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

        final (journey, appointments, queue, referrals) = snapshot.data!;
        
        final consultationCount = appointments.isNotEmpty ? appointments.length.toString() : '0';
        final referralCount = referrals.isNotEmpty ? referrals.length.toString() : '0';
        final queuePos = queue.isNotEmpty ? '${queue.first.queuePosition}º' : '-';
        final alertsCount = '0';





        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _load()),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(AppRadii.spaceMd, 0, AppRadii.spaceMd, AppRadii.spaceLg),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(AppRadii.card),
                      bottomRight: Radius.circular(AppRadii.card),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppRadii.spaceMd),
                      Text(
                        'Olá, ${widget.profileName}!',
                        style: AppTextStyles.displayLg.copyWith(color: AppColors.primary),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aqui você encontra uma visão integrada da jornada de cuidado e pode acompanhar cada etapa de forma simples e segura.',
                        style: AppTextStyles.body.copyWith(color: AppColors.secondaryText),
                      ),
                      const SizedBox(height: AppRadii.spaceLg),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar procedimentos, médicos...',
                          prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
                          fillColor: AppColors.background,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(AppRadii.spaceMd),
              sliver: SliverGrid.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: AppRadii.spaceMd,
                  crossAxisSpacing: AppRadii.spaceMd,
                  childAspectRatio: 1.35, // Altura perfeita para textos do paciente sem dar overflow
                  children: [
                    _StatCard(
                      title: 'Consultas agendadas',
                      value: consultationCount,
                      icon: Icons.calendar_today_outlined,
                      color: AppColors.purpleLight,
                      iconColor: AppColors.purple,
                    ),
                    _StatCard(
                      title: 'Avisos da unidade',
                      value: '3', // Quantidade de avisos mockados na aba de avisos
                      icon: Icons.notifications_none_rounded,
                      color: AppColors.peachLight,
                      iconColor: AppColors.peach,
                    ),
                    _StatCard(
                      title: 'Encaminhamentos',
                      value: referralCount,
                      icon: Icons.send_outlined,
                      color: AppColors.mintLight,
                      iconColor: AppColors.mint,
                    ),
                    _StatCard(
                      title: 'Posição na fila',
                      value: queuePos,
                      icon: Icons.access_time_rounded,
                      color: AppColors.blueLight,
                      iconColor: AppColors.blue,
                    ),
                  ],
                ),
              ),



              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppRadii.spaceMd),
                sliver: SliverToBoxAdapter(
                  child: CuidarCard(
                    color: AppColors.surface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Jornada do Cuidado', style: AppTextStyles.titleMd),
                            const Icon(Icons.more_horiz, color: AppColors.secondaryText),
                          ],
                        ),
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

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;
  final Color iconColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppRadii.spaceMd),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadii.card),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: AppTextStyles.titleLg.copyWith(color: AppColors.primaryText, fontSize: 22)),
              Text(title, style: AppTextStyles.bodySm.copyWith(color: AppColors.secondaryText)),
            ],
          ),
        ],
      ),
    );
  }
}

