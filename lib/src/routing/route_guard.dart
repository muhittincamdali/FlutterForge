/// Route guard implementations for protected navigation.
///
/// Provides guards for authentication, authorization,
/// and other navigation protection patterns.
library;

import 'package:flutter/material.dart';

import 'app_router.dart';

/// Authentication guard that checks if user is logged in.
class AuthGuard implements RouteGuard {
  /// Creates a new [AuthGuard].
  AuthGuard({
    required this.isAuthenticated,
    this.redirectTo = '/login',
  });

  /// Function to check authentication status.
  final Future<bool> Function() isAuthenticated;

  @override
  final String redirectTo;

  @override
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    return isAuthenticated();
  }
}

/// Role-based authorization guard.
class RoleGuard implements RouteGuard {
  /// Creates a new [RoleGuard].
  RoleGuard({
    required this.getUserRole,
    required this.allowedRoles,
    this.redirectTo = '/unauthorized',
  });

  /// Function to get current user role.
  final Future<String?> Function() getUserRole;

  /// List of allowed roles.
  final List<String> allowedRoles;

  @override
  final String redirectTo;

  @override
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    final role = await getUserRole();
    return role != null && allowedRoles.contains(role);
  }
}

/// Permission-based guard.
class PermissionGuard implements RouteGuard {
  /// Creates a new [PermissionGuard].
  PermissionGuard({
    required this.hasPermission,
    required this.requiredPermission,
    this.redirectTo = '/unauthorized',
  });

  /// Function to check permission.
  final Future<bool> Function(String permission) hasPermission;

  /// Required permission.
  final String requiredPermission;

  @override
  final String redirectTo;

  @override
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    return hasPermission(requiredPermission);
  }
}

/// Onboarding completion guard.
class OnboardingGuard implements RouteGuard {
  /// Creates a new [OnboardingGuard].
  OnboardingGuard({
    required this.isOnboardingCompleted,
    this.redirectTo = '/onboarding',
  });

  /// Function to check onboarding status.
  final Future<bool> Function() isOnboardingCompleted;

  @override
  final String redirectTo;

  @override
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    return isOnboardingCompleted();
  }
}

/// Feature flag guard.
class FeatureFlagGuard implements RouteGuard {
  /// Creates a new [FeatureFlagGuard].
  FeatureFlagGuard({
    required this.isFeatureEnabled,
    required this.featureFlag,
    this.redirectTo = '/feature-unavailable',
  });

  /// Function to check feature flag.
  final Future<bool> Function(String flag) isFeatureEnabled;

  /// Feature flag name.
  final String featureFlag;

  @override
  final String redirectTo;

  @override
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    return isFeatureEnabled(featureFlag);
  }
}

/// Maintenance mode guard.
class MaintenanceGuard implements RouteGuard {
  /// Creates a new [MaintenanceGuard].
  MaintenanceGuard({
    required this.isMaintenanceMode,
    this.redirectTo = '/maintenance',
    this.exemptRoutes = const [],
  });

  /// Function to check maintenance status.
  final Future<bool> Function() isMaintenanceMode;

  /// Routes exempt from maintenance check.
  final List<String> exemptRoutes;

  @override
  final String redirectTo;

  @override
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    if (exemptRoutes.contains(route)) return true;
    final isMaintenance = await isMaintenanceMode();
    return !isMaintenance;
  }
}

/// Network connectivity guard.
class ConnectivityGuard implements RouteGuard {
  /// Creates a new [ConnectivityGuard].
  ConnectivityGuard({
    required this.isConnected,
    this.redirectTo = '/offline',
    this.offlineRoutes = const [],
  });

  /// Function to check connectivity.
  final Future<bool> Function() isConnected;

  /// Routes allowed offline.
  final List<String> offlineRoutes;

  @override
  final String redirectTo;

  @override
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    if (offlineRoutes.contains(route)) return true;
    return isConnected();
  }
}

/// Subscription/Premium guard.
class SubscriptionGuard implements RouteGuard {
  /// Creates a new [SubscriptionGuard].
  SubscriptionGuard({
    required this.hasSubscription,
    this.redirectTo = '/subscription',
  });

  /// Function to check subscription status.
  final Future<bool> Function() hasSubscription;

  @override
  final String redirectTo;

  @override
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    return hasSubscription();
  }
}

/// Composite guard that combines multiple guards.
class CompositeGuard implements RouteGuard {
  /// Creates a new [CompositeGuard].
  CompositeGuard({
    required this.guards,
    this.redirectTo = '/error',
  });

  /// List of guards to check.
  final List<RouteGuard> guards;

  @override
  final String redirectTo;

  @override
  Future<bool> canActivate(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    for (final guard in guards) {
      final canActivate = await guard.canActivate(context, route, params);
      if (!canActivate) return false;
    }
    return true;
  }

  /// Gets the redirect route for the first failing guard.
  Future<String?> getFailingRedirect(
    BuildContext context,
    String route,
    Map<String, String> params,
  ) async {
    for (final guard in guards) {
      final canActivate = await guard.canActivate(context, route, params);
      if (!canActivate) return guard.redirectTo;
    }
    return null;
  }
}

/// Guard runner utility.
class GuardRunner {
  /// Runs all guards and returns the result.
  static Future<GuardResult> run(
    BuildContext context,
    String route,
    Map<String, String> params,
    List<RouteGuard> guards,
  ) async {
    for (final guard in guards) {
      final canActivate = await guard.canActivate(context, route, params);
      if (!canActivate) {
        return GuardResult(
          allowed: false,
          redirectTo: guard.redirectTo,
          failedGuard: guard.runtimeType.toString(),
        );
      }
    }
    return const GuardResult(allowed: true);
  }
}

/// Result of guard checks.
class GuardResult {
  /// Creates a new [GuardResult].
  const GuardResult({
    required this.allowed,
    this.redirectTo,
    this.failedGuard,
  });

  /// Whether navigation is allowed.
  final bool allowed;

  /// Redirect route if blocked.
  final String? redirectTo;

  /// Name of the failed guard.
  final String? failedGuard;
}
