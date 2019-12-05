import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import '../auth.dart';
import '../authentications/bloc.dart';
import '../authentications/authentication_state.dart';
import '../authentications/authentication_event.dart';
import 'package:chatapp/auth.dart';

class AuthenticationBloc
    extends Bloc<AuthenticationEvent, AuthenticationState> {

  final BaseAuth _auth;

  AuthenticationBloc({@required Auth auth})
      : assert(auth != null),
        _auth = auth;

  @override
  AuthenticationState get initialState => Uninitialized();

  @override
  Stream<AuthenticationState> mapEventToState(
      AuthenticationEvent event,
      ) async* {
    if (event is AppStarted) {
      yield* _mapAppStartedToState();
    } else if (event is LoggedIn) {
      yield* _mapLoggedInToState();
    } else if (event is LoggedOut) {
      yield* _mapLoggedOutToState();
    }
  }

  Stream<AuthenticationState> _mapAppStartedToState() async* {
    try {
      final isSignedIn = await _auth.isSignedIn();
      if (isSignedIn) {
        final id = await _auth.currentUser();
        final fulna = await _auth.getUserFullname();
        final coverpicture = await _auth.getcoverpicture();
        final userProfile = await _auth.firestoreUser();
        yield Authenticated(id, fulna, coverpicture, userProfile);
      } else {
        yield Unauthenticated();
      }
    } catch (_) {
      yield Unauthenticated();
    }
  }

  Stream<AuthenticationState> _mapLoggedInToState() async* {
    yield Authenticated(await _auth.currentUser(), await _auth.getUserFullname(), await _auth.getcoverpicture(), await _auth.firestoreUser());
  }

  Stream<AuthenticationState> _mapLoggedOutToState() async* {
    yield Unauthenticated();
    _auth.signOut();
  }
}