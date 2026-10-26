import 'package:flutter_forge/flutter_forge.dart';

/// A sentence for the user that explains [error].
String errorMessage(Object error) => switch (error) {
  ConnectionException() =>
    'You appear to be offline. Check your connection and try again.',
  RequestTimeoutException() => 'The server took too long to answer.',
  RequestCancelledException() => 'The request was cancelled.',
  HttpStatusException(statusCode: 401 || 403) =>
    'You are not allowed to see this. Sign in and try again.',
  HttpStatusException(statusCode: 404) => 'This could not be found.',
  HttpStatusException(:final statusCode) when statusCode >= 500 =>
    'The server had a problem. Try again later.',
  HttpStatusException(:final statusCode) =>
    'The server answered with status $statusCode.',
  DecodingException() => 'The server sent data this app cannot read.',
  ResponseTooLargeException() => 'The answer from the server was too large.',
  RedirectException() => 'The server sent the request to an unsafe address.',
  _ => 'Something went wrong. Try again.',
};
