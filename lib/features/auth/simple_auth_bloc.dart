import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:whatbytes_assignment/core/logger.dart';
import 'auth_service.dart';

// Events
abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;
  final String? displayName;

  AuthSignUpRequested({
    required this.email,
    required this.password,
    this.displayName,
  });
}

class AuthSignInRequested extends AuthEvent {
  final String email;
  final String password;

  AuthSignInRequested({
    required this.email,
    required this.password,
  });
}

class AuthSignOutRequested extends AuthEvent {}

class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  AuthPasswordResetRequested({required this.email});
}

class AuthUserChanged extends AuthEvent {
  final User? user;

  AuthUserChanged(this.user);
}

// States
abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);
}

class AuthPasswordResetSent extends AuthState {
  final String email;

  const AuthPasswordResetSent(this.email);
}

// BLoC
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthService _authService;

  AuthBloc(this._authService) : super(AuthInitial()) {
    // Listen to auth state changes
    _authService.authStateChanges.listen((user) {
      add(AuthUserChanged(user));
    });

    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthSignUpRequested>(_onAuthSignUpRequested);
    on<AuthSignInRequested>(_onAuthSignInRequested);
    on<AuthSignOutRequested>(_onAuthSignOutRequested);
    on<AuthPasswordResetRequested>(_onAuthPasswordResetRequested);
    on<AuthUserChanged>(_onAuthUserChanged);
  }

  void _onAuthCheckRequested(AuthCheckRequested event, Emitter<AuthState> emit) {
    AppLogger.info('AuthBloc: Checking authentication status');
    final user = _authService.currentUser;
    if (user != null) {
      AppLogger.info('AuthBloc: User is authenticated: ${user.uid}');
      emit(AuthAuthenticated(user));
    } else {
      AppLogger.info('AuthBloc: User is not authenticated');
      emit(AuthUnauthenticated());
    }
  }

  void _onAuthUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    AppLogger.info('AuthBloc: Auth state changed, user: ${event.user?.uid}');
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('AuthBloc: Sign up requested for: ${event.email}');
    emit(AuthLoading());
    
    try {
      final user = await _authService.signUpWithEmailPassword(
        email: event.email,
        password: event.password,
        displayName: event.displayName,
      );
      
      if (user != null) {
        AppLogger.info('AuthBloc: Sign up successful: ${user.uid}');
        emit(AuthAuthenticated(user));
      } else {
        AppLogger.info('AuthBloc: Sign up failed - no user returned');
        emit(const AuthError('Sign up failed'));
      }
    } catch (e) {
      AppLogger.error('AuthBloc: Sign up error - $e');
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAuthSignInRequested(
    AuthSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('AuthBloc: Sign in requested for: ${event.email}');
    emit(AuthLoading());
    
    try {
      final user = await _authService.signInWithEmailPassword(
        email: event.email,
        password: event.password,
      );
      
      if (user != null) {
        AppLogger.info('AuthBloc: Sign in successful: ${user.uid}');
        emit(AuthAuthenticated(user));
      } else {
        AppLogger.info('AuthBloc: Sign in failed - no user returned');
        emit(const AuthError('Sign in failed'));
      }
    } catch (e) {
      AppLogger.error('AuthBloc: Sign in error - $e');
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAuthSignOutRequested(
    AuthSignOutRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('AuthBloc: Sign out requested');
    emit(AuthLoading());
    
    try {
      await _authService.signOut();
      AppLogger.info('AuthBloc: Sign out successful');
      emit(AuthUnauthenticated());
    } catch (e) {
      AppLogger.error('AuthBloc: Sign out error - $e');
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }

  Future<void> _onAuthPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    AppLogger.info('AuthBloc: Password reset requested for: ${event.email}');
    emit(AuthLoading());
    
    try {
      await _authService.resetPassword(email: event.email);
      AppLogger.info('AuthBloc: Password reset email sent');
      emit(AuthPasswordResetSent(event.email));
    } catch (e) {
      AppLogger.error('AuthBloc: Password reset error - $e');
      emit(AuthError(e.toString().replaceFirst('Exception: ', '')));
    }
  }
}
