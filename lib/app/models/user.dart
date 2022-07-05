import 'package:nylo_framework/nylo_framework.dart';

class User extends Storable {
  String? userId;
  String? token;

  User();
  User.fromUserAuthResponse({this.userId, this.token});

  @override
  toStorage() => {"token": token, "user_id": userId};

  @override
  fromStorage(dynamic data) {
    token = data['token'];
    userId = data['user_id'];
  }
}
