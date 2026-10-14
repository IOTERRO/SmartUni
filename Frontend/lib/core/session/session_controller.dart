import 'package:flutter/foundation.dart';

import '../enums/user_role.dart';
import '../models/app_user.dart';

/// In-memory session for Step 1 (design preview).
/// Later: persist with SharedPreferences / secure storage + real auth API.
class SessionController extends ChangeNotifier {
  SessionController._();

  static final SessionController instance = SessionController._();

  AppUser? _user;

  AppUser? get user => _user;

  bool get isAuthenticated =>
      _user != null && _user!.role != UserRole.guest;

  UserRole? get role => _user?.role;

  void setUser(AppUser user) {
    _user = user;
    notifyListeners();
  }

  void continueAsGuest() {
    _user = AppUser.guest();
    notifyListeners();
  }

  void clear() {
    _user = null;
    notifyListeners();
  }
}
