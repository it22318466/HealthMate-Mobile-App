class UserAccount {
  UserAccount({
    this.id,
    required this.fullName,
    required this.email,
    required this.passwordHash,
  });

  final int? id;
  final String fullName;
  final String email;
  final String passwordHash;

  factory UserAccount.fromMap(Map<String, dynamic> map) {
    return UserAccount(
      id: map['id'] as int?,
      fullName: map['fullName'] as String,
      email: map['email'] as String,
      passwordHash: map['passwordHash'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'passwordHash': passwordHash,
    };
  }

  UserAccount copyWith({
    int? id,
    String? fullName,
    String? email,
    String? passwordHash,
  }) {
    return UserAccount(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
    );
  }
}
