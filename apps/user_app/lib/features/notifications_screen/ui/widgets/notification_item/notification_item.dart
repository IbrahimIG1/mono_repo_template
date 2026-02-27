import 'package:core/helper/format_time.dart';
import 'package:core/helper/spacer.dart';
import 'package:shared/styles/fonts/app_text_styles.dart';
import 'package:monorepo_template/features/notifications_screen/logic/cubit/notification_cubit.dart';
import 'package:monorepo_template/features/notifications_screen/logic/models/notification_model.dart';
import 'package:monorepo_template/features/notifications_screen/ui/widgets/notification_item/notification_item_name_and_unread_num.dart';
import 'package:monorepo_template/features/notifications_screen/ui/widgets/notification_item/notification_item_profile_image.dart';
import 'package:monorepo_template/features/notifications_screen/ui/widgets/notification_item/notification_item_time_and_delete_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationItem extends StatelessWidget {
  final NotificationsModel notificationModel;
  final NotificationCubit cubit;

  const NotificationItem({
    required this.notificationModel,
    required this.cubit,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        cubit.updateNotifications(
          notificationModel.id,
          notificationModel.isRead,
        );
      },
      child: Container(
        color: Colors.transparent,
        height: 52.h,
        child: Row(
          children: [
            //* Profile Image
            notificationItemProfileImage(notificationModel.byUser.image ?? ""),
            horizontalSpace(16.w),
            //* chat details
            Expanded(child: _buildChatDetails(context)),
            //* time and delete icon
            notificationItemTimeAndDelete(
              time: formatTimeHelper(notificationModel.createdAt.toString()),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the chat details (name, unread count, and message)
  Widget _buildChatDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //*  name and unread count
        notificationItemName(title: notificationModel.byUser.userName),
        verticalSpace(8.h),
        Text(
          notificationModel.description,
          style: AppTextStyles().fontGold14Regular,
        ),
      ],
    );
  }
}
