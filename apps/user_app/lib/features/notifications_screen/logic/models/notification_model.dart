import 'package:shared/models/user_mode.dart';

class NotificationModel {
  List<NotificationsModel> notifications;
  int unreadCount;

  NotificationModel({required this.notifications, required this.unreadCount});

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notifications: List<NotificationsModel>.from(
          json["notifications"].map((x) => NotificationsModel.fromJson(x)),
        ),
        unreadCount: json["unreadCount"],
      );

  Map<String, dynamic> toJson() => {
    "notifications": List<dynamic>.from(notifications.map((x) => x.toJson())),
    "unreadCount": unreadCount,
  };
}

class NotificationsModel {
  String id;
  String type;
  String user;
  UserModel byUser;
  String description;
  bool isRead;
  DateTime createdAt;
  DateTime updatedAt;
  int v;

  NotificationsModel({
    required this.id,
    required this.type,
    required this.user,
    required this.byUser,
    required this.description,
    required this.isRead,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
  });

  factory NotificationsModel.fromJson(Map<String, dynamic> json) =>
      NotificationsModel(
        id: json["_id"],
        type: json["type"],
        user: json["user"],
        byUser: UserModel.fromJson(json["byUser"]),
        description: json["description"],
        isRead: json["isRead"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "type": type,
    "user": user,
    "byUser": byUser.toJson(),
    "description": description,
    "isRead": isRead,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "__v": v,
  };
}

