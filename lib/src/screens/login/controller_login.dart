part of login;

class _LoginController with AppLogger {
  _LoginController._(this.api, this.storage, {MsalService? msal}) : msal = msal ?? MsalService();

  final StorageService storage;
  final AzureApiService api;
  final MsalService msal;

  final formFieldKey = GlobalKey<FormFieldState<dynamic>>();

  String pat = '';

  // ignore: use_setters_to_change_properties
  void setPat(String value) {
    pat = value;
  }

  Future<void> loginWithMicrosoft() async {
    try {
      final loginRes = await msal.login();
      if (loginRes == null) return;

      await _loginAndNavigate(loginRes, isPat: false);
    } catch (e) {
      _showLoginErrorAlert(description: e.toString());
    }
  }

  Future<void> login() async {
    final isValid = formFieldKey.currentState!.validate();
    if (!isValid) return;

    await _loginAndNavigate(LoginResponse(accessToken: pat, tenantId: ''), isPat: true);
  }

  Future<void> _loginAndNavigate(LoginResponse loginResponse, {required bool isPat}) async {
    final isLogged = await api.login(loginResponse.accessToken);

    if (isLogged == LoginStatus.failed) {
      _showLoginErrorAlert();
      return;
    }

    if (isLogged == LoginStatus.unauthorized) {
      final hasSetOrg = await _setOrgManually();
      if (!hasSetOrg) return;

      final isLoggedManually = await api.login(isPat ? pat : loginResponse.accessToken);
      if (isLoggedManually == LoginStatus.failed) {
        _showLoginErrorAlert();
        return;
      } else if (isLoggedManually == LoginStatus.unauthorized) {
        _showLoginErrorAlert();
        return;
      }
    }

    storage.setTenantId(loginResponse.tenantId);

    await AppRouter.goToChooseProjects();
  }

  void showInfo() {
    OverlayService.error(
      'Info',
      description:
          'Your PAT is stored on your device and is only used as an http header to communicate with Azure API, '
          "it's not stored anywhere else.\n\n"
          "Check that your PAT has 'User Profile' read enabled, otherwise it won't work.",
    );
  }

  void _showLoginErrorAlert({String? description}) {
    OverlayService.error('Login error', description: description ?? 'Check that your PAT is correct and retry');
  }

  Future<bool> _setOrgManually() async {
    var hasSetOrg = false;

    String? manualOrg;
    await OverlayService.bottomsheet(
      title: 'Insert your organization',
      isScrollControlled: true,
      builder: (context) => Column(
        children: [
          DevOpsFormField(
            label: 'Organization',
            onChanged: (s) => manualOrg = s,
            onFieldSubmitted: () {
              hasSetOrg = true;
              AppRouter.pop();
            },
            maxLines: 1,
          ),
          const SizedBox(height: 40),
          LoadingButton(
            onPressed: () {
              hasSetOrg = true;
              AppRouter.pop();
            },
            text: 'Confirm',
          ),
        ],
      ),
    );

    if (!hasSetOrg) return false;
    if (manualOrg == null || manualOrg!.isEmpty) return false;

    await api.setOrganization(manualOrg!);

    return true;
  }

  void openPurplesoftWebsite(FollowLink? link) {
    logInfo('Open Purplesoft website');

    link?.call();
  }
}
