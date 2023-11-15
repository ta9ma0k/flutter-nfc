import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _owner;

  @override
  void initState() {
    super.initState();
    NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      MifareClassic? mifare = MifareClassic.from(tag);
      if (mifare == null) {
        return;
      }
      if (listEquals(mifare.identifier, [70, 203, 127, 221])) {
        setOwner('Okada Takuma');
      }
    });
  }

  void setOwner(String owner) {
    setState(() {
      _owner = owner;
    });
  }

  void clearOwner() {
    setState(() {
      _owner = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Owner:',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(
              _owner ?? 'Unknown',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }
}
