import 'package:flutter_app/app/events/login_event.dart';
import 'package:flutter_app/app/events/logout_event.dart';
import 'package:nylo_framework/nylo_framework.dart';

final Map<Type, NyEvent> events = {
  LoginEvent: LoginEvent(),
  LogoutEvent: LogoutEvent(),
};
