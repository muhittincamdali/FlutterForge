/// Template generator for repositories.
///
/// Generates repository interfaces, implementations, and data sources
/// following the repository pattern.
library;

/// Template generator for repositories.
class RepositoryTemplate {
  /// Creates a new [RepositoryTemplate].
  RepositoryTemplate({
    required this.repositoryName,
    this.includeRemoteDataSource = true,
    this.includeLocalDataSource = true,
    this.methods = const ['getAll', 'getById', 'create', 'update', 'delete'],
    this.entityName,
  });

  /// The name of the repository in PascalCase (without 'Repository' suffix).
  final String repositoryName;

  /// Whether to include remote data source.
  final bool includeRemoteDataSource;

  /// Whether to include local data source.
  final bool includeLocalDataSource;

  /// List of methods to generate.
  final List<String> methods;

  /// Optional custom entity name (defaults to repositoryName + Entity).
  final String? entityName;

  /// Gets the full repository name with suffix.
  String get fullRepositoryName => '${repositoryName}Repository';

  /// Gets the entity name.
  String get entity => entityName ?? '${repositoryName}Entity';

  /// Gets the snake_case version of the repository name.
  String get repositoryNameSnake => _toSnakeCase(repositoryName);

  /// Generates all repository files.
  Map<String, String> generate() {
    final files = <String, String>{};

    // Repository interface
    files['repositories/${repositoryNameSnake}_repository.dart'] =
        _generateRepositoryInterface();

    // Repository implementation
    files['repositories/${repositoryNameSnake}_repository_impl.dart'] =
        _generateRepositoryImpl();

    // Data sources
    if (includeRemoteDataSource) {
      files['datasources/${repositoryNameSnake}_remote_datasource.dart'] =
          _generateRemoteDataSource();
    }

    if (includeLocalDataSource) {
      files['datasources/${repositoryNameSnake}_local_datasource.dart'] =
          _generateLocalDataSource();
    }

    return files;
  }

  String _generateRepositoryInterface() {
    final buffer = StringBuffer();

    buffer.writeln("import '../entities/${repositoryNameSnake}_entity.dart';");
    buffer.writeln();

    buffer.writeln('/// Repository interface for $repositoryName operations.');
    buffer.writeln('///');
    buffer.writeln('/// Defines the contract for data operations on $entity.');
    buffer.writeln('abstract class $fullRepositoryName {');

    // Generate method signatures based on requested methods
    for (final method in methods) {
      buffer.writeln();
      buffer.writeln(_generateMethodSignature(method));
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateMethodSignature(String method) {
    switch (method) {
      case 'getAll':
        return '''
  /// Retrieves all $repositoryName entities.
  ///
  /// Returns a list of all available entities.
  Future<List<$entity>> getAll();''';

      case 'getById':
        return '''
  /// Retrieves a single $repositoryName entity by [id].
  ///
  /// Returns the entity if found, null otherwise.
  Future<$entity?> getById(String id);''';

      case 'create':
        return '''
  /// Creates a new $repositoryName entity.
  ///
  /// Returns the created entity with server-generated fields.
  Future<$entity> create($entity entity);''';

      case 'update':
        return '''
  /// Updates an existing $repositoryName entity.
  ///
  /// Returns the updated entity.
  Future<$entity> update($entity entity);''';

      case 'delete':
        return '''
  /// Deletes a $repositoryName entity by [id].
  ///
  /// Throws an exception if the entity doesn't exist.
  Future<void> delete(String id);''';

      case 'search':
        return '''
  /// Searches for entities matching the [query].
  ///
  /// Returns a list of matching entities.
  Future<List<$entity>> search(String query);''';

      case 'count':
        return '''
  /// Returns the total count of entities.
  Future<int> count();''';

      case 'exists':
        return '''
  /// Checks if an entity with the given [id] exists.
  Future<bool> exists(String id);''';

      case 'getPaginated':
        return '''
  /// Retrieves entities with pagination.
  ///
  /// Returns a paginated list of entities.
  Future<List<$entity>> getPaginated({
    required int page,
    required int pageSize,
    String? sortBy,
    bool ascending = true,
  });''';

      case 'getByIds':
        return '''
  /// Retrieves multiple entities by their [ids].
  ///
  /// Returns a list of found entities (may be fewer than requested).
  Future<List<$entity>> getByIds(List<String> ids);''';

      case 'deleteAll':
        return '''
  /// Deletes all entities.
  ///
  /// Use with caution.
  Future<void> deleteAll();''';

      case 'createMany':
        return '''
  /// Creates multiple entities in batch.
  ///
  /// Returns the list of created entities.
  Future<List<$entity>> createMany(List<$entity> entities);''';

      default:
        return '''
  /// Custom method: $method
  Future<void> $method();''';
    }
  }

  String _generateRepositoryImpl() {
    final buffer = StringBuffer();

    buffer.writeln("import '../entities/${repositoryNameSnake}_entity.dart';");
    buffer.writeln("import '${repositoryNameSnake}_repository.dart';");

    if (includeRemoteDataSource) {
      buffer.writeln(
          "import '../datasources/${repositoryNameSnake}_remote_datasource.dart';");
    }
    if (includeLocalDataSource) {
      buffer.writeln(
          "import '../datasources/${repositoryNameSnake}_local_datasource.dart';");
    }

    buffer.writeln();

    buffer.writeln('/// Implementation of [$fullRepositoryName].');
    buffer.writeln('///');
    buffer.writeln('/// Coordinates between remote and local data sources,');
    buffer.writeln('/// implementing caching and offline-first strategies.');
    buffer.writeln('class ${fullRepositoryName}Impl implements $fullRepositoryName {');

    // Constructor
    buffer.writeln('  /// Creates a new [${fullRepositoryName}Impl].');
    buffer.writeln('  const ${fullRepositoryName}Impl({');
    if (includeRemoteDataSource) {
      buffer.writeln('    required this.remoteDataSource,');
    }
    if (includeLocalDataSource) {
      buffer.writeln('    required this.localDataSource,');
    }
    buffer.writeln('  });');
    buffer.writeln();

    // Data source fields
    if (includeRemoteDataSource) {
      buffer.writeln('  /// The remote data source for API operations.');
      buffer.writeln('  final ${repositoryName}RemoteDataSource remoteDataSource;');
      buffer.writeln();
    }
    if (includeLocalDataSource) {
      buffer.writeln('  /// The local data source for caching.');
      buffer.writeln('  final ${repositoryName}LocalDataSource localDataSource;');
      buffer.writeln();
    }

    // Generate method implementations
    for (final method in methods) {
      buffer.writeln(_generateMethodImpl(method));
      buffer.writeln();
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateMethodImpl(String method) {
    switch (method) {
      case 'getAll':
        return '''
  @override
  Future<List<$entity>> getAll() async {
    try {
      ${includeRemoteDataSource ? '''final entities = await remoteDataSource.getAll();
      ${includeLocalDataSource ? 'await localDataSource.cacheAll(entities);' : ''}
      return entities;''' : includeLocalDataSource ? 'return localDataSource.getAll();' : 'throw UnimplementedError();'}
    } catch (e) {
      ${includeLocalDataSource ? '''// Fallback to cache on error
      return localDataSource.getAll();''' : 'rethrow;'}
    }
  }''';

      case 'getById':
        return '''
  @override
  Future<$entity?> getById(String id) async {
    ${includeLocalDataSource ? '''// Try cache first
    final cached = await localDataSource.getById(id);
    if (cached != null) return cached;

    ''' : ''}${includeRemoteDataSource ? '''final entity = await remoteDataSource.getById(id);
    ${includeLocalDataSource ? 'if (entity != null) await localDataSource.cache(entity);' : ''}
    return entity;''' : 'throw UnimplementedError();'}
  }''';

      case 'create':
        return '''
  @override
  Future<$entity> create($entity entity) async {
    ${includeRemoteDataSource ? '''final created = await remoteDataSource.create(entity);
    ${includeLocalDataSource ? 'await localDataSource.cache(created);' : ''}
    return created;''' : includeLocalDataSource ? '''await localDataSource.cache(entity);
    return entity;''' : 'throw UnimplementedError();'}
  }''';

      case 'update':
        return '''
  @override
  Future<$entity> update($entity entity) async {
    ${includeRemoteDataSource ? '''final updated = await remoteDataSource.update(entity);
    ${includeLocalDataSource ? 'await localDataSource.cache(updated);' : ''}
    return updated;''' : includeLocalDataSource ? '''await localDataSource.cache(entity);
    return entity;''' : 'throw UnimplementedError();'}
  }''';

      case 'delete':
        return '''
  @override
  Future<void> delete(String id) async {
    ${includeRemoteDataSource ? 'await remoteDataSource.delete(id);' : ''}
    ${includeLocalDataSource ? 'await localDataSource.remove(id);' : ''}
  }''';

      case 'search':
        return '''
  @override
  Future<List<$entity>> search(String query) async {
    ${includeRemoteDataSource ? 'return remoteDataSource.search(query);' : includeLocalDataSource ? 'return localDataSource.search(query);' : 'throw UnimplementedError();'}
  }''';

      case 'count':
        return '''
  @override
  Future<int> count() async {
    ${includeRemoteDataSource ? 'return remoteDataSource.count();' : includeLocalDataSource ? 'return localDataSource.count();' : 'throw UnimplementedError();'}
  }''';

      case 'exists':
        return '''
  @override
  Future<bool> exists(String id) async {
    final entity = await getById(id);
    return entity != null;
  }''';

      case 'getPaginated':
        return '''
  @override
  Future<List<$entity>> getPaginated({
    required int page,
    required int pageSize,
    String? sortBy,
    bool ascending = true,
  }) async {
    ${includeRemoteDataSource ? '''return remoteDataSource.getPaginated(
      page: page,
      pageSize: pageSize,
      sortBy: sortBy,
      ascending: ascending,
    );''' : 'throw UnimplementedError();'}
  }''';

      case 'getByIds':
        return '''
  @override
  Future<List<$entity>> getByIds(List<String> ids) async {
    final results = <$entity>[];
    for (final id in ids) {
      final entity = await getById(id);
      if (entity != null) results.add(entity);
    }
    return results;
  }''';

      case 'deleteAll':
        return '''
  @override
  Future<void> deleteAll() async {
    ${includeRemoteDataSource ? 'await remoteDataSource.deleteAll();' : ''}
    ${includeLocalDataSource ? 'await localDataSource.clearAll();' : ''}
  }''';

      case 'createMany':
        return '''
  @override
  Future<List<$entity>> createMany(List<$entity> entities) async {
    final results = <$entity>[];
    for (final entity in entities) {
      final created = await create(entity);
      results.add(created);
    }
    return results;
  }''';

      default:
        return '''
  @override
  Future<void> $method() async {
    // TODO: Implement $method
    throw UnimplementedError();
  }''';
    }
  }

  String _generateRemoteDataSource() {
    final buffer = StringBuffer();

    buffer.writeln("import '../entities/${repositoryNameSnake}_entity.dart';");
    buffer.writeln();

    buffer.writeln('/// Remote data source for $repositoryName operations.');
    buffer.writeln('///');
    buffer.writeln('/// Handles all network requests for $repositoryName data.');
    buffer.writeln('abstract class ${repositoryName}RemoteDataSource {');

    for (final method in methods) {
      if (_isRemoteMethod(method)) {
        buffer.writeln(_generateDataSourceMethodSignature(method, true));
        buffer.writeln();
      }
    }

    buffer.writeln('}');
    buffer.writeln();

    // Implementation
    buffer.writeln('/// Implementation of [${repositoryName}RemoteDataSource].');
    buffer.writeln('class ${repositoryName}RemoteDataSourceImpl');
    buffer.writeln('    implements ${repositoryName}RemoteDataSource {');
    buffer.writeln('  /// Creates a new [${repositoryName}RemoteDataSourceImpl].');
    buffer.writeln('  const ${repositoryName}RemoteDataSourceImpl({');
    buffer.writeln('    required this.apiClient,');
    buffer.writeln('  });');
    buffer.writeln();
    buffer.writeln('  /// The API client for making network requests.');
    buffer.writeln('  final dynamic apiClient; // Replace with your API client type');
    buffer.writeln();

    for (final method in methods) {
      if (_isRemoteMethod(method)) {
        buffer.writeln(_generateDataSourceMethodImpl(method, true));
        buffer.writeln();
      }
    }

    buffer.writeln('}');

    return buffer.toString();
  }

  String _generateLocalDataSource() {
    final buffer = StringBuffer();

    buffer.writeln("import '../entities/${repositoryNameSnake}_entity.dart';");
    buffer.writeln();

    buffer.writeln('/// Local data source for $repositoryName caching.');
    buffer.writeln('///');
    buffer.writeln('/// Handles local storage operations for offline support.');
    buffer.writeln('abstract class ${repositoryName}LocalDataSource {');

    buffer.writeln('''
  /// Retrieves all cached items.
  Future<List<$entity>> getAll();

  /// Retrieves a cached item by [id].
  Future<$entity?> getById(String id);

  /// Caches all items.
  Future<void> cacheAll(List<$entity> entities);

  /// Caches a single item.
  Future<void> cache($entity entity);

  /// Removes an item from cache.
  Future<void> remove(String id);

  /// Clears all cached items.
  Future<void> clearAll();

  /// Searches cached items.
  Future<List<$entity>> search(String query);

  /// Returns the count of cached items.
  Future<int> count();
''');

    buffer.writeln('}');
    buffer.writeln();

    // Implementation
    buffer.writeln('/// Implementation of [${repositoryName}LocalDataSource].');
    buffer.writeln('class ${repositoryName}LocalDataSourceImpl');
    buffer.writeln('    implements ${repositoryName}LocalDataSource {');
    buffer.writeln('  /// Creates a new [${repositoryName}LocalDataSourceImpl].');
    buffer.writeln('  ${repositoryName}LocalDataSourceImpl();');
    buffer.writeln();
    buffer.writeln('  final Map<String, $entity> _cache = {};');
    buffer.writeln();

    buffer.writeln('''
  @override
  Future<List<$entity>> getAll() async {
    return _cache.values.toList();
  }

  @override
  Future<$entity?> getById(String id) async {
    return _cache[id];
  }

  @override
  Future<void> cacheAll(List<$entity> entities) async {
    for (final entity in entities) {
      _cache[entity.id] = entity;
    }
  }

  @override
  Future<void> cache($entity entity) async {
    _cache[entity.id] = entity;
  }

  @override
  Future<void> remove(String id) async {
    _cache.remove(id);
  }

  @override
  Future<void> clearAll() async {
    _cache.clear();
  }

  @override
  Future<List<$entity>> search(String query) async {
    final lowerQuery = query.toLowerCase();
    return _cache.values
        .where((e) => e.toString().toLowerCase().contains(lowerQuery))
        .toList();
  }

  @override
  Future<int> count() async {
    return _cache.length;
  }
''');

    buffer.writeln('}');

    return buffer.toString();
  }

  bool _isRemoteMethod(String method) {
    // Methods that should be in remote data source
    return ['getAll', 'getById', 'create', 'update', 'delete', 'search',
            'count', 'getPaginated', 'deleteAll'].contains(method);
  }

  String _generateDataSourceMethodSignature(String method, bool isRemote) {
    switch (method) {
      case 'getAll':
        return '  Future<List<$entity>> getAll();';
      case 'getById':
        return '  Future<$entity?> getById(String id);';
      case 'create':
        return '  Future<$entity> create($entity entity);';
      case 'update':
        return '  Future<$entity> update($entity entity);';
      case 'delete':
        return '  Future<void> delete(String id);';
      case 'search':
        return '  Future<List<$entity>> search(String query);';
      case 'count':
        return '  Future<int> count();';
      case 'getPaginated':
        return '''  Future<List<$entity>> getPaginated({
    required int page,
    required int pageSize,
    String? sortBy,
    bool ascending = true,
  });''';
      case 'deleteAll':
        return '  Future<void> deleteAll();';
      default:
        return '  Future<void> $method();';
    }
  }

  String _generateDataSourceMethodImpl(String method, bool isRemote) {
    final impl = isRemote
        ? '// TODO: Implement API call\n    throw UnimplementedError();'
        : '// TODO: Implement local storage\n    throw UnimplementedError();';

    switch (method) {
      case 'getAll':
        return '''  @override
  Future<List<$entity>> getAll() async {
    $impl
  }''';
      case 'getById':
        return '''  @override
  Future<$entity?> getById(String id) async {
    $impl
  }''';
      case 'create':
        return '''  @override
  Future<$entity> create($entity entity) async {
    $impl
  }''';
      case 'update':
        return '''  @override
  Future<$entity> update($entity entity) async {
    $impl
  }''';
      case 'delete':
        return '''  @override
  Future<void> delete(String id) async {
    $impl
  }''';
      case 'search':
        return '''  @override
  Future<List<$entity>> search(String query) async {
    $impl
  }''';
      case 'count':
        return '''  @override
  Future<int> count() async {
    $impl
  }''';
      case 'getPaginated':
        return '''  @override
  Future<List<$entity>> getPaginated({
    required int page,
    required int pageSize,
    String? sortBy,
    bool ascending = true,
  }) async {
    $impl
  }''';
      case 'deleteAll':
        return '''  @override
  Future<void> deleteAll() async {
    $impl
  }''';
      default:
        return '''  @override
  Future<void> $method() async {
    $impl
  }''';
    }
  }

  String _toSnakeCase(String input) {
    return input
        .replaceAllMapped(
          RegExp(r'[A-Z]'),
          (match) => '_${match.group(0)!.toLowerCase()}',
        )
        .replaceFirst('_', '');
  }
}
