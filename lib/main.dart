import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final titleProvider = Provider((_) => 'Startup Namer Generator');
final savedItemsProvider =
    StateNotifierProvider<SavedItems, Set<WordPair>>((ref) {
  return SavedItems(ref);
});
final itemsProvider = Provider((ref) => <WordPair>{});

class SavedItems extends StateNotifier<Set<WordPair>> {
  SavedItems(this.ref) : super({});

  final Ref ref;

  void save(WordPair pair) {
    final items = ref.read(itemsProvider);
    items.add(pair);
  }

  void remove(WordPair pair) {
    final items = ref.read(itemsProvider);
    items.remove(pair);
  }
}

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class RandomWords extends ConsumerStatefulWidget {
  const RandomWords({Key? key}) : super(key: key);

  @override
  _RandomWordsState createState() => _RandomWordsState();
}

class _RandomWordsState extends ConsumerState<RandomWords> {
  final _suggestions = <WordPair>[];
  final _biggerFont = const TextStyle(fontSize: 18);

  @override
  void initState() {
    super.initState();
    ref.read(savedItemsProvider);
  }

  void _pushSaved() {
    final saved = ref.watch(itemsProvider);

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) {
          final tiles = saved.map(
            (pair) {
              return ListTile(
                title: Text(
                  pair.asPascalCase,
                  style: _biggerFont,
                ),
              );
            },
          );
          final divided = tiles.isNotEmpty
              ? ListTile.divideTiles(context: context, tiles: tiles).toList()
              : <Widget>[];

          return Scaffold(
            appBar: AppBar(
              title: const Text('Saved Suggetions'),
            ),
            body: ListView(children: divided),
          );
        },
      ),
    );
  }

  Widget _buildSuggestions(WidgetRef ref) {
    return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, i) {
          if (i.isOdd) {
            return const Divider();
          }
          final index = i ~/ 2;
          if (index >= _suggestions.length) {
            _suggestions.addAll(generateWordPairs().take(10));
          }
          return _buildRow(_suggestions[index], ref);
        });
  }

  Widget _buildRow(WordPair pair, WidgetRef ref) {
    final alreadySaved = ref.watch(itemsProvider).contains(pair);

    return ListTile(
        title: Text(
          pair.asPascalCase,
          style: _biggerFont,
        ),
        trailing: Icon(
          alreadySaved ? Icons.favorite : Icons.favorite_border,
          color: alreadySaved ? Colors.red : null,
          semanticLabel: alreadySaved ? 'Remove from saved' : 'Save',
        ),
        onTap: () {
          setState(() {
            if (alreadySaved) {
              ref.read(savedItemsProvider.notifier).remove(pair);
            } else {
              ref.read(savedItemsProvider.notifier).save(pair);
            }
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: const Text('Startup Namer Generator'), actions: [
          IconButton(
            icon: const Icon(Icons.list),
            onPressed: _pushSaved,
            tooltip: 'Saved Suggestions',
          )
        ]),
        body: _buildSuggestions(ref));
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String value = ref.watch(titleProvider);

    return MaterialApp(
      title: value,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
        ),
      ),
      home: const RandomWords(),
    );
  }
}
