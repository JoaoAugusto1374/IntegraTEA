import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../models/appointment.dart';
import '../../../models/enums.dart';
import '../../../widgets/cuidar_card.dart';

/// Card de um atendimento (a partir de `v_agenda`), com ação de confirmação
/// de presença pelo responsável quando aplicável.
class AppointmentCard extends StatelessWidget {
  final Appointment appointment;
  final VoidCallback onConfirm;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("EEEE, d 'de' MMMM · HH:mm", 'pt_BR');

    return CuidarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(color: AppColors.mint, shape: BoxShape.circle),
                child: const Icon(Icons.event_available_rounded, color: Colors.white),
              ),
              const SizedBox(width: AppRadii.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(appointment.serviceName ?? appointment.specialtyName ?? 'Atendimento', style: AppTextStyles.subtitle),
                    if (appointment.professionalName != null)
                      Text(appointment.professionalName!, style: AppTextStyles.bodySm),
                  ],
                ),
              ),
              _StatusChip(status: appointment.status),
            ],
          ),
          const SizedBox(height: AppRadii.spaceMd),
          _InfoLine(icon: Icons.calendar_today_rounded, text: _capitalize(dateFormat.format(appointment.scheduledFor))),
          if (appointment.confirmedByGuardianAt != null) ...[
            const SizedBox(height: 6),
            _InfoLine(icon: Icons.check_circle_rounded, text: 'Presença confirmada por você'),
          ],
          if (appointment.needsGuardianConfirmation) ...[
            const SizedBox(height: AppRadii.spaceMd),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onConfirm,
                icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
                label: const Text('Confirmar presença'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

class _InfoLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.primaryText.withValues(alpha: 0.6)),
        const SizedBox(width: 6),
        Expanded(child: Text(text, style: AppTextStyles.bodySm)),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final AppointmentStatus status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: status.color, borderRadius: BorderRadius.circular(AppRadii.chip)),
      child: Text(status.label, style: AppTextStyles.label.copyWith(fontSize: 11, color: AppColors.primaryText)),
    );
  }
}
