import 'package:auth_core/auth_core.dart';
import 'package:networking/dio.dart';
import 'package:networking/networking.dart';
import 'package:platform_foundation/platform_foundation.dart';
import 'package:storage/flutter_secure_storage.dart';
import 'package:storage/shared_preferences.dart';
import 'package:storage/storage.dart';

import 'app_config.dart';
import 'app_controller.dart';
import 'auth/email_password_credential.dart';
import 'auth/reference_auth_backend.dart';
import 'auth/secure_session_store.dart';
import 'auth/session_network_bridge.dart';
import 'launch_counter_repository.dart';
import 'routing/app_router.dart';

final class AppComposition {
  AppComposition._({
    required this.config,
    required this.networkClient,
    required this.controller,
    required this.sessionManager,
    required this.signIn,
    required this.signOut,
    required this.appRouter,
  });

  factory AppComposition.create() {
    final config = AppConfig.local();
    final backend = ReferenceAuthBackend(configuration: config.authBackend);
    return AppComposition._assemble(
      config: config,
      preferences: SharedPreferencesStore.create(),
      sessionStore: SecureSessionStore(
        secureStore: FlutterSecureStringStore.create(),
        storageKey: config.sessionStorageKey,
      ),
      authGateway: ReferenceEmailPasswordAuthGateway(backend),
      sessionGateway: ReferenceSessionGateway(backend),
    );
  }

  factory AppComposition.forTest({
    required AppConfig config,
    required KeyValueStore preferences,
    required SessionStore sessionStore,
    required AuthGateway<EmailPasswordCredential> authGateway,
    required SessionGateway sessionGateway,
    String? initialLocation,
  }) => AppComposition._assemble(
    config: config,
    preferences: preferences,
    sessionStore: sessionStore,
    authGateway: authGateway,
    sessionGateway: sessionGateway,
    initialLocation: initialLocation,
  );

  factory AppComposition._assemble({
    required AppConfig config,
    required KeyValueStore preferences,
    required SessionStore sessionStore,
    required AuthGateway<EmailPasswordCredential> authGateway,
    required SessionGateway sessionGateway,
    String? initialLocation,
  }) {
    const logger = NullLogger();
    final sessionManager = SessionManager(
      store: sessionStore,
      gateway: sessionGateway,
      logger: logger,
    );
    final signIn = BoundSignIn<EmailPasswordCredential>(
      gateway: authGateway,
      sessionManager: sessionManager,
    );
    final networkClient = DioNetworkClient.create(
      configuration: NetworkConfiguration(baseUri: config.apiBaseUri),
      logger: logger,
      accessTokenProvider: SessionAccessTokenProvider(sessionManager),
      unauthorizedRecovery: SessionUnauthorizedRecovery(sessionManager),
    );
    return AppComposition._(
      config: config,
      networkClient: networkClient,
      controller: AppController(LaunchCounterRepository(preferences)),
      sessionManager: sessionManager,
      signIn: signIn,
      signOut: SessionSignOut(sessionManager),
      appRouter: AppRouter(
        sessionManager: sessionManager,
        initialLocation: initialLocation,
      ),
    );
  }

  final AppConfig config;
  final NetworkClient networkClient;
  final AppController controller;
  final SessionManager sessionManager;
  final SignIn<EmailPasswordCredential> signIn;
  final SignOut signOut;
  final AppRouter appRouter;

  Future<void> dispose() async {
    appRouter.dispose();
    controller.dispose();
    networkClient.close();
    await sessionManager.dispose();
  }
}
