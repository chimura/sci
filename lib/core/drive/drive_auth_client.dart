import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

/// An HTTP client that injects the Google access token into every request.
/// Used to authenticate Google Drive API calls.
class DriveAuthClient extends http.BaseClient {
  final http.Client _inner;

  DriveAuthClient({http.Client? inner}) : _inner = inner ?? http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final account = await _getAccount();
    if (account != null) {
      final authClient = account.authorizationClient;
      final authorization = await authClient.authorizationForScopes([
        'https://www.googleapis.com/auth/drive.file',
      ]);
      if (authorization != null) {
        request.headers['Authorization'] =
            'Bearer ${authorization.accessToken}';
      }
    }
    return _inner.send(request);
  }

  Future<GoogleSignInAccount?> _getAccount() async {
    final googleSignIn = GoogleSignIn.instance;
    return googleSignIn.attemptLightweightAuthentication();
  }

  @override
  void close() {
    _inner.close();
    super.close();
  }
}
