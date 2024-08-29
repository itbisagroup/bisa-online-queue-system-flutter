class AppExceptions implements Exception {
  final dynamic message;
  final dynamic prefix;

  AppExceptions([this.message, this.prefix]);

  @override
  String toString() {
    return '$prefix$message';
  }
}

class InternetException extends AppExceptions {
  InternetException([String? message]) : super(message, 'No Internet');
}

class RequestTimeOut extends AppExceptions {
  RequestTimeOut([String? message]) : super(message, 'Request Timed Out');
}

class ServerException extends AppExceptions {
  ServerException([String? message]) : super(message, 'Internal Server Error');
}

class InvalidUrlException extends AppExceptions {
  InvalidUrlException([String? message]) : super(message, '');
}

class UnautorizedException extends AppExceptions {
  UnautorizedException([String? message]) : super(message, 'Unauthorized');
}

class ForbidenException extends AppExceptions {
  ForbidenException([String? message]) : super(message, 'Forbidden');
}
class BadGateway extends AppExceptions {
  BadGateway([String? message]) : super(message, 'Bad Gateway');
}
class ToManyRequest extends AppExceptions {
  ToManyRequest([String? message]) : super(message, 'To Many Request');
}

class FetchDataException extends AppExceptions {
  FetchDataException([String? message]) : super(message, '');
}
