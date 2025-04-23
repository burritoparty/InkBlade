import 'package:flutter/material.dart';

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
    Center(child: Text("Home Page")),
    Center(child: Text('Authors Page')),
    Center(child: Text('Tags Page')),
    Center(child: Text("Search Page")),
    Center(child: Text("Favorites Page")),
    Center(child: Text("Filter Page")),
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
        body: _pages[_selectedIndex],
        appBar: AppBar(
          // backgroundColor: Colors.blue,
          title: const Text(
            'Manga Reader',
            style: TextStyle(),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {},
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Authors'),
            BottomNavigationBarItem(icon: Icon(Icons.tag), label: 'Tags'),
          ],
        ),
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
              ListTile(
                leading: const Icon(Icons.search),
                title: const Text("Search"),
                onTap: () {
                  Navigator.pop(context);
                  // setState(() {
                  //   _selectedIndex = 3;
                  // });
                },
              ),
              const ListTile(leading: Icon(Icons.favorite), title: Text("Favorites")),
              const ListTile(
                leading: Icon(Icons.filter_alt),
                title: Text("Filter Library"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
