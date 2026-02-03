/// Template generator for feature modules.
///
/// Generates a complete feature module with domain, data, and presentation
/// layers following Clean Architecture principles.
library;

/// Template generator for feature modules.
class FeatureTemplate {
  /// Creates a new [FeatureTemplate] instance.
  FeatureTemplate({
    required this.featureName,
    this.includeRepository = true,
    this.includeUseCase = true,
    this.entities = const [],
  });

  /// The name of the feature in snake_case.
  final String featureName;

  /// Whether to include repository layer.
  final bool includeRepository;

  /// Whether to include use cases.
  final bool includeUseCase;

  /// List of entity names to generate.
  final List<String> entities;

  /// Gets the feature name in PascalCase.
  String get featureNamePascal => _toPascalCase(featureName);

  /// Generates all feature files.
  Map<String, String> generate() {
    final files = <String, String>{};

    // Domain layer - Entities
    files['domain/entities/${featureName}_entity.dart'] = _generateEntity();

    // Domain layer - Repository interface
    if (includeRepository) {
      files['domain/repositories/${featureName}_repository.dart'] =
          _generateRepositoryInterface();
    }

    // Domain layer - Use cases
    if (includeUseCase) {
      files['domain/usecases/get_${featureName}_usecase.dart'] =
          _generateGetUseCase();
      files['domain/usecases/create_${featureName}_usecase.dart'] =
          _generateCreateUseCase();
      files['domain/usecases/update_${featureName}_usecase.dart'] =
          _generateUpdateUseCase();
      files['domain/usecases/delete_${featureName}_usecase.dart'] =
          _generateDeleteUseCase();
    }

    // Data layer - Models
    files['data/models/${featureName}_model.dart'] = _generateModel();

    // Data layer - Repository implementation
    if (includeRepository) {
      files['data/repositories/${featureName}_repository_impl.dart'] =
          _generateRepositoryImpl();
    }

    // Data layer - Data sources
    files['data/datasources/${featureName}_remote_datasource.dart'] =
        _generateRemoteDataSource();
    files['data/datasources/${featureName}_local_datasource.dart'] =
        _generateLocalDataSource();

    // Presentation layer - Provider/State
    files['presentation/providers/${featureName}_provider.dart'] =
        _generateProvider();
    files['presentation/providers/${featureName}_state.dart'] =
        _generateState();

    // Presentation layer - Pages
    files['presentation/pages/${featureName}_page.dart'] = _generatePage();
    files['presentation/pages/${featureName}_detail_page.dart'] =
        _generateDetailPage();

    // Presentation layer - Widgets
    files['presentation/widgets/${featureName}_card.dart'] = _generateCard();
    files['presentation/widgets/${featureName}_list.dart'] = _generateList();
    files['presentation/widgets/${featureName}_form.dart'] = _generateForm();

    return files;
  }

  /// Generates test files for the feature.
  Map<String, String> generateTests() {
    return {
      '${featureName}_repository_test.dart': _generateRepositoryTest(),
      '${featureName}_provider_test.dart': _generateProviderTest(),
      '${featureName}_page_test.dart': _generatePageTest(),
    };
  }

  String _generateEntity() {
    return '''
import 'package:equatable/equatable.dart';

/// Entity representing a $featureNamePascal.
///
/// This is the core business object for the $featureName feature.
class ${featureNamePascal}Entity extends Equatable {
  /// Creates a new [${featureNamePascal}Entity].
  const ${featureNamePascal}Entity({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  /// Unique identifier for the entity.
  final String id;

  /// The name of the entity.
  final String name;

  /// Optional description.
  final String? description;

  /// When the entity was created.
  final DateTime createdAt;

  /// When the entity was last updated.
  final DateTime? updatedAt;

  /// Whether the entity is active.
  final bool isActive;

  /// Creates a copy of this entity with the given fields replaced.
  ${featureNamePascal}Entity copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return ${featureNamePascal}Entity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [id, name, description, createdAt, updatedAt, isActive];
}
''';
  }

  String _generateRepositoryInterface() {
    return '''
import '../entities/${featureName}_entity.dart';

/// Repository interface for $featureNamePascal operations.
///
/// Defines the contract for data operations on $featureNamePascal entities.
abstract class ${featureNamePascal}Repository {
  /// Retrieves all $featureNamePascal entities.
  ///
  /// Returns a list of all available entities.
  Future<List<${featureNamePascal}Entity>> getAll();

  /// Retrieves a single $featureNamePascal entity by [id].
  ///
  /// Returns the entity if found, null otherwise.
  Future<${featureNamePascal}Entity?> getById(String id);

  /// Creates a new $featureNamePascal entity.
  ///
  /// Returns the created entity with generated fields.
  Future<${featureNamePascal}Entity> create(${featureNamePascal}Entity entity);

  /// Updates an existing $featureNamePascal entity.
  ///
  /// Returns the updated entity.
  Future<${featureNamePascal}Entity> update(${featureNamePascal}Entity entity);

  /// Deletes a $featureNamePascal entity by [id].
  Future<void> delete(String id);

  /// Searches for entities matching the [query].
  Future<List<${featureNamePascal}Entity>> search(String query);

  /// Retrieves entities with pagination.
  Future<List<${featureNamePascal}Entity>> getPaginated({
    required int page,
    required int pageSize,
  });
}
''';
  }

  String _generateGetUseCase() {
    return '''
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use case for retrieving $featureNamePascal entities.
class Get${featureNamePascal}UseCase {
  /// Creates a new [Get${featureNamePascal}UseCase].
  const Get${featureNamePascal}UseCase(this._repository);

  final ${featureNamePascal}Repository _repository;

  /// Retrieves all $featureNamePascal entities.
  Future<List<${featureNamePascal}Entity>> call() {
    return _repository.getAll();
  }

  /// Retrieves a single $featureNamePascal entity by [id].
  Future<${featureNamePascal}Entity?> getById(String id) {
    return _repository.getById(id);
  }
}
''';
  }

  String _generateCreateUseCase() {
    return '''
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use case for creating $featureNamePascal entities.
class Create${featureNamePascal}UseCase {
  /// Creates a new [Create${featureNamePascal}UseCase].
  const Create${featureNamePascal}UseCase(this._repository);

  final ${featureNamePascal}Repository _repository;

  /// Creates a new $featureNamePascal entity.
  Future<${featureNamePascal}Entity> call(${featureNamePascal}Entity entity) {
    return _repository.create(entity);
  }
}
''';
  }

  String _generateUpdateUseCase() {
    return '''
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

/// Use case for updating $featureNamePascal entities.
class Update${featureNamePascal}UseCase {
  /// Creates a new [Update${featureNamePascal}UseCase].
  const Update${featureNamePascal}UseCase(this._repository);

  final ${featureNamePascal}Repository _repository;

  /// Updates an existing $featureNamePascal entity.
  Future<${featureNamePascal}Entity> call(${featureNamePascal}Entity entity) {
    return _repository.update(entity);
  }
}
''';
  }

  String _generateDeleteUseCase() {
    return '''
import '../repositories/${featureName}_repository.dart';

/// Use case for deleting $featureNamePascal entities.
class Delete${featureNamePascal}UseCase {
  /// Creates a new [Delete${featureNamePascal}UseCase].
  const Delete${featureNamePascal}UseCase(this._repository);

  final ${featureNamePascal}Repository _repository;

  /// Deletes a $featureNamePascal entity by [id].
  Future<void> call(String id) {
    return _repository.delete(id);
  }
}
''';
  }

  String _generateModel() {
    return '''
import 'package:freezed_annotation/freezed_annotation.dart';

import '../../domain/entities/${featureName}_entity.dart';

part '${featureName}_model.freezed.dart';
part '${featureName}_model.g.dart';

/// Data model for $featureNamePascal.
///
/// Handles serialization and deserialization of data.
@freezed
class ${featureNamePascal}Model with _\$${featureNamePascal}Model {
  /// Creates a new [${featureNamePascal}Model].
  const factory ${featureNamePascal}Model({
    required String id,
    required String name,
    String? description,
    @JsonKey(name: 'created_at') required DateTime createdAt,
    @JsonKey(name: 'updated_at') DateTime? updatedAt,
    @Default(true) @JsonKey(name: 'is_active') bool isActive,
  }) = _${featureNamePascal}Model;

  const ${featureNamePascal}Model._();

  /// Creates a model from JSON.
  factory ${featureNamePascal}Model.fromJson(Map<String, dynamic> json) =>
      _\$${featureNamePascal}ModelFromJson(json);

  /// Creates a model from an entity.
  factory ${featureNamePascal}Model.fromEntity(${featureNamePascal}Entity entity) {
    return ${featureNamePascal}Model(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isActive: entity.isActive,
    );
  }

  /// Converts this model to an entity.
  ${featureNamePascal}Entity toEntity() {
    return ${featureNamePascal}Entity(
      id: id,
      name: name,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive,
    );
  }
}
''';
  }

  String _generateRepositoryImpl() {
    return '''
import '../../domain/entities/${featureName}_entity.dart';
import '../../domain/repositories/${featureName}_repository.dart';
import '../datasources/${featureName}_local_datasource.dart';
import '../datasources/${featureName}_remote_datasource.dart';
import '../models/${featureName}_model.dart';

/// Implementation of [${featureNamePascal}Repository].
///
/// Coordinates between remote and local data sources.
class ${featureNamePascal}RepositoryImpl implements ${featureNamePascal}Repository {
  /// Creates a new [${featureNamePascal}RepositoryImpl].
  const ${featureNamePascal}RepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  /// The remote data source.
  final ${featureNamePascal}RemoteDataSource remoteDataSource;

  /// The local data source.
  final ${featureNamePascal}LocalDataSource localDataSource;

  @override
  Future<List<${featureNamePascal}Entity>> getAll() async {
    try {
      final models = await remoteDataSource.getAll();
      await localDataSource.cacheAll(models);
      return models.map((m) => m.toEntity()).toList();
    } catch (e) {
      final cached = await localDataSource.getCached();
      return cached.map((m) => m.toEntity()).toList();
    }
  }

  @override
  Future<${featureNamePascal}Entity?> getById(String id) async {
    final model = await remoteDataSource.getById(id);
    return model?.toEntity();
  }

  @override
  Future<${featureNamePascal}Entity> create(${featureNamePascal}Entity entity) async {
    final model = ${featureNamePascal}Model.fromEntity(entity);
    final created = await remoteDataSource.create(model);
    return created.toEntity();
  }

  @override
  Future<${featureNamePascal}Entity> update(${featureNamePascal}Entity entity) async {
    final model = ${featureNamePascal}Model.fromEntity(entity);
    final updated = await remoteDataSource.update(model);
    return updated.toEntity();
  }

  @override
  Future<void> delete(String id) async {
    await remoteDataSource.delete(id);
    await localDataSource.remove(id);
  }

  @override
  Future<List<${featureNamePascal}Entity>> search(String query) async {
    final models = await remoteDataSource.search(query);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<${featureNamePascal}Entity>> getPaginated({
    required int page,
    required int pageSize,
  }) async {
    final models = await remoteDataSource.getPaginated(
      page: page,
      pageSize: pageSize,
    );
    return models.map((m) => m.toEntity()).toList();
  }
}
''';
  }

  String _generateRemoteDataSource() {
    return '''
import '../models/${featureName}_model.dart';

/// Remote data source for $featureNamePascal operations.
///
/// Handles all network requests for $featureNamePascal data.
abstract class ${featureNamePascal}RemoteDataSource {
  /// Retrieves all items from the server.
  Future<List<${featureNamePascal}Model>> getAll();

  /// Retrieves a single item by [id].
  Future<${featureNamePascal}Model?> getById(String id);

  /// Creates a new item on the server.
  Future<${featureNamePascal}Model> create(${featureNamePascal}Model model);

  /// Updates an item on the server.
  Future<${featureNamePascal}Model> update(${featureNamePascal}Model model);

  /// Deletes an item from the server.
  Future<void> delete(String id);

  /// Searches for items matching the [query].
  Future<List<${featureNamePascal}Model>> search(String query);

  /// Retrieves paginated items.
  Future<List<${featureNamePascal}Model>> getPaginated({
    required int page,
    required int pageSize,
  });
}

/// Implementation of [${featureNamePascal}RemoteDataSource].
class ${featureNamePascal}RemoteDataSourceImpl implements ${featureNamePascal}RemoteDataSource {
  /// Creates a new [${featureNamePascal}RemoteDataSourceImpl].
  const ${featureNamePascal}RemoteDataSourceImpl();

  @override
  Future<List<${featureNamePascal}Model>> getAll() async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<${featureNamePascal}Model?> getById(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<${featureNamePascal}Model> create(${featureNamePascal}Model model) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<${featureNamePascal}Model> update(${featureNamePascal}Model model) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<void> delete(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<List<${featureNamePascal}Model>> search(String query) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }

  @override
  Future<List<${featureNamePascal}Model>> getPaginated({
    required int page,
    required int pageSize,
  }) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
''';
  }

  String _generateLocalDataSource() {
    return '''
import '../models/${featureName}_model.dart';

/// Local data source for $featureNamePascal caching.
///
/// Handles local storage operations for offline support.
abstract class ${featureNamePascal}LocalDataSource {
  /// Retrieves all cached items.
  Future<List<${featureNamePascal}Model>> getCached();

  /// Caches all items.
  Future<void> cacheAll(List<${featureNamePascal}Model> models);

  /// Caches a single item.
  Future<void> cache(${featureNamePascal}Model model);

  /// Removes an item from cache.
  Future<void> remove(String id);

  /// Clears all cached items.
  Future<void> clearCache();
}

/// Implementation of [${featureNamePascal}LocalDataSource].
class ${featureNamePascal}LocalDataSourceImpl implements ${featureNamePascal}LocalDataSource {
  /// Creates a new [${featureNamePascal}LocalDataSourceImpl].
  const ${featureNamePascal}LocalDataSourceImpl();

  @override
  Future<List<${featureNamePascal}Model>> getCached() async {
    // TODO: Implement local storage retrieval
    return [];
  }

  @override
  Future<void> cacheAll(List<${featureNamePascal}Model> models) async {
    // TODO: Implement local storage caching
  }

  @override
  Future<void> cache(${featureNamePascal}Model model) async {
    // TODO: Implement local storage caching
  }

  @override
  Future<void> remove(String id) async {
    // TODO: Implement local storage removal
  }

  @override
  Future<void> clearCache() async {
    // TODO: Implement cache clearing
  }
}
''';
  }

  String _generateProvider() {
    return '''
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/${featureName}_entity.dart';
import '${featureName}_state.dart';

/// Provider for $featureNamePascal state management.
final ${featureName}Provider =
    StateNotifierProvider<${featureNamePascal}Notifier, ${featureNamePascal}State>((ref) {
  return ${featureNamePascal}Notifier();
});

/// Selected item provider.
final selected${featureNamePascal}Provider = StateProvider<${featureNamePascal}Entity?>((ref) => null);

/// Search query provider.
final ${featureName}SearchQueryProvider = StateProvider<String>((ref) => '');

/// Filtered items provider.
final filtered${featureNamePascal}ListProvider = Provider<List<${featureNamePascal}Entity>>((ref) {
  final state = ref.watch(${featureName}Provider);
  final query = ref.watch(${featureName}SearchQueryProvider);

  if (query.isEmpty) return state.items;

  return state.items
      .where((item) => item.name.toLowerCase().contains(query.toLowerCase()))
      .toList();
});

/// Notifier for $featureNamePascal state.
class ${featureNamePascal}Notifier extends StateNotifier<${featureNamePascal}State> {
  /// Creates a new [${featureNamePascal}Notifier].
  ${featureNamePascal}Notifier() : super(const ${featureNamePascal}State());

  /// Loads all items.
  Future<void> loadItems() async {
    state = state.copyWith(status: ${featureNamePascal}Status.loading);
    try {
      // TODO: Call use case
      final items = <${featureNamePascal}Entity>[];
      state = state.copyWith(
        items: items,
        status: ${featureNamePascal}Status.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: ${featureNamePascal}Status.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Creates a new item.
  Future<void> createItem(${featureNamePascal}Entity entity) async {
    state = state.copyWith(status: ${featureNamePascal}Status.loading);
    try {
      // TODO: Call use case
      final items = [...state.items, entity];
      state = state.copyWith(
        items: items,
        status: ${featureNamePascal}Status.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: ${featureNamePascal}Status.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Updates an existing item.
  Future<void> updateItem(${featureNamePascal}Entity entity) async {
    state = state.copyWith(status: ${featureNamePascal}Status.loading);
    try {
      // TODO: Call use case
      final items = state.items.map((item) {
        return item.id == entity.id ? entity : item;
      }).toList();
      state = state.copyWith(
        items: items,
        status: ${featureNamePascal}Status.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: ${featureNamePascal}Status.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Deletes an item.
  Future<void> deleteItem(String id) async {
    state = state.copyWith(status: ${featureNamePascal}Status.loading);
    try {
      // TODO: Call use case
      final items = state.items.where((item) => item.id != id).toList();
      state = state.copyWith(
        items: items,
        status: ${featureNamePascal}Status.success,
      );
    } catch (e) {
      state = state.copyWith(
        status: ${featureNamePascal}Status.error,
        errorMessage: e.toString(),
      );
    }
  }

  /// Clears any error state.
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }
}
''';
  }

  String _generateState() {
    return '''
import '../../domain/entities/${featureName}_entity.dart';

/// Status of $featureNamePascal operations.
enum ${featureNamePascal}Status {
  /// Initial state.
  initial,

  /// Loading data.
  loading,

  /// Operation successful.
  success,

  /// Operation failed.
  error,
}

/// State for $featureNamePascal feature.
class ${featureNamePascal}State {
  /// Creates a new [${featureNamePascal}State].
  const ${featureNamePascal}State({
    this.items = const [],
    this.status = ${featureNamePascal}Status.initial,
    this.errorMessage,
    this.currentPage = 1,
    this.hasMore = true,
  });

  /// List of items.
  final List<${featureNamePascal}Entity> items;

  /// Current status.
  final ${featureNamePascal}Status status;

  /// Error message if any.
  final String? errorMessage;

  /// Current page for pagination.
  final int currentPage;

  /// Whether there are more items to load.
  final bool hasMore;

  /// Whether the state is loading.
  bool get isLoading => status == ${featureNamePascal}Status.loading;

  /// Whether the state has an error.
  bool get hasError => status == ${featureNamePascal}Status.error;

  /// Creates a copy with the given fields replaced.
  ${featureNamePascal}State copyWith({
    List<${featureNamePascal}Entity>? items,
    ${featureNamePascal}Status? status,
    String? errorMessage,
    int? currentPage,
    bool? hasMore,
  }) {
    return ${featureNamePascal}State(
      items: items ?? this.items,
      status: status ?? this.status,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
''';
  }

  String _generatePage() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/${featureName}_provider.dart';
import '../widgets/${featureName}_list.dart';

/// Main page for $featureNamePascal feature.
class ${featureNamePascal}Page extends ConsumerStatefulWidget {
  /// Creates a new [${featureNamePascal}Page].
  const ${featureNamePascal}Page({super.key});

  @override
  ConsumerState<${featureNamePascal}Page> createState() => _${featureNamePascal}PageState();
}

class _${featureNamePascal}PageState extends ConsumerState<${featureNamePascal}Page> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(${featureName}Provider.notifier).loadItems();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(${featureName}Provider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('$featureNamePascal'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () => _showSearch(context),
          ),
        ],
      ),
      body: _buildBody(state),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAdd,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(${featureNamePascal}State state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage ?? 'An error occurred'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(${featureName}Provider.notifier).loadItems();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state.items.isEmpty) {
      return const Center(
        child: Text('No items found'),
      );
    }

    return ${featureNamePascal}List(items: state.items);
  }

  void _showSearch(BuildContext context) {
    // TODO: Implement search
  }

  void _onAdd() {
    // TODO: Navigate to create page
  }
}
''';
  }

  String _generateDetailPage() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/${featureName}_entity.dart';
import '../providers/${featureName}_provider.dart';

/// Detail page for $featureNamePascal.
class ${featureNamePascal}DetailPage extends ConsumerWidget {
  /// Creates a new [${featureNamePascal}DetailPage].
  const ${featureNamePascal}DetailPage({
    required this.item,
    super.key,
  });

  /// The item to display.
  final ${featureNamePascal}Entity item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => _onEdit(context),
          ),
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () => _onDelete(context, ref),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              item.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            if (item.description != null)
              Text(
                item.description!,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            const SizedBox(height: 16),
            Text(
              'Created: \${item.createdAt}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            if (item.updatedAt != null)
              Text(
                'Updated: \${item.updatedAt}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
          ],
        ),
      ),
    );
  }

  void _onEdit(BuildContext context) {
    // TODO: Navigate to edit page
  }

  Future<void> _onDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ref.read(${featureName}Provider.notifier).deleteItem(item.id);
      Navigator.pop(context);
    }
  }
}
''';
  }

  String _generateCard() {
    return '''
import 'package:flutter/material.dart';

import '../../domain/entities/${featureName}_entity.dart';

/// Card widget for displaying a $featureNamePascal item.
class ${featureNamePascal}Card extends StatelessWidget {
  /// Creates a new [${featureNamePascal}Card].
  const ${featureNamePascal}Card({
    required this.item,
    this.onTap,
    super.key,
  });

  /// The item to display.
  final ${featureNamePascal}Entity item;

  /// Callback when the card is tapped.
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (item.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  item.description!,
                  style: Theme.of(context).textTheme.bodyMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
''';
  }

  String _generateList() {
    return '''
import 'package:flutter/material.dart';

import '../../domain/entities/${featureName}_entity.dart';
import '${featureName}_card.dart';

/// List widget for displaying $featureNamePascal items.
class ${featureNamePascal}List extends StatelessWidget {
  /// Creates a new [${featureNamePascal}List].
  const ${featureNamePascal}List({
    required this.items,
    this.onItemTap,
    super.key,
  });

  /// The items to display.
  final List<${featureNamePascal}Entity> items;

  /// Callback when an item is tapped.
  final void Function(${featureNamePascal}Entity)? onItemTap;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ${featureNamePascal}Card(
          item: item,
          onTap: () => onItemTap?.call(item),
        );
      },
    );
  }
}
''';
  }

  String _generateForm() {
    return '''
import 'package:flutter/material.dart';

import '../../domain/entities/${featureName}_entity.dart';

/// Form widget for creating/editing $featureNamePascal items.
class ${featureNamePascal}Form extends StatefulWidget {
  /// Creates a new [${featureNamePascal}Form].
  const ${featureNamePascal}Form({
    this.initialValue,
    required this.onSubmit,
    super.key,
  });

  /// Initial value for editing.
  final ${featureNamePascal}Entity? initialValue;

  /// Callback when form is submitted.
  final void Function(${featureNamePascal}Entity) onSubmit;

  @override
  State<${featureNamePascal}Form> createState() => _${featureNamePascal}FormState();
}

class _${featureNamePascal}FormState extends State<${featureNamePascal}Form> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialValue?.name);
    _descriptionController = TextEditingController(
      text: widget.initialValue?.description,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _onSubmit,
            child: Text(widget.initialValue == null ? 'Create' : 'Update'),
          ),
        ],
      ),
    );
  }

  void _onSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      final entity = ${featureNamePascal}Entity(
        id: widget.initialValue?.id ?? DateTime.now().toIso8601String(),
        name: _nameController.text,
        description: _descriptionController.text.isEmpty
            ? null
            : _descriptionController.text,
        createdAt: widget.initialValue?.createdAt ?? DateTime.now(),
        updatedAt: widget.initialValue != null ? DateTime.now() : null,
      );
      widget.onSubmit(entity);
    }
  }
}
''';
  }

  String _generateRepositoryTest() {
    return '''
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('${featureNamePascal}Repository', () {
    test('getAll returns list of entities', () async {
      // TODO: Implement test
    });

    test('getById returns entity when found', () async {
      // TODO: Implement test
    });

    test('create returns created entity', () async {
      // TODO: Implement test
    });

    test('update returns updated entity', () async {
      // TODO: Implement test
    });

    test('delete completes successfully', () async {
      // TODO: Implement test
    });
  });
}
''';
  }

  String _generateProviderTest() {
    return '''
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('${featureNamePascal}Provider', () {
    test('initial state is correct', () {
      // TODO: Implement test
    });

    test('loadItems updates state correctly', () async {
      // TODO: Implement test
    });

    test('createItem adds item to state', () async {
      // TODO: Implement test
    });

    test('deleteItem removes item from state', () async {
      // TODO: Implement test
    });
  });
}
''';
  }

  String _generatePageTest() {
    return '''
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  group('${featureNamePascal}Page', () {
    testWidgets('renders loading indicator initially', (tester) async {
      // TODO: Implement test
    });

    testWidgets('renders list when loaded', (tester) async {
      // TODO: Implement test
    });

    testWidgets('renders error message on failure', (tester) async {
      // TODO: Implement test
    });
  });
}
''';
  }

  String _toPascalCase(String input) {
    return input
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join();
  }
}
