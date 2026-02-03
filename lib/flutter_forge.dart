/// FlutterForge - Production-ready Flutter project template
///
/// A comprehensive Flutter application template featuring clean architecture,
/// Riverpod state management, and production-ready tooling.
library flutter_forge;

// CLI exports
export 'src/cli/cli_runner.dart';
export 'src/cli/commands/create_command.dart';
export 'src/cli/commands/generate_command.dart';
export 'src/cli/commands/build_command.dart';
export 'src/cli/commands/analyze_command.dart';
export 'src/cli/templates/template_engine.dart';
export 'src/cli/templates/feature_template.dart';
export 'src/cli/templates/model_template.dart';
export 'src/cli/templates/repository_template.dart';

// Architecture exports - Clean Architecture
export 'src/architecture/clean_architecture/domain/use_case.dart';
export 'src/architecture/clean_architecture/domain/entity.dart';
export 'src/architecture/clean_architecture/data/repository.dart';
export 'src/architecture/clean_architecture/data/datasource.dart';
export 'src/architecture/clean_architecture/presentation/bloc.dart';
export 'src/architecture/clean_architecture/presentation/state.dart';

// Architecture exports - MVVM
export 'src/architecture/mvvm/view_model.dart';
export 'src/architecture/mvvm/model.dart';

// Architecture exports - Riverpod
export 'src/architecture/riverpod/providers.dart';
export 'src/architecture/riverpod/notifiers.dart';

// Networking exports
export 'src/networking/api_client.dart';
export 'src/networking/interceptors.dart';
export 'src/networking/endpoints.dart';

// Storage exports
export 'src/storage/local_storage.dart';
export 'src/storage/secure_storage.dart';
export 'src/storage/cache.dart';

// Routing exports
export 'src/routing/app_router.dart';
export 'src/routing/route_guard.dart';
export 'src/routing/deep_linking.dart';

// DI exports
export 'src/di/injection_container.dart';
export 'src/di/service_locator.dart';

// Theming exports
export 'src/theming/app_theme.dart';
export 'src/theming/colors.dart';
export 'src/theming/typography.dart';

// Localization exports
export 'src/l10n/localization.dart';
export 'src/l10n/translations.dart';

// Utility exports
export 'src/utils/extensions.dart';
export 'src/utils/validators.dart';
export 'src/utils/formatters.dart';
