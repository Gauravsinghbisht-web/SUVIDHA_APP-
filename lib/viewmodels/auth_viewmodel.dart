
import 'package:flutter/foundation.dart';

class AuthViewModel extends ChangeNotifier {
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  void login() {
    _isLoading = true;
    notifyListeners();

    // Firebase login will be added later.

    _isLoading = false;
    notifyListeners();
  }
}