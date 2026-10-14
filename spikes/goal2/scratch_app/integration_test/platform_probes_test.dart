import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal2_scratch_app/spike_probes.dart';
import 'package:integration_test/integration_test.dart';

const webSocketUrl = String.fromEnvironment('SPIKE_WEBSOCKET_URL');
const webSocketTicket = 'goal2-one-time-ticket';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('secure storage writes, reads, and deletes', (tester) async {
    const probe = SecureStorageProbe(FlutterSecureStorage());
    await probe.verifyRoundTrip();
  });

  testWidgets('browser-compatible WebSocket ticket is accepted', (
    tester,
  ) async {
    const probe = BrowserWebSocketAuthProbe();
    await probe.verifyTicketHandshake(
      endpoint: Uri.parse(webSocketUrl),
      ticket: webSocketTicket,
    );
  }, skip: webSocketUrl.isEmpty);
}
