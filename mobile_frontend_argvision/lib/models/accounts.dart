class User {
  final int id;
  final String? email;
  final String? phone;
  final String username;
  final String firstName;
  final String lastName;
  final DateTime? birthdate;
  final String? gender;
  final String? picture;
  final int matches;
  final int wins;
  final int losses;
  final int score;
  final DateTime dateJoined;
  final DateTime? lastLogin;
  final String role;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final bool archived;

  User({
    required this.id,
    this.email,
    this.phone,
    required this.username,
    required this.firstName,
    required this.lastName,
    this.birthdate,
    this.gender,
    this.picture,
    required this.matches,
    required this.wins,
    required this.losses,
    required this.score,
    required this.dateJoined,
    this.lastLogin,
    required this.role,
    required this.isActive,
    required this.isStaff,
    required this.isSuperuser,
    required this.archived,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      phone: json['phone'],
      username: json['username'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      birthdate: json['birthdate'] != null ? DateTime.parse(json['birthdate']) : null,
      gender: json['gender'],
      picture: json['picture'],
      matches: json['matches'] ?? 0,
      wins: json['wins'] ?? 0,
      losses: json['losses'] ?? 0,
      score: json['score'] ?? 0,
      dateJoined: DateTime.parse(json['date_joined']),
      lastLogin: json['last_login'] != null ? DateTime.parse(json['last_login']) : null,
      role: json['role'] ?? 'Player',
      isActive: json['is_active'] ?? true,
      isStaff: json['is_staff'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
      archived: json['archived'] ?? false,
    );
  }

  String get fullName => '$firstName $lastName';

  String get genderDisplay {
    switch (gender) {
      case 'M':
        return 'Male';
      case 'F':
        return 'Female';
      case 'P':
        return 'Prefer not to say';
      default:
        return 'Unknown';
    }
  }

  String get roleDisplay {
    switch (role) {
      case 'Admin':
        return 'Administrator';
      case 'Player':
        return 'Player';
      case 'Owner':
        return 'Owner';
      default:
        return role;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'phone': phone,
      'username': username,
      'first_name': firstName,
      'last_name': lastName,
      'birthdate': birthdate?.toIso8601String(),
      'gender': gender,
      'picture': picture,
      'matches': matches,
      'wins': wins,
      'losses': losses,
      'score': score,
      'date_joined': dateJoined.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
      'role': role,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      'archived': archived,
    };
  }
}