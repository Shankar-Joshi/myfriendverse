import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../models/user.dart';

@immutable
abstract class AuthenticationState extends Equatable {
  AuthenticationState([List props = const []]) : super(props);
}

class Uninitialized extends AuthenticationState {
  @override
  String toString() => 'Uninitialized';
}

class Authenticated extends AuthenticationState {
  final String id;
  final String fulnaaa;
  final String coverpicture;
  final User user;

  Authenticated(this.id, this.fulnaaa, this.coverpicture, this.user) : super([id, fulnaaa, coverpicture, user]);

  @override
  String toString() => 'Authenticated';
}

class Unauthenticated extends AuthenticationState {
  @override
  String toString() => 'Unauthenticated';
}