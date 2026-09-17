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
        children: [
          for (var i = 0; i < events.length; i++) ...[
            _StepNode(event: events[i], isCurrent: i == events.length - 1),
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

  const _StepNode({required this.event, required this.isCurrent});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM');
    return SizedBox(
      width: 96,
      child: Column(
        children: [
          Container(
            width: isCurrent ? 48 : 36,
            height: isCurrent ? 48 : 36,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCurrent ? AppColors.peach : AppColors.mint,
              border: isCurrent ? Border.all(color: AppColors.primaryText, width: 2) : null,
            ),
            child: isCurrent ? null : const Icon(Icons.check_rounded, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            event.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.label,
          ),
          Text(dateFormat.format(event.createdAt), style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
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
      width: 28,
      height: 3,
      margin: const EdgeInsets.only(bottom: 30),
      decoration: BoxDecoration(
        color: active ? AppColors.mint : AppColors.surface,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
