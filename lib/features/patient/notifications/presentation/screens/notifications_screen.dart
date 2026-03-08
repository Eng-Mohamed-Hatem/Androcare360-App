import 'package:elajtech/core/constants/app_colors.dart';
import 'package:elajtech/features/auth/providers/auth_provider.dart';
// import 'package:elajtech/core/services/firestore_service.dart'; // Unused
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/features/patient/notifications/presentation/widgets/notification_card.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:get_it/get_it.dart';

/// Notifications Screen - شاشة الإشعارات
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('يجب تسجيل الدخول لعرض الإشعارات')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('الإشعارات'),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'تحديد الكل كمقروء',
            onPressed: () async {
              try {
                final result = await GetIt.I<NotificationRepository>()
                    .markAllNotificationsAsRead(user.id);

                result.fold(
                  (failure) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('حدث خطأ: ${failure.message}')),
                      );
                    }
                  },
                  (_) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('تم تحديد جميع الإشعارات كمقروءة'),
                        ),
                      );
                    }
                  },
                );
              } on Exception catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('حدث خطأ: $e')));
                }
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<NotificationModel>>(
        stream: GetIt.I<NotificationRepository>().getNotificationsStream(
          user.id,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('حدث خطأ: ${snapshot.error}'));
          }

          final notifications = snapshot.data ?? [];
          final unreadCount = notifications.where((n) => !n.isRead).length;

          if (notifications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.notifications_none,
                    size: 80,
                    color: AppColors.textSecondaryLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'لا توجد إشعارات',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.textSecondaryLight,
                    ),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Unread Count Badge
              if (unreadCount > 0)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  color: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    'لديك $unreadCount إشعار غير مقروء',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),

              // Notifications List
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(24),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: NotificationCard(
                      notification: notifications[index],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
