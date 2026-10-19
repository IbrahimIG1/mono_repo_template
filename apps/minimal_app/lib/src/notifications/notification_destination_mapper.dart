import 'package:notifications_core/notifications_core.dart';
import 'package:platform_foundation/platform_foundation.dart';

abstract interface class NotificationDestinationMapper {
  Result<String> map(NotificationPayload payload);
}

final class ReferenceNotificationDestinationMapper
    implements NotificationDestinationMapper {
  const ReferenceNotificationDestinationMapper();

  @override
  Result<String> map(NotificationPayload payload) {
    if (payload.type != 'protected_item') {
      return _invalid('notifications.unknown_destination_type');
    }
    if (payload.arguments.keys.any((key) => key != 'item_id' && key != 'tab')) {
      return _invalid('notifications.unexpected_destination_argument');
    }
    final itemId = payload.arguments['item_id'];
    if (itemId == null ||
        itemId.isEmpty ||
        itemId.length > 128 ||
        !RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(itemId)) {
      return _invalid('notifications.invalid_destination_item');
    }
    final tab = payload.arguments['tab'];
    if (tab != null &&
        (tab.isEmpty ||
            tab.length > 64 ||
            !RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(tab))) {
      return _invalid('notifications.invalid_destination_tab');
    }
    return Success(
      '/${Uri(pathSegments: ['protected', itemId], queryParameters: tab == null ? null : {'tab': tab})}',
    );
  }

  Failure<String> _invalid(String code) => Failure(
    NotificationFailure(
      kind: NotificationFailureKind.invalidPayload,
      code: code,
      message: 'Notification destination is invalid.',
    ),
  );
}
