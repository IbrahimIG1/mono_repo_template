import 'package:monorepo_template/features/notifications_screen/logic/cubit/notification_cubit.dart';
import 'package:monorepo_template/features/notifications_screen/logic/models/notification_model.dart';
import 'package:monorepo_template/features/notifications_screen/ui/widgets/notification_item/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsList extends StatelessWidget {
  const NotificationsList({
    super.key,
    required this.notificationsDetails,
    required this.cubit,
  });
  final List<NotificationsModel> notificationsDetails;
  final NotificationCubit cubit;
  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      separatorBuilder: (context, index) => Divider(),
      itemCount: notificationsDetails.length, // from cubit in real use
      padding: EdgeInsets.only(top: 10.h),
      itemBuilder: (context, index) {
        return Padding(
          padding: EdgeInsets.only(bottom: 24.h),
          child: NotificationItem(
            cubit: cubit,
            notificationModel: notificationsDetails[index],
          ),
        );
      },
    );
  }
}
