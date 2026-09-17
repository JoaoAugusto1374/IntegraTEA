import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/journey_event.dart';

/// Stepper horizontal construído a partir de `journey_events` (ordem
/// cronológica). O evento mais recente é destacado como etapa atual.
class CareJourneyStepper extends StatelessWidget {
  final List<JourneyEvent> events;

  const CareJourneyStepper({super.key, required this.events});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = 0; i < events.length; i++) ...[
            _StepNode(
              event: events[i],
              isCurrent: i == events.length - 1,
              index: i,
            ),
            if (i != events.length - 1) const _StepConnector(active: true),
          ],
        ],
      ),
    );
  }
}


class _StepNode extends StatelessWidget {
  final JourneyEvent event;
  final bool isCurrent;
  final int index;

  const _StepNode({required this.event, required this.isCurrent, required this.index});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppColors.peach,
      AppColors.purple,
      AppColors.mint,
      AppColors.yellow,
      AppColors.blue,
    ];
    final color = colors[index % colors.length];
    final lightColor = [
      AppColors.peachLight,
      AppColors.purpleLight,
      AppColors.mintLight,
      AppColors.yellowLight,
      AppColors.blueLight,
    ][index % colors.length];

    final dateFormat = DateFormat('dd/MM');
    
    IconData icon;
    switch (event.label.toLowerCase()) {
      case String s when s.contains('entrada'): icon = Icons.login; break;
      case String s when s.contains('triagem'): icon = Icons.assignment_outlined; break;
      case String s when s.contains('fila'): icon = Icons.people_outline; break;
      case String s when s.contains('atendimento'): icon = Icons.medical_services_outlined; break;
      case String s when s.contains('continuidade'): icon = Icons.trending_up; break;
      default: icon = Icons.check_circle_outline;
    }

    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lightColor,
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            event.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label.copyWith(fontSize: 12),
          ),
          const SizedBox(height: 2),
          if (isCurrent)
            const Icon(Icons.check_circle, color: AppColors.mint, size: 16)
          else
            Text(dateFormat.format(event.createdAt), style: AppTextStyles.bodySm.copyWith(fontSize: 10)),
        ],
      ),
    );
  }
}


class _StepConnector extends StatelessWidget {
  final bool active;

  const _StepConnector({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 2,
      margin: const EdgeInsets.only(top: 22),
      decoration: BoxDecoration(
        color: active ? Colors.grey.shade200 : AppColors.surface,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}

