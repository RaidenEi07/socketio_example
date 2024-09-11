import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class InstrumentInfo {
  final String name;
  final String type;

  InstrumentInfo({required this.name, required this.type});

  @override
  String toString() {
    return '$name ($type)';
  }
}

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<InstrumentInfo?> _instrumentInfoList = [];
  late io.Socket _socket;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInstrumentInfo();
      _initializeSocket();
    });
  }

  Future<void> _loadInstrumentInfo() async {
    // Load instrument info from cache or API
    _instrumentInfoList = await CacheDataManager.instance.instrumentInfoList;
    setState(() {
      _isLoading = false; // Update loading state
    });
  }

  void _initializeSocket() {
    const String baseUrl = 'trading.agr.vn';
    const String path = 'trading.agr.vn/market/socket.io/';

    _socket = io.io(
      baseUrl,
      io.OptionBuilder()
          .setQuery({
        '__sails_io_sdk_version': '1.2.1',
        '__sails_io_sdk_platform': 'flutter',
        '__sails_io_sdk_language': 'dart'
      })
          .setTimeout(100000)
          .setTransports(['websocket'])
          .setPath(path)
          .enableAutoConnect()
          .build(),
    );

    _socket.onConnect((_) {
      print('Socket connected');
    });

    _socket.onError((data) {
      print('Socket error: $data');
    });

    _socket.onConnectError((data) {
      print('Socket connection error: $data');
    });

    _socket.onDisconnect((_) {
      print('Socket disconnected');
    });
  }

  @override
  void dispose() {
    if (_socket != null) {
      _socket.dispose(); // Clean up the socket connection
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Instrument Info'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _instrumentInfoList.length,
        itemBuilder: (context, index) {
          final instrument = _instrumentInfoList[index];
          return ListTile(
            title: Text(instrument?.toString() ?? 'No Data'),
          );
        },
      ),
    );
  }
}

class CacheDataManager {
  static final CacheDataManager _instance = CacheDataManager._internal();

  static CacheDataManager get instance => _instance;

  CacheDataManager._internal();

  Future<List<InstrumentInfo?>> get instrumentInfoList async {
    await Future.delayed(Duration(seconds: 2));
    return [
      InstrumentInfo(name: 'Alo', type: 'String'),
      InstrumentInfo(name: 'bang bang', type: 'Keyban'),
      InstrumentInfo(name: 'Drum', type: 'Percussion'),
    ];
  }
}

// Main function to run the app
void main() {
  runApp(MaterialApp(
    home: MyWidget(),
  ));
}
