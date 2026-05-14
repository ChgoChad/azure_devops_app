import 'package:azure_devops/src/mixins/logger_mixin.dart';
import 'package:msal_auth/msal_auth.dart';

class MsalService with AppLogger {
  factory MsalService() {
    return instance ??= MsalService._();
  }

  MsalService._();

  static MsalService? instance;

  static const _scopes = ['499b84ac-1321-427f-aa17-267ca6975798/user_impersonation'];

  SingleAccountPca? _pca;

  void dispose() {
    instance = null;
  }

  Future<void> init() async {
    setTag('MsalService');

    var msalClientId = const String.fromEnvironment('MSAL_CLIENT_ID');
    var msalRedirectUri = const String.fromEnvironment('MSAL_REDIRECT_URI');

    if (msalClientId.isEmpty || msalRedirectUri.isEmpty) {
      // Fallback for local development if not provided via --dart-define
      msalClientId = 'fc3f2dc9-260a-4157-8d55-3a0e932df8d4';
      msalRedirectUri = 'msauth://io.purplesoft.azuredevops/QG8o4quMfqXiTsA9PMn9DbcPBVo%3D';

      logDebug('MSAL environment variables missing. Using default fallback values.');
    }

    logDebug('MSAL Config: ID: $msalClientId, URI: $msalRedirectUri');

    try {
      logDebug('Initializing MSAL PCA...');
      _pca = await SingleAccountPca.create(
        clientId: msalClientId,
        androidConfig: AndroidConfig(configFilePath: 'assets/msal_config.json', redirectUri: msalRedirectUri),
        appleConfig: AppleConfig(),
      );
      logDebug('MSAL PCA initialized successfully.');
    } catch (e, s) {
      logError('MSAL PCA initialization failed: $e', s);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      if (_pca == null) await init();

      await _pca!.signOut();
    } catch (_) {
      // ignore
    }
  }

  Future<LoginResponse?> login({String? authority}) async {
    try {
      if (_pca == null) await init();

      final token = await _pca!.acquireToken(scopes: _scopes, prompt: Prompt.selectAccount, authority: authority);
      return LoginResponse(accessToken: token.accessToken, tenantId: token.tenantId ?? '');
    } on MsalUserCancelException catch (_) {
      return null;
    } catch (e, s) {
      logError(e, s);
      rethrow;
    }
  }

  Future<String?> loginSilently({String? authority}) async {
    try {
      if (_pca == null) await init();

      final token = await _pca!.acquireTokenSilent(scopes: _scopes, authority: authority);
      return token.accessToken;
    } on MsalException catch (e, s) {
      logError(e, s);
      return null;
    }
  }
}

class LoginResponse {
  LoginResponse({required this.accessToken, required this.tenantId});

  final String accessToken;
  final String tenantId;
}
