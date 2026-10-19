import 'dart:io';

abstract interface class WebSocketConnection {
  Stream<Object?> get messages;
  void add(String frame);
  Future<void> close();
}

abstract interface class WebSocketConnector {
  Future<WebSocketConnection> connect(
    Uri endpoint, {
    required Map<String, String> headers,
  });
}

final class IoWebSocketConnector implements WebSocketConnector {
  const IoWebSocketConnector();

  @override
  Future<WebSocketConnection> connect(
    Uri endpoint, {
    required Map<String, String> headers,
  }) async => _IoWebSocketConnection(
    await WebSocket.connect(endpoint.toString(), headers: headers),
  );
}

final class _IoWebSocketConnection implements WebSocketConnection {
  const _IoWebSocketConnection(this._socket);

  final WebSocket _socket;

  @override
  Stream<Object?> get messages => _socket;

  @override
  void add(String frame) => _socket.add(frame);

  @override
  Future<void> close() async {
    await _socket.close();
  }
}
