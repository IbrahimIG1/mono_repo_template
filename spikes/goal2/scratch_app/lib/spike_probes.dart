import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

final class SecureStorageProbe {
  const SecureStorageProbe(this._storage);

  final FlutterSecureStorage _storage;

  Future<void> verifyRoundTrip() async {
    const key = 'goal2_spike_round_trip';
    const value = 'goal2-spike-value';

    await _storage.delete(key: key);
    await _storage.write(key: key, value: value);
    final stored = await _storage.read(key: key);
    if (stored != value) {
      throw StateError('Secure storage returned an unexpected value.');
    }

    await _storage.delete(key: key);
    final deleted = await _storage.read(key: key);
    if (deleted != null) {
      throw StateError('Secure storage did not delete the probe value.');
    }
  }
}

final class BrowserWebSocketAuthProbe {
  const BrowserWebSocketAuthProbe();

  Future<void> verifyTicketHandshake({
    required Uri endpoint,
    required String ticket,
  }) async {
    final uri = endpoint.replace(
      queryParameters: {...endpoint.queryParameters, 'ticket': ticket},
    );
    final channel = WebSocketChannel.connect(uri);

    try {
      await channel.ready.timeout(const Duration(seconds: 10));
      channel.sink.add('probe');
      final response = await channel.stream.first.timeout(
        const Duration(seconds: 10),
      );
      if (response != 'ack:probe') {
        throw StateError('Unexpected WebSocket response: $response');
      }
    } finally {
      unawaited(channel.sink.close());
    }
  }
}
