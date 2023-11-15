import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';
import 'package:nfc_sample/card_dao.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NFC Reader',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? searchId;
  CardDto? card;

  @override
  void initState() {
    super.initState();
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      MifareClassic? mifare = MifareClassic.from(tag);
      if (mifare == null) {
        return;
      }
      final id = toString(mifare.identifier);
      final maybeCard = await CardDao().readById(id);
      if (maybeCard == null) {
        setState(() {
          searchId = id;
        });
      } else {
        setState(() {
          card = maybeCard;
        });
      }
    });
  }

  void clear() {
    setState(() {
      searchId = null;
      card = null;
    });
  }

  void addCard(String id, String owner) async {
    final card = CardDto(id: id, owner: owner);
    await CardDao().create(card);
    clear();
  }

  void removeCard(String id) async {
    await CardDao().delete(id);
    clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(32),
        child: searchId == null && card == null
            ? const Center(child: Text('Please touch your card'))
            : card != null
                ? _CardWidget(card: card!, removeCard: removeCard, clear: clear)
                : _NotExistsCardWidget(
                    id: searchId!, clear: clear, addCard: addCard),
      ),
    );
  }
}

class _CardWidget extends StatelessWidget {
  final CardDto card;
  final Function(String id) removeCard;
  final Function() clear;
  const _CardWidget(
      {required this.card, required this.removeCard, required this.clear});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Id: ${card.id}'),
          Text('Owner: ${card.owner}'),
          OutlinedButton(
            onPressed: () => removeCard(card.id),
            child: const Text('remove card'),
          ),
          OutlinedButton(
            onPressed: clear,
            child: const Text('back'),
          )
        ],
      ),
    );
  }
}

class _NotExistsCardWidget extends StatefulWidget {
  final String id;
  final Function() clear;
  final Function(String id, String owner) addCard;
  const _NotExistsCardWidget(
      {required this.id, required this.clear, required this.addCard});

  @override
  State<_NotExistsCardWidget> createState() => _NotExistsCardWidgetState();
}

class _NotExistsCardWidgetState extends State<_NotExistsCardWidget> {
  var inputText = '';

  void changeText(String text) {
    setState(() {
      inputText = text;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Not Found Id: ${widget.id}'),
          const SizedBox(height: 16),
          TextField(
            onChanged: changeText,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
            ),
          ),
          OutlinedButton(
            onPressed: () => widget.addCard(widget.id, inputText),
            child: const Text('add card'),
          ),
          OutlinedButton(
            onPressed: widget.clear,
            child: const Text('back'),
          ),
        ],
      ),
    );
  }
}

List<int> fromString(String idStr) {
  return idStr.split('-').map((e) => int.parse(e)).toList();
}

String toString(List<int> id) {
  return id.map((e) => e.toRadixString(16).padLeft(2, '0')).join('-');
}
