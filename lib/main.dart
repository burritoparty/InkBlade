// Third-party package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project-specific imports
import 'controllers/library_controller.dart';
import 'controllers/settings_controller.dart';
import 'router/routes.dart';
import 'screen/screens.dart';
import 'services/library_repository.dart';

// entry point: inflate the widget tree
void main() async {
  // make sure engine and bindings are ready
  WidgetsFlutterBinding.ensureInitialized();

  // initialize the library repository, for managing the json file
  final libraryRepository = LibraryRepository();
  // initialize the library controller, for managing the books
  final libraryController = LibraryController(libraryRepository);

  await libraryController.init();

  // initialize the settings controller, for managing the settings
  final settingsController = SettingsController();
  // call init to load the settings from shared preferences
  await settingsController.init();

  // run the app with the loaded data
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: libraryController),
        ChangeNotifierProvider.value(value: settingsController),
      ],
      child: const MyApp(),
    ),
  );
}

// root widget: sets up theme and home screen
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InkBlade',
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
    Settings(),
    SeriesPage(),
    CharactersPage(),
  ];
  static const _pageTitles = [
    'Library',
    'Authors',
    'Tags',
    'Favorites',
    'Read Later',
    'Filter Library',
    'Settings',
    'Series',
    'Characters',
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
        title: Text(_pageTitles[_selectedIndex]),
        centerTitle: true,
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
              },
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
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

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
  const NavDrawer({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(),
            child: Center(
              child: Text('InkBlade', style: TextStyle(fontSize: 30)),
            ),
          ),
          // new order
          _buildItem(context, Icons.favorite, 'Favorites', 3),
          _buildItem(context, Icons.bookmark, 'Later', 4),
          const Divider(height: 0),
          _buildItem(context, Icons.auto_stories, 'Series', 7),
          _buildItem(context, Icons.groups, 'Characters', 8),
          const Divider(height: 0),
          _buildItem(context, Icons.filter_alt, 'Filter Library', 5),
          _buildItem(context, Icons.settings, 'Settings', 6),
          const Divider(height: 0),
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
