import 'package:elajtech/core/constants/app_colors.dart';
// import 'package:elajtech/core/services/firestore_service.dart'; // Unused
import 'package:elajtech/features/notifications/domain/repositories/notification_repository.dart';
import 'package:elajtech/features/patient/notifications/presentation/screens/notifications_screen.dart';
import 'package:elajtech/shared/models/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class NotificationIcon extends StatelessWidget {
  const NotificationIcon({required this.userId, super.key});
  final String userId;

  @override
  Widget build(BuildContext context) => StreamBuilder<List<NotificationModel>>(
    stream: GetIt.I<NotificationRepository>().getNotificationsStream(userId),
    builder: (context, snapshot) {
      var unreadCount = 0;
      if (snapshot.hasData) {
        unreadCount = snapshot.data!.where((element) => !element.isRead).length;
      }

      return Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () async {
              await Navigator.push<void>(
                context,
                MaterialPageRoute<void>(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          if (unreadCount > 0)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                constraints: const BoxConstraints(
                  minWidth: 16,
                  minHeight: 16,
                ),
                child: Text(
                  unreadCount > 9 ? '+9' : unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    },
  );
}
