/// A file the generator writes: a path relative to the project and the
/// template of its content.
final class TemplateFile {
  /// Creates a template file. Both [path] and [content] may contain
  /// `{{key}}` placeholders.
  const TemplateFile(this.path, this.content);

  /// The path relative to the project root, with `/` separators.
  final String path;

  /// The content template.
  final String content;
}

final RegExp _placeholder = RegExp(r'\{\{([A-Za-z][A-Za-z0-9]*)\}\}');

/// Replaces every `{{key}}` in [template] with `values[key]`.
///
/// Throws a [StateError] for a placeholder without a value, so a mistake in a
/// template fails the generator instead of producing broken code. Values are
/// inserted once and not scanned again, so a value that contains `{{…}}` is
/// written as it is.
String render(String template, Map<String, String> values) {
  return template.replaceAllMapped(_placeholder, (match) {
    final key = match.group(1)!;
    final value = values[key];
    if (value == null) throw StateError('The template uses {{$key}}, which has no value.');
    return value;
  });
}
