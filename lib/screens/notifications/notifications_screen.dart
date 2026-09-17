import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/notification_item.dart';
import '../../widgets/cuidar_card.dart';

/// Central de notificações mockada para visualização direta de dados de teste.
class NotificationsScreen extends StatefulWidget {
  final String profileId;

  const NotificationsScreen({super.key, required this.profileId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  // Lista local de mocks fixa para garantir a exibição sem depender do banco
  final List<NotificationItem> _displayList = [
    NotificationItem(
      id: 'mock-1',
      type: 'alert',
      title: 'Consulta Confirmada 🩺',
      body: 'A consulta com o Fonoaudiólogo foi confirmada para o dia 25/10 às 09:30 na Casa Mais Azul.',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    NotificationItem(
      id: 'mock-2',
      type: 'info',
      title: 'Novo Encaminhamento 📋',
      body: 'Um novo encaminhamento para Terapia Ocupacional (IntegraTEA) foi gerado pelo sistema.',
      isRead: false,
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
    NotificationItem(
      id: 'mock-3',
      type: 'warning',
      title: 'Documentação Pendente ⚠️',
      body: 'Por favor, atualize o cartão do SUS do dependente na recepção da unidade.',
      isRead: true,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
    ),
  ];

  void _markRead(int index) {
    if (_displayList[index].isRead) return;
    setState(() {
      _displayList[index] = _displayList[index].copyWith(isRead: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => setState(() {}),
      child: ListView.separated(
        padding: const EdgeInsets.all(AppRadii.spaceMd),
        itemCount: _displayList.length,
        separatorBuilder: (_, _) => const SizedBox(height: AppRadii.spaceSm),
        itemBuilder: (context, index) {
          final item = _displayList[index];

          return CuidarCard(
            color: item.isRead ? Colors.white : AppColors.primary.withOpacity(0.05),
            onTap: () => _markRead(index),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (!item.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                    Expanded(
                      child: Text(
                        item.title,
                        style: AppTextStyles.subtitle.copyWith(
                          color: item.isRead ? AppColors.primaryText : AppColors.primary,
                          fontWeight: item.isRead ? FontWeight.w600 : FontWeight.w700,
                        ),
                      ),
                    ),

                  ],
                ),
                if (item.body != null) ...[
                  const SizedBox(height: 6),
                  Text(item.body!, style: AppTextStyles.bodySm.copyWith(color: AppColors.secondaryText)),
                ],
                const SizedBox(height: 8),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt),
                  style: AppTextStyles.bodySm.copyWith(fontSize: 10, color: AppColors.secondaryText.withOpacity(0.7)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
