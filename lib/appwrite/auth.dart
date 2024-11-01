import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart';
import 'package:flutter/widgets.dart';

const String APPWRITE_PROJECT_ID = "6719118a002fcf2e7c4d";
const String APPWRITE_URL = "https://cloud.appwrite.io/v1";

enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
}

class AuthAPI extends ChangeNotifier {
  Client client = Client();
  late final Account account;

  late User _currentUser;

  AuthStatus _status = AuthStatus.uninitialized;

  // Getter methods
  User get currentUser => _currentUser;
  AuthStatus get status => _status;
  String? get username => _currentUser?.name;
  String? get email => _currentUser?.email;
  String? get userid => _currentUser?.$id;

  // Constructor
  AuthAPI() {
    init();
    loadUser();
  }

  // Initialize the Appwrite client
  init() {
    client
        .setEndpoint(APPWRITE_URL)
        .setProject(APPWRITE_PROJECT_ID)
        .setSelfSigned();
    account = Account(client);
  }

  loadUser() async {
    try {
      final user = await account.get();
      _status = AuthStatus.authenticated;
      _currentUser = user;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  // create OTP
  Future<Token> createPhoneToken({required String phoneNo}) async {
    try {
      final token =
          await account.createPhoneToken(userId: ID.unique(), phone: phoneNo);
      return token;
    } finally {
      notifyListeners();
    }
  }

  // create phone session
  Future<Session> createPhoneSession(
      {required String userId, required String otp}) async {
    try {
      final session = await account.createSession(userId: userId, secret: otp);
      _currentUser = await account.get();
      _status = AuthStatus.authenticated;
      return session;
    } finally {
      notifyListeners();
    }
  }

  // sign out
  signOut() async {
    try {
      await account.deleteSession(sessionId: 'current');
      _status = AuthStatus.unauthenticated;
    } finally {
      notifyListeners();
    }
  }

  // > Perfs methods
  // get user Perfs
  Future<Preferences> getUserPreferences() async {
    return await account.getPrefs();
  }

  // update user Perfs
  updatePreferences({required String bio}) async {
    return account.updatePrefs(prefs: {'bio': bio});
  }

  isuserOnboarded() async {
    final prefs = await getUserPreferences();
    return prefs.data['onboarded'] ?? false;
  }

  onboardUser() async {
    return account.updatePrefs(prefs: {'onboarded': true});
  }
  //
}
