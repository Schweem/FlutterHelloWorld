import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  //you know what main is!
  runApp(MyApp()); //run the app
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App', //title
        theme: ThemeData(
          //assign theme and customzie
          useMaterial3: true,
          colorScheme:
              ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 93, 93, 93)),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random(); //update current word
    notifyListeners(); //notify observers
  }

  var favorites = <WordPair>[]; //initialize favorite list

  void toggleFavorite() {
    //add or remove from favorites
    if (favorites.contains(current)) {
      favorites.remove(current);
      print(favorites);
    } else {
      favorites.add(current);
      print(favorites);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    favorites.remove(pair);
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0; // track page index
  @override
  Widget build(BuildContext context) {
    Widget page; //page widget
    switch (selectedIndex) {
      //switch between pages
      case 0:
        page = GeneratorPage();
      case 1:
        page = FavoritesPage(); //will be favorites page
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600, //labels if space
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: selectedIndex, //track selected index
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                  print('selected: $value');
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page, //select page
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    if (appState.favorites.isEmpty) {
      return Center(
        child: Text('No Favorites yet. Go get em'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have ' '${appState.favorites.length} favorites:'),
        ),
        for (var pair in appState.favorites)
          ListTile(
            leading: IconButton(
              icon: Icon(Icons.favorite),
              onPressed: () {
                appState.removeFavorite(pair);
              },
            ),
            title: Text(pair.asLowerCase),
          )
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var pair = appState.current;

    IconData icon;
    if (appState.favorites.contains(pair)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(pair: pair),
          SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('New'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); //request theme of context
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    ); //grab the style form theme, specifcally for short/important text (this is a copy)
    return Card(
      color: theme.colorScheme.primary, //apply primary color from context theme
      elevation: 3.5, //shadow size
      child: Padding(
        //wrap card in widget
        padding: const EdgeInsets.all(20), //padding
        child: Text(
          pair.asPascalCase,
          style: style,
          semanticsLabel:
              "${pair.first} ${pair.second}", //for screen reader, seperate word 1 and 2
        ), //text content, get style from style
      ),
    );
  }
}
