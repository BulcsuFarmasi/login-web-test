import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:oidc/oidc.dart';
import 'package:oidc_default_store/oidc_default_store.dart';

class AuthService {
  late OidcUserManager currentManager;

  final currentManagerInitedCompleter = Completer();

  Stream<OidcUser?> get userChanges => currentManager.userChanges();

  AuthService() {
    initService();
  }

  Future<void> initService() async {
    currentManager = OidcUserManager.lazy(
      discoveryDocumentUri: OidcUtils.getOpenIdConfigWellKnownUri(
        Uri.parse('https://gge.onelogin.com/oidc/2'),
      ),
      clientCredentials: const OidcClientAuthentication.none(
        clientId: '8383da30-9819-013c-943b-0aa5277bc13437592',
      ),
      store: OidcDefaultStore(
          // useSessionStorageForSessionNamespaceOnWeb: true,
          ),

      // keyStore: JsonWebKeyStore(),
      settings: OidcUserManagerSettings(
        frontChannelLogoutUri: Uri(path: 'redirect.html'),
        uiLocales: ['en'],
        refreshBefore: (token) {
          return const Duration(seconds: 1);
        },
        options: const OidcPlatformSpecificOptions(
            web: OidcPlatformSpecificOptions_Web(
                //navigationMode: OidcPlatformSpecificOptions_Web_NavigationMode.samePage
                navigationMode:
                    OidcPlatformSpecificOptions_Web_NavigationMode.newPage)),
        // scopes supported by the provider and needed by the client.
        scope: ['openid', 'profile', 'email'],
        postLogoutRedirectUri: kIsWeb
            ? Uri.parse('http://localhost:22433/redirect.html')
            : Platform.isAndroid || Platform.isIOS || Platform.isMacOS
                ? Uri.parse('com.ggeedu.onespace:/endsessionredirect')
                : Platform.isWindows || Platform.isLinux
                    ? Uri.parse('http://localhost:0')
                    : null,
        redirectUri: kIsWeb
            // this url must be an actual html page.
            // see the file in /web/redirect.html for an example.
            //
            // for debugging in flutter, you must run this app with --web-port 22433
            ? Uri.parse('http://localhost:22433/redirect.html')
            : Platform.isIOS || Platform.isMacOS || Platform.isAndroid
                // scheme: reverse domain name notation of your package name.
                // path: anything.
                ? Uri.parse('com.ggeedu.onespace:/oauth2redirect')
                : Platform.isWindows || Platform.isLinux
                    // using port 0 means that we don't care which port is used,
                    // and a random unused port will be assigned.
                    //
                    // this is safer than passing a port yourself.
                    //
                    // note that you can also pass a path like /redirect,
                    // but it's completely optional.
                    ? Uri.parse('http://localhost:0')
                    : Uri(),
      ),
    );
    await currentManager.init();
    currentManagerInitedCompleter.complete();
  }

  Future<void> authenticate() async {
    await currentManagerInitedCompleter.future;

    await currentManager.loginAuthorizationCodeFlow();
  }

  Future<void> logOut() async {
    await currentManager.logout();
  }
}
