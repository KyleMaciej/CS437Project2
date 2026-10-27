import 'package:flutter/material.dart';
import 'package:flutter_blue_app/AppPage.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:permission_handler/permission_handler.dart'; // Make sure permission_handler is in pubspec.yaml if you use it, or use flutter_bluetooth_serial's built-in check
import 'dart:convert';
import 'dart:typed_data';

import './ChatPage.dart';
//import './ChatPage2.dart';


class MainPage extends StatefulWidget {
  @override
  _MainPage createState() => new _MainPage();
}

class _MainPage extends State<MainPage> {


  bool connected = false;
  BluetoothDevice? _device;

  @override
  void initState() {
    super.initState();

    FlutterBluetoothSerial.instance
        .getBondedDevices()
        .then((List<BluetoothDevice> bondedDevices) {
     setState(() {
        for (BluetoothDevice device in bondedDevices) {
          if (device.name == "KyleRaspberryPi" || (device.name != null && device.name!.contains("Raspberry"))) {
            _device = device;
            print("Matched target device: ${device.name} (${device.address})");
            break; 
          }
        }
      });
    });
  }


  @override
  void dispose() {
    FlutterBluetoothSerial.instance.setPairingRequestHandler(null);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Demo'),
      ),
      body: Container(
        child: ListView(
          children: <Widget>[
            Divider(),
            ListTile(
                    title: Text("Device: " + (_device?.name ?? "No device selected")),
                    ),
            ListTile(
              title: ElevatedButton(
                child: const Text('Start Chat'),
                onPressed: () async {
                  if (_device != null) {
                    print('Connect -> selected ' + _device!.address);
                    _startApp(context, _device!);
                  } else {
                    print('Connect -> no device selected');
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  void _startApp(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AppPage(server: server);
        },
      ),
    );
  }

  void _startChat(BuildContext context, BluetoothDevice server) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ChatPage(server: server);
        },
      ),
    );
  }
}


// class MainPage extends StatefulWidget {
//   const MainPage({Key? key}) : super(key: key);

//   @override
//   _MainPage createState() => _MainPage();
// }

// class _MainPage extends State<MainPage> {
//   BluetoothDevice? _device;
//   BluetoothConnection? _connection;
//   bool _isConnecting = false;
//   bool get _isConnected => _connection != null && _connection!.isConnected;

//   final List<Message> _messages = [];
//   final TextEditingController _textController = TextEditingController();
//   final ScrollController _listScrollController = ScrollController();

//   @override
//   void initState() {
//     super.initState();
//     _requestPermissionsAndFindPi();
//   }

//   @override
//   void dispose() {
//     if (_isConnected) {
//       _connection!.dispose();
//     }
//     _textController.dispose();
//     super.dispose();
//   }

//   // 1. Permissions & Finding the Pi automatically
//   Future<void> _requestPermissionsAndFindPi() async {
//     bool permissionGranted = await _checkAndRequestPermissions();
//     if (!permissionGranted) return;

//     try {
//       List<BluetoothDevice> bondedDevices = await FlutterBluetoothSerial.instance.getBondedDevices();
      
//       setState(() {
//         for (BluetoothDevice device in bondedDevices) {
//           if (device.name == "KyleRaspberryPi" || (device.name != null && device.name!.contains("Raspberry"))) {
//             _device = device;
//             print("Matched target device: ${device.name} (${device.address})");
//             break; 
//           }
//         }
//       });

//       // Automatically connect once found if a device was matched
//       if (_device != null) {
//         _connectToPi();
//       }
//     } catch (e) {
//       print("Error fetching bonded devices: $e");
//     }
//   }

//   Future<bool> _checkAndRequestPermissions() async {
//     Map<Permission, PermissionStatus> statuses = await [
//       Permission.bluetoothConnect,
//       Permission.bluetoothScan,
//       Permission.location,
//     ].request();

//     return statuses[Permission.bluetoothConnect] == PermissionStatus.granted;
//   }

//   // 2. Connect to the Pi Socket
//   void _connectToPi() async {
//     if (_device == null) return;

//     setState(() {
//       _isConnecting = true;
//     });

//     try {
//       print("Connecting to ${_device!.address}...");
//       _connection = await BluetoothConnection.toAddress(_device!.address);
//       print("Connected to the Pi!");

//       setState(() {
//         _isConnecting = false;
//       });

//       // Listen for incoming data from the Pi server script
//       _connection!.input!.listen(_onDataReceived).onDone(() {
//         print("Disconnected by remote server");
//         setState(() {});
//       });
//     } catch (exception) {
//       print("Cannot connect, exception occurred: $exception");
//       setState(() {
//         _isConnecting = false;
//       });
//     }
//   }

//   // 3. Receive data from Pi
//   void _onDataReceived(Uint8List data) {
//     int backspacesCounter = 0;
//     data.forEach((byte) {
//       if (byte == 8 || byte == 127) {
//         backspacesCounter++;
//       }
//     });
//     Uint8List buffer = Uint8List(data.length - backspacesCounter);
//     int bufferIndex = subscriptBuffer(data, buffer);

//     String dataString = utf8.decode(buffer);
//     setState(() {
//       _messages.add(Message(text: dataString, isMe: false));
//     });
//   }

//   int subscriptBuffer(Uint8List data, Uint8List buffer) {
//     int bufferIndex = 0;
//     for (int i = 0; i < data.length; i++) {
//       if (data[i] != 8 && data[i] != 127) {
//         buffer[bufferIndex++] = data[i];
//       }
//     }
//     return bufferIndex;
//   }

//   // 4. Send message to Pi
//   void _sendMessage(String text) async {
//     text = text.trim();
//     if (text.isEmpty) return;

//     _textController.clear();

//     try {
//       _connection!.output.add(utf8.encode("$text\r\n") as Uint8List);
//       await _connection!.output.allSent;

//       setState(() {
//         _messages.add(Message(text: text, isMe: true));
//       });
//     } catch (e) {
//       print("Error sending message: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final List<Widget> list = _messages.map((msg) {
//       return Container(
//         padding: const EdgeInsets.all(8.0),
//         alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
//         child: Container(
//           padding: const EdgeInsets.all(10.0),
//           decoration: BoxDecoration(
//             color: msg.isMe ? Colors.blue[150] : Colors.grey[300],
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//           child: Text(msg.text),
//         ),
//       );
//     }).toList();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(_isConnected 
//           ? 'Connected to Pi' 
//           : (_device != null ? 'Found: ${_device!.name}' : 'Searching for Pi...')),
//         actions: [
//           IconButton(
//             icon: Icon(_isConnected ? Icons.link : Icons.link_off),
//             onPressed: _isConnected ? () => _connection?.close() : _connectToPi,
//           )
//         ],
//       ),
//       body: SafeArea(
//         child: Column(
//           children: <Widget>[
//             Flexible(
//               child: ListView(
//                 controller: _listScrollController,
//                 padding: const EdgeInsets.all(12.0),
//                 children: list,
//               ),
//             ),
//             Row(
//               children: <Widget>[
//                 Flexible(
//                   child: Container(
//                     margin: const EdgeInsets.symmetric(horizontal: 16.0),
//                     child: TextField(
//                       controller: _textController,
//                       decoration: const InputDecoration.collapsed(hintText: 'Type a message to Pi...'),
//                       enabled: _isConnected,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   margin: const EdgeInsets.symmetric(horizontal: 4.0),
//                   child: IconButton(
//                     icon: const Icon(Icons.send),
//                     onPressed: _isConnected ? () => _sendMessage(_textController.text) : null,
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// class Message {
//   final bool isMe;
//   final String text;
//   Message({required this.isMe, required this.text});
// }