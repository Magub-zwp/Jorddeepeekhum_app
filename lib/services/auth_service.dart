import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  User? currentUser;
  final apiService = ApiService();

  // Login
  Future<bool> login(String email, String password) async {
    try {
      final user = await apiService.loginUser(email, password);
      currentUser = user;
      print('✅ Login successful: User ID = ${user.id} (int)');
      return true;
    } catch (e) {
      print('❌ Login failed: $e');
      return false;
    }
  }

  // Register
  Future<bool> register(String username, String email, String phone, String password) async {
    try {
      final user = await apiService.registerUser(username, email, phone, password);
      currentUser = user;
      print('✅ Register successful: User ID = ${user.id} (int)');
      return true;
    } catch (e) {
      print('❌ Register failed: $e');
      return false;
    }
  }

  // Logout
  void logout() {
    currentUser = null;
    print('✅ User logged out');
  }

  // Check if logged in
  bool get isLoggedIn => currentUser != null;
}
