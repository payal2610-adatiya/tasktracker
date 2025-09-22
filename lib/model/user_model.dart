class User
{
  int? id;
  String username;
  String password;
  User({this.id, required this.username, required this.password});
  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'username': username,
    'password': password,
  };

  factory User.fromMap(Map<String, dynamic> m) => User(
    id: m['id'] as int?,
    username: m['username'] ?? '',
    password: m['password'] ?? '',
  );

}