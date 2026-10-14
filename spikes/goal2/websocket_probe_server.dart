import 'dart:io';

const expectedTicket = 'goal2-one-time-ticket';

Future<void> main(List<String> arguments) async {
  final port = arguments.isEmpty ? 9234 : int.parse(arguments.single);
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  stdout.writeln('READY ws://${server.address.host}:${server.port}/socket');

  await for (final request in server) {
    final isSocketPath = request.uri.path == '/socket';
    final hasTicket = request.uri.queryParameters['ticket'] == expectedTicket;
    final canUpgrade = WebSocketTransformer.isUpgradeRequest(request);

    if (!isSocketPath || !hasTicket || !canUpgrade) {
      request.response.statusCode = HttpStatus.unauthorized;
      await request.response.close();
      continue;
    }

    stdout.writeln(
      "ACCEPT origin=${request.headers.value('origin') ?? 'none'}",
    );
    final socket = await WebSocketTransformer.upgrade(request);
    socket.listen((message) => socket.add('ack:$message'));
  }
}
