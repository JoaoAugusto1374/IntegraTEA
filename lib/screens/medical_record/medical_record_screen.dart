import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/data/care_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/care_plan.dart';
import '../../models/enums.dart';
import '../../models/referral.dart';
import '../../widgets/cuidar_card.dart';
import '../../widgets/error_state.dart';

/// Prontuário do paciente: planos de cuidado (care_plans/care_plan_items) e
/// encaminhamentos (referrals). Mantém fora campos clínicos sensíveis de uso
/// interno da equipe (ex.: clinical_notes de triagem).
class MedicalRecordScreen extends StatefulWidget {
  final String patientId;

  const MedicalRecordScreen({super.key, required this.patientId});

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  final _repository = CareRepository();
  late Future<(List<CarePlan>, List<Referral>)> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<(List<CarePlan>, List<Referral>)> _load() async {
    final plans = await _repository.fetchCarePlans(widget.patientId);
    final referrals = await _repository.fetchReferrals(widget.patientId);
    return (plans, referrals);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<(List<CarePlan>, List<Referral>)>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(error: snapshot.error, onRetry: () => setState(() => _future = _load()));
        }

        final (plans, referrals) = snapshot.data!;

        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _load()),
          child: ListView(
            padding: const EdgeInsets.all(AppRadii.spaceMd),
            children: [
              Text('Plano de cuidado', style: AppTextStyles.titleMd),
              const SizedBox(height: AppRadii.spaceMd),
              if (plans.isEmpty)
                Text('Nenhum plano de cuidado registrado.', style: AppTextStyles.bodySm)
              else
                ...plans.map((plan) => Padding(
                      padding: const EdgeInsets.only(bottom: AppRadii.spaceMd),
                      child: _CarePlanCard(plan: plan),
                    )),
              const SizedBox(height: AppRadii.spaceLg),
              Text('Encaminhamentos', style: AppTextStyles.titleMd),
              const SizedBox(height: AppRadii.spaceMd),
              if (referrals.isEmpty)
                Text('Nenhum encaminhamento registrado.', style: AppTextStyles.bodySm)
              else
                ...referrals.map((referral) => Padding(
                      padding: const EdgeInsets.only(bottom: AppRadii.spaceMd),
                      child: _ReferralCard(referral: referral),
                    )),
            ],
          ),
        );
      },
    );
  }
}

class _CarePlanCard extends StatelessWidget {
  final CarePlan plan;
  const _CarePlanCard({required this.plan});

  @override
  Widget build(BuildContext context) {
    return CuidarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(plan.goal ?? 'Plano de cuidado', style: AppTextStyles.subtitle),
          const SizedBox(height: 4),
          Text('Status: ${plan.status}', style: AppTextStyles.bodySm),
          if (plan.items.isNotEmpty) ...[
            const SizedBox(height: AppRadii.spaceMd),
            const Divider(height: 1),
            const SizedBox(height: AppRadii.spaceSm),
            ...plan.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        item.isDone ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                        size: 18,
                        color: item.isDone ? AppColors.mint : AppColors.primaryText.withValues(alpha: 0.4),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(item.description ?? '', style: AppTextStyles.bodySm)),
                    ],
                  ),
                )),
          ],
        ],
      ),
    );
  }
}

class _ReferralCard extends StatelessWidget {
  final Referral referral;
  const _ReferralCard({required this.referral});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return CuidarCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(referral.reason ?? 'Encaminhamento', style: AppTextStyles.subtitle)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(color: AppColors.lavender, borderRadius: BorderRadius.circular(AppRadii.chip)),
                child: Text(referral.status.label, style: AppTextStyles.label.copyWith(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text('Solicitado em ${dateFormat.format(referral.createdAt)}', style: AppTextStyles.bodySm),
        ],
      ),
    );
  }
}
