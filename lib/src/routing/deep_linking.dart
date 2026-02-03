/// Deep linking and universal links handling.
///
/// Provides utilities for handling deep links, app links,
/// and universal links in the application.
library;

import 'dart:async';

/// Deep link configuration.
class DeepLinkConfig {
  /// Creates a new [DeepLinkConfig].
  const DeepLinkConfig({
    required this.scheme,
    required this.host,
    this.pathPatterns = const [],
  });

  /// URL scheme (e.g., 'myapp').
  final String scheme;

  /// Host (e.g., 'example.com').
  final String host;

  /// Path patterns to handle.
  final List<PathPattern> pathPatterns;

  /// Checks if a URI matches this configuration.
  bool matches(Uri uri) {
    return uri.scheme == scheme || uri.host == host;
  }
}

/// Path pattern for deep link matching.
class PathPattern {
  /// Creates a new [PathPattern].
  const PathPattern({
    required this.pattern,
    required this.route,
    this.parameterMapping = const {},
  });

  /// The path pattern (e.g., '/product/:id').
  final String pattern;

  /// The app route to navigate to.
  final String route;

  /// Maps URL parameters to route parameters.
  final Map<String, String> parameterMapping;

  /// Checks if a path matches this pattern.
  bool matches(String path) {
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');

    if (patternParts.length != pathParts.length) return false;

    for (var i = 0; i < patternParts.length; i++) {
      final patternPart = patternParts[i];
      if (patternPart.startsWith(':')) continue;
      if (patternPart != pathParts[i]) return false;
    }

    return true;
  }

  /// Extracts parameters from a path.
  Map<String, String> extractParams(String path) {
    final params = <String, String>{};
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');

    for (var i = 0; i < patternParts.length && i < pathParts.length; i++) {
      final patternPart = patternParts[i];
      if (patternPart.startsWith(':')) {
        final paramName = patternPart.substring(1);
        final mappedName = parameterMapping[paramName] ?? paramName;
        params[mappedName] = pathParts[i];
      }
    }

    return params;
  }
}

/// Deep link parser and handler.
class DeepLinkHandler {
  /// Creates a new [DeepLinkHandler].
  DeepLinkHandler({
    required this.config,
    this.onNavigate,
    this.onError,
  });

  /// Deep link configuration.
  final DeepLinkConfig config;

  /// Callback for navigation.
  final void Function(String route, Map<String, String> params)? onNavigate;

  /// Callback for errors.
  final void Function(String error)? onError;

  final StreamController<DeepLinkResult> _resultController =
      StreamController.broadcast();

  /// Stream of deep link results.
  Stream<DeepLinkResult> get results => _resultController.stream;

  /// Handles a deep link URI.
  DeepLinkResult? handle(Uri uri) {
    if (!config.matches(uri)) {
      onError?.call('URI does not match configuration: $uri');
      return null;
    }

    for (final pattern in config.pathPatterns) {
      if (pattern.matches(uri.path)) {
        final params = {
          ...pattern.extractParams(uri.path),
          ...uri.queryParameters,
        };

        final result = DeepLinkResult(
          uri: uri,
          route: pattern.route,
          params: params,
        );

        onNavigate?.call(result.route, result.params);
        _resultController.add(result);

        return result;
      }
    }

    onError?.call('No matching pattern for path: ${uri.path}');
    return null;
  }

  /// Handles a deep link string.
  DeepLinkResult? handleString(String link) {
    try {
      final uri = Uri.parse(link);
      return handle(uri);
    } catch (e) {
      onError?.call('Invalid URI: $link');
      return null;
    }
  }

  /// Disposes resources.
  void dispose() {
    _resultController.close();
  }
}

/// Result of deep link handling.
class DeepLinkResult {
  /// Creates a new [DeepLinkResult].
  const DeepLinkResult({
    required this.uri,
    required this.route,
    required this.params,
  });

  /// The original URI.
  final Uri uri;

  /// The matched route.
  final String route;

  /// Extracted parameters.
  final Map<String, String> params;
}

/// Universal link configuration.
class UniversalLinkConfig {
  /// Creates a new [UniversalLinkConfig].
  const UniversalLinkConfig({
    required this.hosts,
    this.pathPrefixes = const [],
  });

  /// Allowed hosts.
  final List<String> hosts;

  /// Path prefixes to handle.
  final List<String> pathPrefixes;

  /// Checks if a URI should be handled.
  bool shouldHandle(Uri uri) {
    if (!hosts.contains(uri.host)) return false;

    if (pathPrefixes.isEmpty) return true;

    return pathPrefixes.any((prefix) => uri.path.startsWith(prefix));
  }
}

/// Link builder for creating deep links.
class DeepLinkBuilder {
  /// Creates a new [DeepLinkBuilder].
  DeepLinkBuilder({
    required this.scheme,
    required this.host,
  });

  /// URL scheme.
  final String scheme;

  /// Host.
  final String host;

  /// Builds a deep link URI.
  Uri build(String path, {Map<String, String>? queryParams}) {
    return Uri(
      scheme: scheme,
      host: host,
      path: path,
      queryParameters: queryParams?.isNotEmpty == true ? queryParams : null,
    );
  }

  /// Builds a deep link string.
  String buildString(String path, {Map<String, String>? queryParams}) {
    return build(path, queryParams: queryParams).toString();
  }
}

/// App link association file generator.
class AppLinksGenerator {
  /// Generates Android assetlinks.json content.
  static Map<String, dynamic> generateAssetLinks({
    required String packageName,
    required String sha256Fingerprint,
  }) {
    return {
      'relation': ['delegate_permission/common.handle_all_urls'],
      'target': {
        'namespace': 'android_app',
        'package_name': packageName,
        'sha256_cert_fingerprints': [sha256Fingerprint],
      },
    };
  }

  /// Generates iOS apple-app-site-association content.
  static Map<String, dynamic> generateAppleAppSiteAssociation({
    required String appId,
    required List<String> paths,
  }) {
    return {
      'applinks': {
        'apps': <String>[],
        'details': [
          {
            'appID': appId,
            'paths': paths,
          },
        ],
      },
    };
  }
}

/// Deep link analytics tracker.
class DeepLinkAnalytics {
  /// Creates a new [DeepLinkAnalytics].
  DeepLinkAnalytics({this.onTrack});

  /// Callback for tracking.
  final void Function(DeepLinkEvent)? onTrack;

  /// Tracks a deep link received event.
  void trackReceived(Uri uri) {
    onTrack?.call(DeepLinkEvent(
      type: DeepLinkEventType.received,
      uri: uri,
      timestamp: DateTime.now(),
    ));
  }

  /// Tracks a deep link handled event.
  void trackHandled(Uri uri, String route) {
    onTrack?.call(DeepLinkEvent(
      type: DeepLinkEventType.handled,
      uri: uri,
      route: route,
      timestamp: DateTime.now(),
    ));
  }

  /// Tracks a deep link error event.
  void trackError(Uri uri, String error) {
    onTrack?.call(DeepLinkEvent(
      type: DeepLinkEventType.error,
      uri: uri,
      error: error,
      timestamp: DateTime.now(),
    ));
  }
}

/// Deep link event types.
enum DeepLinkEventType {
  /// Link received.
  received,

  /// Link handled successfully.
  handled,

  /// Error handling link.
  error,
}

/// Deep link event for analytics.
class DeepLinkEvent {
  /// Creates a new [DeepLinkEvent].
  const DeepLinkEvent({
    required this.type,
    required this.uri,
    required this.timestamp,
    this.route,
    this.error,
  });

  /// Event type.
  final DeepLinkEventType type;

  /// The URI.
  final Uri uri;

  /// Timestamp.
  final DateTime timestamp;

  /// Route navigated to.
  final String? route;

  /// Error message.
  final String? error;
}

/// Pending deep link holder for handling links before app is ready.
class PendingDeepLink {
  static Uri? _pendingLink;

  /// Sets a pending deep link.
  static void set(Uri link) => _pendingLink = link;

  /// Gets and clears the pending deep link.
  static Uri? consume() {
    final link = _pendingLink;
    _pendingLink = null;
    return link;
  }

  /// Checks if there's a pending link.
  static bool get hasPending => _pendingLink != null;
}
