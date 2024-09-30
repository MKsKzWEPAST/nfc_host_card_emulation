import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:nfc_host_card_emulation/nfc_host_card_emulation.dart';

late NfcState _nfcState;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  _nfcState = await NfcHce.checkDeviceNfcState();

  if (_nfcState == NfcState.enabled) {
    await NfcHce.init(
      aid: Uint8List.fromList([0xA0, 0x00, 0x00, 0x02, 0x47, 0x10, 0x01]),
      hello: 'Hello from Flutter!',
      jsonArrayByte: Uint8List.fromList([0x00]),
    );

    print("NFC is active.");
  }

  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String helloMessage = "";
  final TextEditingController _controller = TextEditingController();

  // JSON Fields Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // Function to convert JSON to byte array and set it
  Future<void> _setJsonData() async {
    // Gather data from text fields
    String name = _nameController.text;
    String country = _countryController.text;
    int age = int.tryParse(_ageController.text) ?? 0;
    double height = double.tryParse(_heightController.text) ?? 0.0;

    // Create a JSON object
    Map<String, dynamic> jsonData = {
      'name': name,
      'country': country,
      'age': age,
      'height': height,
    };

    // Encode the JSON to a string
    String jsonString = jsonEncode(jsonData);

    // Convert the JSON string to byte array
    Uint8List jsonBytes = Uint8List.fromList(utf8.encode(jsonString));

    // Set the byte array using NfcHce
    await NfcHce.setJsonArrayByte(jsonBytes);

    print("JSON data sent as bytes: $jsonString");
  }

  @override
  Widget build(BuildContext context) {
    final body = _nfcState == NfcState.enabled
        ? Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Text(
            'NFC State is ${_nfcState.name}',
            style: const TextStyle(fontSize: 20),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _controller,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Enter Color',
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await NfcHce.setHello(_controller.text);
              setState(() {
                helloMessage = _controller.text;
              });
            },
            child: const Text('Set Color'),
          ),
          if (helloMessage.isNotEmpty)
            Text(
              'Color: $helloMessage',
              style: const TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
          // Button to set JSON file
          ElevatedButton(
            onPressed: () {
              _showJsonInputDialog(context);
            },
            child: const Text('Set JSON File'),
          ),
        ],
      ),
    )
        : Center(
      child: Text(
        'Oh no...\nNFC is ${_nfcState.name}',
        style: const TextStyle(fontSize: 20),
        textAlign: TextAlign.center,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.green),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('NFC HCE example app'),
        ),
        body: body,
      ),
    );
  }

  // Function to display a dialog to enter JSON fields
  void _showJsonInputDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Enter JSON Data"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _countryController,
                decoration: const InputDecoration(labelText: 'Country'),
              ),
              TextField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Age'),
              ),
              TextField(
                controller: _heightController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Height'),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                _setJsonData();
                Navigator.of(context).pop(); // Close dialog
              },
              child: const Text('Set JSON'),
            ),
          ],
        );
      },
    );
  }
}