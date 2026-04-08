class UserModel {
  final String id;
  final String firstName;
  final String lastName;
  final String? avatarUrl;
  final String? gender;
  final String? birthday;
  final String? role;
  final String? email;
  final bool pushNotificationEnabled;

  const UserModel({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.avatarUrl,
    this.gender,
    this.birthday,
    this.role,
    this.email,
    this.pushNotificationEnabled = true,
  });

  String get fullName => '$lastName $firstName'.trim();

  /// gender API: "male" / "female" / "other"
  String get genderLabel {
    switch (gender) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      case 'other':
        return 'Khác';
      default:
        return '';
    }
  }

  /// Reverse: "Nam" → "male", "Nữ" → "female", "Khác" → "other"
  static String genderToApi(String label) {
    switch (label) {
      case 'Nam':
        return 'male';
      case 'Nữ':
        return 'female';
      case 'Khác':
        return 'other';
      default:
        return 'other';
    }
  }

  DateTime? get birthdayDate {
    if (birthday == null) return null;
    return DateTime.tryParse(birthday!);
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      firstName: json['first_name']?.toString() ?? '',
      lastName: json['last_name']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString(),
      gender: json['gender']?.toString(),
      birthday: json['birthday']?.toString(),
      role: json['role']?.toString(),
      email: json['email']?.toString(),
      pushNotificationEnabled: json['push_notification_enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'avatar_url': avatarUrl,
      'gender': gender,
      'birthday': birthday,
      'role': role,
      'email': email,
      'push_notification_enabled': pushNotificationEnabled,
    };
  }
}
