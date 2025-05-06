import 'package:flutter/material.dart';
import 'services/library_repository.dart';
import 'models/book.dart';
import 'screen/screens.dart';
import 'router/routes.dart';

// entry point: inflate the widget tree
void main() async {
  // make sure engine and bindings are ready
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the library repository, for managing the json file
  final libraryRepository = LibraryRepository();
  // call init to create the json file if it doesn't exist
  await libraryRepository.init();
  // load books from the json file on disk
  final Books = await libraryRepository.loadBooks();

  // set up sets for unique values
  final authors = <String>{};
  final tags = <String>{};
  final series = <String>{};
  final characters = <String>{};

  // loop through all books and add their values to the sets
  for (final book in Books) {
    authors.addAll(book.authors);
    tags.addAll(book.tags);
    series.add(book.series);
    characters.addAll(book.characters);
  }

  // run the app with the loaded data
  runApp(
    MyApp(
      libraryRepository: libraryRepository,
      allBooks: Books,
      allAuthors: authors.toList(),
      allTags: tags.toList(),
      allSeries: series.toList(),
      allCharacters: characters.toList(),
    ),
  );
}

// root widget: sets up theme and home screen
class MyApp extends StatelessWidget {
  final LibraryRepository libraryRepository;
  final List<Book> allBooks;
  final List<String> allAuthors;
  final List<String> allTags;
  final List<String> allSeries;
  final List<String> allCharacters;
  const MyApp({
    super.key,
    required this.libraryRepository,
    required this.allBooks,
    required this.allAuthors,
    required this.allTags,
    required this.allSeries,
    required this.allCharacters,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: const HomeScaffold(),
      // custom router, go through AppRouter.onGenerateRoute
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}

// main scaffold:
// holds AppBar, body, FAB, bottom nav & drawer
class HomeScaffold extends StatefulWidget {
  const HomeScaffold({super.key});

  @override
  State<HomeScaffold> createState() => _HomeScaffoldState();
}

class _HomeScaffoldState extends State<HomeScaffold> {
  // track which page/tab is selected
  int _selectedIndex = 0;

  // all the pages we can switch between
  static const _pages = <Widget>[
    Library(),
    Authors(),
    TagPage(),
    Favorites(),
    Later(),
    Filter(),
    Settings()
  ];
  static const _pageTitles = [
    'Library',
    'Authors',
    'Tags',
    'Favorites',
    'Read Later',
    'Filter Library',
    'Settings',
  ];

  // update selected index and rebuild
  void _onItemTapped(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appbar: conditional back button on search
      appBar: AppBar(
        // show back arrow on pages 3+ (Favorites, Later, Filter, Settings)
        leading: _selectedIndex >= 3
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedIndex = 0),
              )
            : null,
        title: Text(_pageTitles[_selectedIndex]), // app title
      ),

      // main content
      // page shown is the selected index, see in _pages
      body: _pages[_selectedIndex],

      // only show fab on the first 3 tabs:
      // library, authors, tabs
      floatingActionButton: _selectedIndex < 3
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {
                Navigator.pushNamed(context, Routes.import);
              }, // TODO: add new item
            )
          : null,

      // bottom tabs for first 3 pages
      // the first 3 tabs library, authors, tabs
      bottomNavigationBar: _selectedIndex < 3
          ? MainBottomNav(
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            )
          : null,

      // side drawer for search, favorites, filter
      drawer: NavDrawer(onTap: _onItemTapped),
    );
  }
}

// bottom nav
class MainBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const MainBottomNav({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext c) {
    return BottomNavigationBar(
      // highlight current tab
      currentIndex: currentIndex,
      onTap: onTap,
      items: const [
        BottomNavigationBarItem(
            icon: Icon(Icons.library_books), label: 'Library'),
        BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Authors'),
        BottomNavigationBarItem(icon: Icon(Icons.tag), label: 'Tags'),
      ],
    );
  }
}

// side drawer with extra navigation options
class NavDrawer extends StatelessWidget {
  final ValueChanged<int> onTap;
  const NavDrawer({Key? key, required this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          // drawer header
          const DrawerHeader(
            decoration: BoxDecoration(),
            child: Center(
              child: Text('Library Searching', style: TextStyle(fontSize: 30)),
            ),
          ),
          // each item switches pages 3, 4, 5, 6
          _buildItem(context, Icons.favorite, 'Favorites', 3),
          _buildItem(context, Icons.bookmark, 'Later', 4),
          _buildItem(context, Icons.filter_alt, 'Filter Library', 5),
          _buildItem(context, Icons.settings, 'Settings', 6),
        ],
      ),
    );
  }

  // helper to build a listtile and handle navigation
  Widget _buildItem(BuildContext ctx, IconData icon, String label, int idx) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        Navigator.pop(ctx); // close drawer
        onTap(idx); // switch to that page
      },
    );
  }
}
