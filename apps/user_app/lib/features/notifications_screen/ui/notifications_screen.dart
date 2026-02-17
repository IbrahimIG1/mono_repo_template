import 'package:core/helper/spacer.dart';
import 'package:shared/widgets/buttons/app_header.dart';
import 'package:shared/widgets/toast/app_toast.dart';
import 'package:sandwich_app/features/notifications_screen/logic/cubit/notification_cubit.dart';
import 'package:sandwich_app/features/notifications_screen/logic/cubit/notification_state.dart';
import 'package:sandwich_app/features/notifications_screen/ui/widgets/notifications_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key, required this.notificationCubit});

  final NotificationCubit notificationCubit;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is GetMyNotificationsError) {
            showToast(msg: state.errorModel.message, state: ToastStates.ERROR);
          }
        },
        builder: (context, state) {
          NotificationCubit cubit = NotificationCubit.get(context);
          return Scaffold(
            body: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    appHeader(
                      context,
                      title: "الاشعارات",
                      onBack: () {
                        Navigator.pop(context);
                      },
                    ),
                    verticalSpace(30.h),
                    if (state is GetMyNotificationsSuccess)
                      Expanded(
                        child: NotificationsList(
                          cubit: cubit,
                          notificationsDetails:
                              cubit.notificationModel!.notifications,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

