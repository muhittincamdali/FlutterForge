/// A screen listed on the home page.
class Destination {
  const Destination({required this.title, required this.path});

  final String title;
  final String path;
}

/// The screens listed on the home page. `forge feature` adds new features
/// above the marker line.
const List<Destination> destinations = [
  Destination(title: 'Todos', path: '/todos'),
  // forge:destinations
];
