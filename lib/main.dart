import 'package:flutter/material.dart';

// imports entire screen folder
import 'screen/screens.dart';

void main() {
  // global function: runApp()
  // takes a single widget, inflates it to the screen
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // setting up paging variable
  int _selectedIndex = 0;

  // setting up pages to switch between
  static const List<Widget> _pages = <Widget>[
    Library(),
    Authors(),
    Tags(),
    Search(),
    Favorites(),
    Filter()
  ];

  // changes index for page
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: Scaffold(
        // set the page
        body: _pages[_selectedIndex],
        // setting app bar
        appBar: AppBar(
          // making it so its a back button in drawer page
          leading: _selectedIndex >= 3
              ? IconButton(
                  onPressed: () {
                    setState(() => _selectedIndex = 0);
                  },
                  icon: const Icon(Icons.arrow_back))
              : null,
          // set the title
          title: const Text(
            'Manga Reader',
            style: TextStyle(),
          ),
        ),
        // _selectedIndex < 3? and :null make it so that it disappears when on other pages
        floatingActionButton: _selectedIndex < 3
            ? FloatingActionButton(
                child: const Icon(Icons.add),
                onPressed: () {},
              )
            : null,
        // _selectedIndex < 3? and :null make it so that it disappears when on other pages
        bottomNavigationBar: _selectedIndex < 3
            ? BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: _onItemTapped,
                items: const [
                  BottomNavigationBarItem(
                      icon: Icon(Icons.home), label: 'Home'),
                  BottomNavigationBarItem(
                      icon: Icon(Icons.book), label: 'Authors'),
                  BottomNavigationBarItem(icon: Icon(Icons.tag), label: 'Tags'),
                ],
              )
            : null,
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              const DrawerHeader(
                decoration: BoxDecoration(),
                child: Center(
                  child: Text(
                    'Library Searching',
                    style: TextStyle(fontSize: 30),
                  ),
                ),
              ),

              // Wrap in Builder to capture the right context
              Builder(builder: (BuildContext innerCtx) {
                return ListTile(
                  leading: const Icon(Icons.search),
                  title: const Text("Search"),
                  onTap: () {
                    Navigator.pop(innerCtx); // now closes the drawer
                    setState(() => _selectedIndex = 3); // switch to Library()
                  },
                );
              }),

              Builder(builder: (BuildContext innerCtx) {
                return ListTile(
                  leading: const Icon(Icons.favorite),
                  title: const Text("Favorites"),
                  onTap: () {
                    Navigator.pop(innerCtx);
                    setState(() => _selectedIndex = 4);
                  },
                );
              }),

              Builder(builder: (BuildContext innerCtx) {
                return ListTile(
                  leading: const Icon(Icons.filter_alt),
                  title: const Text("Filter Library"),
                  onTap: () {
                    Navigator.pop(innerCtx);
                    setState(() => _selectedIndex = 5);
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
