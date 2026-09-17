import 'package:flutter/material.dart';

import '../../core/data/care_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/enums.dart';
import '../../models/queue_entry.dart';
import '../../widgets/cuidar_card.dart';
import '../../widgets/error_state.dart';

/// Acompanhamento da fila de atendimento do paciente (`v_queue_ranked`).
class QueueScreen extends StatefulWidget {
  final String patientId;

  const QueueScreen({super.key, required this.patientId});

  @override
  State<QueueScreen> createState() => _QueueScreenState();
}

class _QueueScreenState extends State<QueueScreen> {
  final _repository = CareRepository();
  late Future<List<QueueEntry>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchQueueStatus(widget.patientId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<QueueEntry>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(
            error: snapshot.error,
            onRetry: () => setState(() => _future = _repository.fetchQueueStatus(widget.patientId)),
          );
        }
        final entries = snapshot.data!;
        if (entries.isEmpty) {
          return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Você não está em nenhuma fila de atendimento no momento.')));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _repository.fetchQueueStatus(widget.patientId)),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppRadii.spaceMd),
            itemCount: entries.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppRadii.spaceMd),
            itemBuilder: (context, index) => _QueueCard(entry: entries[index]),
          ),
        );
      },
    );
  }
}

class _QueueCard extends StatelessWidget {
  final QueueEntry entry;

  const _QueueCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    return CuidarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(entry.serviceName ?? entry.specialtyName ?? 'Fila de atendimento', style: AppTextStyles.subtitle),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: entry.priority.color, borderRadius: BorderRadius.circular(AppRadii.chip)),
                child: Text(entry.priority.label, style: AppTextStyles.label.copyWith(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: AppRadii.spaceMd),
          if (entry.queuePosition != null)
            Row(
              children: [
                const Icon(Icons.format_list_numbered_rounded, size: 18, color: AppColors.primaryText),
                const SizedBox(width: 8),
                Text('Posição estimada: ${entry.queuePosition}º', style: AppTextStyles.body),
              ],
            ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.hourglass_bottom_rounded, size: 18, color: AppColors.primaryText),
              const SizedBox(width: 8),
              Text(
                entry.waitDays != null
                    ? 'Aguardando há ${entry.waitDays} dia${entry.waitDays == 1 ? '' : 's'}'
                    : 'Status: ${entry.status.label}',
                style: AppTextStyles.body,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
