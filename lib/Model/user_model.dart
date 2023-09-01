

class User {
  String username;
  String password;
  String bolum;

  User({
    required this.username,
    required this.password,
    required this.bolum,
  });

  // JSON nesnesine dönüştürme metodu
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'bolum': bolum,
    };
  }

  // JSON dizesinden User nesnesi oluşturma metodu
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      username: json['username'],
      password: json['password'],
      bolum: json['bolum'],
    );
  }
}
