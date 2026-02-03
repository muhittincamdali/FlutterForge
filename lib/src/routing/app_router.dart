/// Application routing configuration using go_router.
///
/// Provides a declarative routing solution with support for
/// deep linking, guards, and navigation observers.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Route names constants.
class RouteNames {
  RouteNames._();

  /// Splash screen route.
  static const String splash = 'splash';

  /// Onboarding route.
  static const String onboarding = 'onboarding';

  /// Login route.
  static const String login = 'login';

  /// Register route.
  static const String register = 'register';

  /// Home route.
  static const String home = 'home';

  /// Settings route.
  static const String settings = 'settings';

  /// Profile route.
  static const String profile = 'profile';

  /// Details route.
  static const String details = 'details';

  /// Error route.
  static const String error = 'error';

  /// Not found route.
  static const String notFound = 'not-found';
}

/// Route paths constants.
class RoutePaths {
  RoutePaths._();

  /// Splash path.
  static const String splash = '/';

  /// Onboarding path.
  static const String onboarding = '/onboarding';

  /// Login path.
  static const String login = '/login';

  /// Register path.
  static const String register = '/register';

  /// Home path.
  static const String home = '/home';

  /// Settings path.
  static const String settings = '/settings';

  /// Profile path.
  static const String profile = '/profile';

  /// Profile with ID.
  static const String profileWithId = '/profile/:id';

  /// Details path.
  static const String details = '/details/:id';

  /// Error path.
  static const String error = '/error';

  /// Not found path.
  static const String notFound = '/404';
}

/// Route configuration for the application.
class AppRouteConfig {
  /// Creates a new [AppRouteConfig].
  const AppRouteConfig({
    required this.path,
    required this.name,
    required this.builder,
    this.redirect,
    this.routes = const [],
    this.guards = const [],
    this.transitionBuilder,
  });

  /// Route path.
  final String path;

  /// Route name.
  final String name;

  /// Widget builder.
  final Widget Function(BuildContext, Map<String, String>) builder;

  /// Redirect logic.
  final String? Function(BuildContext, Map<String, String>)? redirect;

  /// Child routes.
  final List<AppRouteConfig> routes;

  /// Route guards.
  final List<RouteGuard> guards;

  /// Custom transition builder.
  final Widget Function(
    BuildContext,
    Animation<double>,
    Animation<double>,
    Widget,
  )? transitionBuilder;
}

/// Route guard interface.
abstract class RouteGuard {
  /// Checks if navigation is allowed.
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  );

  /// Returns redirect route if navigation is blocked.
  String? get redirectTo;
}

/// Simple router implementation.
class SimpleRouter {
  /// Creates a new [SimpleRouter].
  SimpleRouter({
    required this.routes,
    this.initialRoute = '/',
    this.onUnknownRoute,
    this.observers = const [],
  }) {
    _buildRouteMap();
  }

  /// Route configurations.
  final List<AppRouteConfig> routes;

  /// Initial route.
  final String initialRoute;

  /// Handler for unknown routes.
  final Widget Function(String)? onUnknownRoute;

  /// Navigation observers.
  final List<NavigatorObserver> observers;

  final Map<String, AppRouteConfig> _routeMap = {};

  void _buildRouteMap() {
    for (final route in routes) {
      _addRoute(route);
    }
  }

  void _addRoute(AppRouteConfig route, [String parentPath = '']) {
    final fullPath = parentPath + route.path;
    _routeMap[route.name] = route;
    _routeMap[fullPath] = route;

    for (final child in route.routes) {
      _addRoute(child, fullPath);
    }
  }

  /// Gets route configuration by name or path.
  AppRouteConfig? getRoute(String nameOrPath) {
    return _routeMap[nameOrPath];
  }

  /// Generates a route for the given settings.
  Route<dynamic>? generateRoute(RouteSettings settings) {
    final config = _routeMap[settings.name];
    if (config == null) {
      if (onUnknownRoute != null) {
        return MaterialPageRoute(
          builder: (_) => onUnknownRoute!(settings.name ?? ''),
          settings: settings,
        );
      }
      return null;
    }

    final params = _extractParams(config.path, settings.name ?? '');

    return MaterialPageRoute(
      builder: (context) => config.builder(context, params),
      settings: settings,
    );
  }

  Map<String, String> _extractParams(String pattern, String path) {
    final params = <String, String>{};
    final patternParts = pattern.split('/');
    final pathParts = path.split('/');

    for (var i = 0; i < patternParts.length && i < pathParts.length; i++) {
      final patternPart = patternParts[i];
      if (patternPart.startsWith(':')) {
        final paramName = patternPart.substring(1);
        params[paramName] = pathParts[i];
      }
    }

    return params;
  }

  /// Builds the path for a named route with parameters.
  String pathFor(String name, {Map<String, String>? params}) {
    final config = _routeMap[name];
    if (config == null) return '/';

    var path = config.path;
    params?.forEach((key, value) {
      path = path.replaceAll(':$key', value);
    });

    return path;
  }
}

/// Navigation service for programmatic navigation.
class NavigationService {
  /// Creates a new [NavigationService].
  NavigationService();

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  /// The navigator key.
  GlobalKey<NavigatorState> get navigatorKey => _navigatorKey;

  /// The current navigator state.
  NavigatorState? get _navigator => _navigatorKey.currentState;

  /// Navigates to a named route.
  Future<T?>? navigateTo<T>(
    String routeName, {
    Map<String, String>? params,
    Object? arguments,
  }) {
    return _navigator?.pushNamed<T>(
      routeName,
      arguments: arguments,
    );
  }

  /// Replaces the current route.
  Future<T?>? replaceTo<T>(
    String routeName, {
    Object? arguments,
  }) {
    return _navigator?.pushReplacementNamed<T, dynamic>(
      routeName,
      arguments: arguments,
    );
  }

  /// Navigates and removes all previous routes.
  Future<T?>? navigateAndClearStack<T>(String routeName, {Object? arguments}) {
    return _navigator?.pushNamedAndRemoveUntil<T>(
      routeName,
      (_) => false,
      arguments: arguments,
    );
  }

  /// Pops the current route.
  void goBack<T>([T? result]) {
    _navigator?.pop(result);
  }

  /// Pops until a specific route.
  void popUntil(String routeName) {
    _navigator?.popUntil(ModalRoute.withName(routeName));
  }

  /// Checks if can pop.
  bool canPop() => _navigator?.canPop() ?? false;

  /// Pops all routes and pushes a new one.
  void popAllAndPush(String routeName, {Object? arguments}) {
    _navigator?.pushNamedAndRemoveUntil(
      routeName,
      (_) => false,
      arguments: arguments,
    );
  }
}

/// Page transition types.
enum PageTransitionType {
  /// Fade transition.
  fade,

  /// Slide from right.
  slideRight,

  /// Slide from bottom.
  slideUp,

  /// Scale transition.
  scale,

  /// No transition.
  none,

  /// Platform default.
  platform,
}

/// Custom page transition builder.
class PageTransitionBuilder {
  PageTransitionBuilder._();

  /// Builds a fade transition.
  static Widget fade(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return FadeTransition(opacity: animation, child: child);
  }

  /// Builds a slide from right transition.
  static Widget slideRight(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end);
    final offsetAnimation = animation.drive(tween);
    return SlideTransition(position: offsetAnimation, child: child);
  }

  /// Builds a slide from bottom transition.
  static Widget slideUp(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const begin = Offset(0.0, 1.0);
    const end = Offset.zero;
    final tween = Tween(begin: begin, end: end);
    final offsetAnimation = animation.drive(tween);
    return SlideTransition(position: offsetAnimation, child: child);
  }

  /// Builds a scale transition.
  static Widget scale(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return ScaleTransition(scale: animation, child: child);
  }
}

/// Navigation observer for analytics.
class AnalyticsNavigationObserver extends NavigatorObserver {
  /// Creates a new [AnalyticsNavigationObserver].
  AnalyticsNavigationObserver({this.onRouteChanged});

  /// Callback when route changes.
  final void Function(String? routeName)? onRouteChanged;

  @override
  void didPush(Route route, Route? previousRoute) {
    onRouteChanged?.call(route.settings.name);
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    onRouteChanged?.call(previousRoute?.settings.name);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    onRouteChanged?.call(newRoute?.settings.name);
  }
}

/// Provider for the router.
final appRouterProvider = Provider<SimpleRouter>((ref) {
  return SimpleRouter(
    routes: [
      AppRouteConfig(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, params) => const Placeholder(),
      ),
      AppRouteConfig(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, params) => const Placeholder(),
      ),
    ],
  );
});

/// Provider for navigation service.
final navigationServiceProvider = Provider<NavigationService>((ref) {
  return NavigationService();
});
