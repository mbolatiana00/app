sealed class Failure {
  final String message;
  const Failure(this.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Pas de connexion']);
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Erreur du serveur']);
}

class UnAuthorizeFailure extends Failure {
  const UnAuthorizeFailure([super.message = 'Session expiree']);
}
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}
class PaymentTimeoutFailure extends Failure {
  const PaymentTimeoutFailure(
      [super.message =
          'Paiement non confirmé. Vérifiez votre téléphone, puis réessayez de vérifier.']);
}