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
            colorScheme:
                ColorScheme.fromSeed(seedColor: Colors.lightBlueAccent)),
        home: const HomePage(),
      ),
    );
  }
}

class WordAppState extends ChangeNotifier {
  WordPair currentState = WordPair.random();

  void getNextWord(){
    currentState = WordPair.random();
    logger.i("Generated new word!");
    notifyListeners();
  }
}
/// Home Page for application
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<WordAppState>();
    return Scaffold(
        body: Column(
          children: [
            Container(margin: const EdgeInsets.only(top: 50.0)),
            const Text("Random Text:"),
            Text(appState.currentState.asLowerCase),
            ElevatedButton(onPressed: () { appState.getNextWord(); }, child: const Text("Next word!"))

          ],
    ));
  }
}
