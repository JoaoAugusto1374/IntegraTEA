import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/data/care_repository.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radii.dart';
import '../../core/theme/app_text_styles.dart';
import '../../models/notification_item.dart';
import '../../widgets/cuidar_card.dart';
import '../../widgets/error_state.dart';

/// Central de notificações (`public.notifications`).
class NotificationsScreen extends StatefulWidget {
  final String profileId;

  const NotificationsScreen({super.key, required this.profileId});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _repository = CareRepository();
  late Future<List<NotificationItem>> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchNotifications(widget.profileId);
  }

  Future<void> _markRead(NotificationItem item) async {
    if (item.isRead) return;
    await _repository.markNotificationRead(item.id);
    setState(() => _future = _repository.fetchNotifications(widget.profileId));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<NotificationItem>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return ErrorState(
            error: snapshot.error,
            onRetry: () => setState(() => _future = _repository.fetchNotifications(widget.profileId)),
          );
        }
        final notifications = snapshot.data!;
        if (notifications.isEmpty) {
          return const Center(child: Text('Você não tem notificações.'));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _repository.fetchNotifications(widget.profileId)),
          child: ListView.separated(
            padding: const EdgeInsets.all(AppRadii.spaceMd),
            itemCount: notifications.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppRadii.spaceSm),
            itemBuilder: (context, index) {
              final item = notifications[index];
              return CuidarCard(
                color: item.isRead ? Colors.white : AppColors.pastelYellow.withValues(alpha: 0.18),
                onTap: () => _markRead(item),
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
                            decoration: const BoxDecoration(color: AppColors.peach, shape: BoxShape.circle),
                          ),
                        Expanded(child: Text(item.title, style: AppTextStyles.subtitle)),
                      ],
                    ),
                    if (item.body != null) ...[
                      const SizedBox(height: 4),
                      Text(item.body!, style: AppTextStyles.bodySm),
                    ],
                    const SizedBox(height: 6),
                    Text(DateFormat('dd/MM/yyyy HH:mm').format(item.createdAt), style: AppTextStyles.bodySm.copyWith(fontSize: 11)),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
