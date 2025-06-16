sealed class AuthFailure {
  const AuthFailure();
}

class AuthFailureEmailAlreadyInUse extends AuthFailure {
  const AuthFailureEmailAlreadyInUse();
}

class AuthFailureWeakPassword extends AuthFailure {
  const AuthFailureWeakPassword();
}

class AuthFailureUserNotFound extends AuthFailure {
  const AuthFailureUserNotFound();
}

class AuthFailureWrongPassword extends AuthFailure {
  const AuthFailureWrongPassword();
}

class AuthFailureInvalidEmail extends AuthFailure {
  const AuthFailureInvalidEmail();
}

class AuthFailureOperationNotAllowed extends AuthFailure {
  const AuthFailureOperationNotAllowed();
}

class AuthFailureUserDisabled extends AuthFailure {
  const AuthFailureUserDisabled();
}

class AuthFailureTooManyRequests extends AuthFailure {
  const AuthFailureTooManyRequests();
}

class AuthFailureGoogleSignInCancelled extends AuthFailure {
  const AuthFailureGoogleSignInCancelled();
}

class AuthFailureUnknown extends AuthFailure {
  final String message;
  const AuthFailureUnknown(this.message);
}


