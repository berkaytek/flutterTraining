import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';

Logger logger = Logger();

void main() {
  runApp(const WordApp());
}

/// Word App
class WordApp extends StatelessWidget {
  const WordApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => WordAppState(),
      child: MaterialApp(
        title: "Berkay Word Name App",
        theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue)),
        home: const MainPage(),
      ),
    );
  }
}

class WordAppState extends ChangeNotifier {
  WordPair currentWord = WordPair.random();
  List<WordPair> favoriteWords = <WordPair>[];

  void getNextWord() {
    currentWord = WordPair.random();
    logger.i("Generated new word!");
    notifyListeners();
  }

  void toggleFavorite() {
    if (favoriteWords.contains(currentWord)) {
      favoriteWords.remove(currentWord);
    } else {
      favoriteWords.add(currentWord);
    }
    notifyListeners();
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedNavigationRailIndex = 0;
  @override
  Widget build(BuildContext context) {
    Widget page;
    switch(selectedNavigationRailIndex){
      case 0:
        page = const WordGeneratorPage();
        break;
      case 1:
        page = const FavoritesPage();
        break;
      default:
        throw UnimplementedError("There is no page for given index $selectedNavigationRailIndex");
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                  child: NavigationRail(
                    extended: constraints.maxWidth > 600,
                    selectedIndex: selectedNavigationRailIndex,
                    onDestinationSelected: (navigatedValue) {
                      setState(() {
                        selectedNavigationRailIndex = navigatedValue;
                      });
                      logger.i("Navigated to $navigatedValue");
                    },
                    destinations: const [
                      NavigationRailDestination(
                          icon: Icon(Icons.home), label: Text("Home", textDirection: TextDirection.ltr,)),
                      NavigationRailDestination(
                          icon: Icon(Icons.favorite), label: Text("Favorites"))
                    ],
              )),
              Expanded(
                  child: Container(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    child: page,
              ))
            ],
          ),
        );
      }
    );
  }
}

class FavoritesPage extends StatefulWidget{
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  @override
  Widget build(BuildContext context) {
    WordAppState wordState = context.watch<WordAppState>();
    final theme = Theme.of(context);

    if(wordState.favoriteWords.isEmpty){
      return const Center(child: Text("No favorites yet!"));
    }

    return Center(
      child: ListView(
        children:  [
          const SizedBox(height: 10),
          ListTile(title: Text("Your favorites (${wordState.favoriteWords.length}): "),leading: const Icon(Icons.list_alt)),
          const SizedBox(height: 10),
          Column(children:
          wordState.favoriteWords.map((word)=>
            ListTile(
              title: Text("${word.first} ${word.second}"),
              leading: const Icon(Icons.delete),
              onTap: () {setState(() {
                wordState.favoriteWords.remove(word);
              });},
        )).toList())
        ]
      ),
    );
  }
}

/// Home Page for application
class WordGeneratorPage extends StatelessWidget {
  const WordGeneratorPage({super.key});

  @override
  Widget build(BuildContext context) {
    WordAppState appState = context.watch<WordAppState>();
    WordPair wordPair = appState.currentWord;
    IconData favoriteIcon;
    if (appState.favoriteWords.contains(wordPair)) {
      favoriteIcon = Icons.favorite;
    } else {
      favoriteIcon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(wordPair: wordPair),
          const SizedBox(height: 10),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                  icon: Icon(favoriteIcon),
                  onPressed: () {
                    appState.toggleFavorite();
                  },
                  label: const Text("Like")),
              ElevatedButton(
                  onPressed: () {
                    appState.getNextWord();
                  },
                  child: const Text("Next word!")),
            ],
          )
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.wordPair,
  });

  final WordPair wordPair;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displaySmall?.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text("${wordPair.first} ${wordPair.second}", style: textStyle),
      ),
    );
  }
}
