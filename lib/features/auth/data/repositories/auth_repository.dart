import '../../../../core/utils/password_hasher.dart';
import '../datasources/auth_dao.dart';
import '../models/user_account.dart';

class AuthRepository {
  AuthRepository({AuthDao? dao}) : _dao = dao ?? AuthDao();

  final AuthDao _dao;

  Future<UserAccount?> login(String email, String password) async {
    final user = await _dao.getUserByEmail(email);
    if (user == null) return null;
    final hash = PasswordHasher.hash(password);
    if (user.passwordHash != hash) return null;
    return user;
  }

  Future<UserAccount> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final existing = await _dao.getUserByEmail(email);
    if (existing != null) {
      throw ArgumentError('Email already registered.');
    }

    final user = UserAccount(
      fullName: fullName.trim(),
      email: email.trim(),
      passwordHash: PasswordHasher.hash(password),
    );
    final id = await _dao.insertUser(user);
    return user.copyWith(id: id);
  }
}
