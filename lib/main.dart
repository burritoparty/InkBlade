import 'package:flutter/material.dart';
import 'screen/screens.dart';
import 'router/routes.dart';

// entry point: inflate the widget tree
void main() => runApp(const MyApp());

// root widget: sets up theme and home screen
class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
    Tags(),
    Favorites(),
    Filter(),
  ];

  // update selected index and rebuild
  void _onItemTapped(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar with conditional back button
      appBar: AppBar(
        // show back arrow on pages 3+ (Search, Favorites, Filter)
        leading: _selectedIndex >= 3
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedIndex = 0),
              )
            : null,
        title: const Text('Manga Reader'), // app title
      ),

      // main content = the currently selected page
      body: _pages[_selectedIndex],

      // only show fab on
      // the first 3 tabs library, authors, tabs
      floatingActionButton: _selectedIndex < 3
          ? FloatingActionButton(
              child: const Icon(Icons.add),
              onPressed: () {}, // TODO: add new item
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

// reusable BottomNavigationBar wrapper
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
          // each item switches pages 4,5
          _buildItem(context, Icons.favorite, 'Favorites', 3),
          _buildItem(context, Icons.filter_alt, 'Filter Library', 4),
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
