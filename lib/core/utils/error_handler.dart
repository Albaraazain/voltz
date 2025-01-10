import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Custom exception class for app-specific errors
class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  AppException(
    this.message, {
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  String toString() =>
      'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Enum defining different types of errors
enum ErrorType {
  network,
  authentication,
  authorization,
  validation,
  notFound,
  server,
  unknown,
}

/// Class containing error messages
class ErrorMessages {
  static const String networkError =
      'Network connection error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String authenticationError =
      'Authentication error. Please log in again.';
  static const String authorizationError =
      'You are not authorized to perform this action.';
  static const String validationError =
      'Invalid input. Please check your data.';
  static const String notFoundError = 'The requested resource was not found.';
  static const String unknownError =
      'An unexpected error occurred. Please try again.';
}

/// Main error handler class
class ErrorHandler {
  /// Handles various types of errors and converts them to AppException
  static AppException handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is AppException) {
      return error;
    }

    if (error is SocketException || error is TimeoutException) {
      return AppException(
        ErrorMessages.networkError,
        code: 'NETWORK_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is AuthException) {
      return AppException(
        ErrorMessages.authenticationError,
        code: 'AUTH_ERROR',
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is PostgrestException) {
      if (error.code == 'PGRST301') {
        return AppException(
          ErrorMessages.authorizationError,
          code: 'AUTHORIZATION_ERROR',
          originalError: error,
          stackTrace: stackTrace,
        );
      }
      return AppException(
        ErrorMessages.serverError,
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    if (error is PlatformException) {
      return AppException(
        error.message ?? ErrorMessages.unknownError,
        code: error.code,
        originalError: error,
        stackTrace: stackTrace,
      );
    }

    return AppException(
      ErrorMessages.unknownError,
      originalError: error,
      stackTrace: stackTrace,
    );
  }

  /// Gets the error type based on the exception
  static ErrorType getErrorType(AppException error) {
    if (error.code != null) {
      switch (error.code) {
        case 'NETWORK_ERROR':
          return ErrorType.network;
        case 'AUTH_ERROR':
          return ErrorType.authentication;
        case 'AUTHORIZATION_ERROR':
          return ErrorType.authorization;
        case 'VALIDATION_ERROR':
          return ErrorType.validation;
        case 'NOT_FOUND':
          return ErrorType.notFound;
      }
    }

    if (error.originalError is SocketException ||
        error.originalError is TimeoutException) {
      return ErrorType.network;
    }

    if (error.originalError is AuthException) {
      return ErrorType.authentication;
    }

    if (error.originalError is PostgrestException) {
      return ErrorType.server;
    }

    return ErrorType.unknown;
  }

  /// Gets a user-friendly error message based on the error type
  static String getUserFriendlyMessage(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return ErrorMessages.networkError;
      case ErrorType.authentication:
        return ErrorMessages.authenticationError;
      case ErrorType.authorization:
        return ErrorMessages.authorizationError;
      case ErrorType.validation:
        return ErrorMessages.validationError;
      case ErrorType.notFound:
        return ErrorMessages.notFoundError;
      case ErrorType.server:
        return ErrorMessages.serverError;
      case ErrorType.unknown:
        return ErrorMessages.unknownError;
    }
  }

  /// Handles an error and returns a user-friendly message
  static String getErrorMessage(dynamic error) {
    final appException = handleError(error);
    final errorType = getErrorType(appException);
    return getUserFriendlyMessage(errorType);
  }

  /// Async error handler that can be used with Future operations
  static Future<T> handleFutureError<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (error, stackTrace) {
      throw handleError(error, stackTrace);
    }
  }
}
