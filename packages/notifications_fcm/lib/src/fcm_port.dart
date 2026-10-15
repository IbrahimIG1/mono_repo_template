import 'dart:async';

enum FcmAuthorizationStatus {
  notDetermined,
  denied,
  deniedPermanently,
  provisional,
  authorized,
}

final class FcmMessage {
  const FcmMessage({
    required this.id,
    required this.data,
    this.title,
    this.body,
  });

  final String? id;
  final Map<String, String> data;
  final String? title;
  final String? body;
}

abstract interface class FcmPort {
  Stream<String> get tokenChanges;
  Stream<FcmMessage> get foregroundMessages;
  Stream<FcmMessage> get openedMessages;

  Future<FcmAuthorizationStatus> requestPermission();
  Future<String?> getToken();
  Future<FcmMessage?> getInitialMessage();
}

final class FakeFcmPort implements FcmPort {
  final StreamController<String> tokenController = StreamController.broadcast();
  final StreamController<FcmMessage> foregroundController =
      StreamController.broadcast();
  final StreamController<FcmMessage> openedController =
      StreamController.broadcast();

  FcmAuthorizationStatus permission = FcmAuthorizationStatus.authorized;
  String? token;
  FcmMessage? initialMessage;
  var permissionRequests = 0;

  @override
  Stream<String> get tokenChanges => tokenController.stream;

  @override
  Stream<FcmMessage> get foregroundMessages => foregroundController.stream;

  @override
  Stream<FcmMessage> get openedMessages => openedController.stream;

  @override
  Future<String?> getToken() async => token;

  @override
  Future<FcmMessage?> getInitialMessage() async => initialMessage;

  @override
  Future<FcmAuthorizationStatus> requestPermission() async {
    permissionRequests++;
    return permission;
  }

  Future<void> dispose() async {
    await Future.wait([
      tokenController.close(),
      foregroundController.close(),
      openedController.close(),
    ]);
  }
}
