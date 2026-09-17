import 'package:flutter/material.dart';

import '../../core/data/care_repository.dart';
import '../../core/theme/app_radii.dart';
import '../../models/appointment.dart';
import '../../widgets/error_state.dart';
import 'widgets/appointment_card.dart';

/// Histórico completo de consultas do paciente (passadas e futuras),
/// a partir da view `v_agenda`.
class AppointmentsScreen extends StatefulWidget {
  final String patientId;

  const AppointmentsScreen({super.key, required this.patientId});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  final _repository = CareRepository();
  late Future<List<Appointment>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchAppointments(widget.patientId, upcomingOnly: false);
  }

  Future<void> _confirm(Appointment appointment) async {
    await _repository.confirmAppointment(appointment.id);
    setState(() => _future = _repository.fetchAppointments(widget.patientId, upcomingOnly: false));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultas')),
      body: FutureBuilder<List<Appointment>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return ErrorState(
              error: snapshot.error,
              onRetry: () => setState(
                () => _future = _repository.fetchAppointments(widget.patientId, upcomingOnly: false),
              ),
            );
          }
          final appointments = snapshot.data!;
          if (appointments.isEmpty) {
            return const Center(child: Text('Nenhuma consulta registrada.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppRadii.spaceMd),
            itemCount: appointments.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppRadii.spaceMd),
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return AppointmentCard(appointment: appointment, onConfirm: () => _confirm(appointment));
            },
          );
        },
      ),
    );
  }
}
