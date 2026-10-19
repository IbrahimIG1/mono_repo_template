import 'dart:convert';

import 'package:platform_foundation/platform_foundation.dart';

import 'failure.dart';
import 'models.dart';

final class NotificationPayloadDecoder {
  const NotificationPayloadDecoder({
    this.supportedVersion = 1,
    this.maximumEncodedBytes = 4096,
    this.maximumArguments = 32,
  });

  final int supportedVersion;
  final int maximumEncodedBytes;
  final int maximumArguments;

  Result<NotificationPayload> decode(Map<String, String> data) {
    if (utf8.encode(jsonEncode(data)).length > maximumEncodedBytes) {
      return _invalid(
        'notifications.payload_too_large',
        'Payload is too large.',
      );
    }

    final rawVersion = data['v'];
    final version = rawVersion == null ? null : int.tryParse(rawVersion);
    if (version != supportedVersion) {
      return _invalid(
        'notifications.unsupported_payload_version',
        'Notification payload version is unsupported.',
      );
    }

    final type = data['type'];
    final interactionId = data['interaction_id'];
    if (!_isIdentifier(type) || !_isIdentifier(interactionId)) {
      return _invalid(
        'notifications.invalid_payload_identity',
        'Notification payload identity is invalid.',
      );
    }

    const reserved = {'v', 'type', 'interaction_id'};
    final arguments = <String, String>{};
    for (final entry in data.entries) {
      if (reserved.contains(entry.key)) {
        continue;
      }
      if (!_isArgumentKey(entry.key) || entry.value.length > 1024) {
        return _invalid(
          'notifications.invalid_payload_argument',
          'Notification payload contains an invalid argument.',
        );
      }
      arguments[entry.key] = entry.value;
    }
    if (arguments.length > maximumArguments) {
      return _invalid(
        'notifications.too_many_payload_arguments',
        'Notification payload has too many arguments.',
      );
    }

    return Success(
      NotificationPayload(
        version: version!,
        type: type!,
        interactionId: interactionId!,
        arguments: Map.unmodifiable(arguments),
      ),
    );
  }

  bool _isIdentifier(String? value) =>
      value != null &&
      value.isNotEmpty &&
      value.length <= 128 &&
      RegExp(r'^[A-Za-z0-9._:-]+$').hasMatch(value);

  bool _isArgumentKey(String value) =>
      value.isNotEmpty &&
      value.length <= 64 &&
      RegExp(r'^[A-Za-z0-9._-]+$').hasMatch(value);

  Failure<NotificationPayload> _invalid(String code, String message) => Failure(
    NotificationFailure(
      kind: NotificationFailureKind.invalidPayload,
      code: code,
      message: message,
    ),
  );
}
