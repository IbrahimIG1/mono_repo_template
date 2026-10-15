import 'dart:convert';
import 'dart:io';

import 'package:auth_core/auth_core.dart';
import 'package:auth_core/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:minimal_app/src/auth/session_network_bridge.dart';
import 'package:networking/dio.dart';
import 'package:networking/networking.dart';
import 'package:platform_foundation/platform_foundation.dart';

void main() {
  test(
    'twenty concurrent 401 responses cause one refresh and one replay each',
    () async {
      final server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
      var requestCount = 0;
      final serverDone = server.forEach((request) async {
        requestCount++;
        final authorized =
            request.headers.value(HttpHeaders.authorizationHeader) ==
            'Bearer access-new';
        request.response.statusCode = authorized ? 200 : 401;
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({'authorized': authorized}));
        await request.response.close();
      });
      final gateway = FakeSessionGateway(
        refreshHandler: (_) async {
          await Future<void>.delayed(const Duration(milliseconds: 50));
          return Success(_newSession);
        },
      );
      final manager = SessionManager(
        store: MemorySessionStore(initialSession: _oldSession),
        gateway: gateway,
      );
      await manager.restore();
      final client = DioNetworkClient.create(
        configuration: NetworkConfiguration(
          baseUri: Uri.parse('http://127.0.0.1:${server.port}'),
        ),
        accessTokenProvider: SessionAccessTokenProvider(manager),
        unauthorizedRecovery: SessionUnauthorizedRecovery(manager),
      );

      final results = await Future.wait(
        List.generate(
          20,
          (_) => client.send(
            const NetworkRequest(
              method: HttpMethod.get,
              path: '/protected',
              requiresAuthorization: true,
            ),
          ),
        ),
      );

      expect(results, everyElement(isA<Success<NetworkResponse>>()));
      expect(gateway.refreshCallCount, 1);
      expect(requestCount, 40);

      client.close();
      await manager.dispose();
      await server.close(force: true);
      await serverDone;
    },
  );
}

final _oldSession = AuthSession(
  accessToken: 'access-old',
  refreshToken: 'refresh-old',
  subjectId: 'user-1',
  expiresAt: DateTime.utc(2030, 1, 1),
);

final _newSession = AuthSession(
  accessToken: 'access-new',
  refreshToken: 'refresh-new',
  subjectId: 'user-1',
  expiresAt: DateTime.utc(2030, 1, 2),
);
