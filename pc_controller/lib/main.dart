import 'package:flutter/material.dart';
import 'package:pc_controller/control.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pc_controller/control.dart';
import 'dart:io';
import 'dart:convert';
import 'package:wake_on_lan/wake_on_lan.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class Computer {
  final String name;
  final String addr;
  Computer(this.name, this.addr);
}

class _MyHomePageState extends State<MyHomePage> {
  // name@ip:port
  // final List<String> computers = [];
  final List<Computer> computers = [];
  RawDatagramSocket? _socket;

  // Future<void> _saveSettings() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   // await prefs.setString('ip', '192.168.221.111:12345');
  //   await prefs.setStringList('computers', computers);
  // }

  // Future<void> _readSettings() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   final value = prefs.getString('ip');
  //   setState(() {
  //     ip = value ?? ' ';
  //   });
  // }

  Future<void> _initUdpSocket() async {
    try {
      _socket = await RawDatagramSocket.bind(InternetAddress.anyIPv4, 0);
    } on SocketException catch(e) {
      print('Error occurred when creating RawDatagramSocket: $e');
    }
  }

  void wakeup() async {
    String mac = 'C8:D3:FF:E7:B5:30';
    String ipv4 = '225.225.225.225';
    String password = '00:11:22:33:44:55';

    final macValidation = MACAddress.validate(mac);
    final ipValidation = IPAddress.validate(ipv4, type: InternetAddressType.IPv4);
    final passwordValidation = SecureONPassword.validate(password);

    if(macValidation.state && ipValidation.state && passwordValidation.state) {
      MACAddress macAddress = MACAddress(mac);
      IPAddress ipAddress = IPAddress(ipv4, type: InternetAddressType.IPv4);
      // SecureONPassword secureOnPassword = SecureONPassword(password);

      WakeOnLAN wakeOnLan = WakeOnLAN(ipAddress, macAddress, port:40000);
      print("start wakeup");
      await wakeOnLan.wake(
        repeat: 3,
        repeatDelay: const Duration(milliseconds: 500),
      );
      print("wakeup end");
    }
  }

  void shutdown() {
    Map<String, dynamic> message = {
      'type': 'command',
      'action': 'shutdown',
      'data': '',
    };
    var encodeMsg = utf8.encode(json.encode(message));
    try {
      _socket!.send(encodeMsg, InternetAddress('10.1.1.226'), 10088);
    } catch (e) {
      print('send data failed! $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _initUdpSocket();
    computers.add(Computer("Susie家", "192.168.221.222:12345"));
    // _readSettings();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center (
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MaterialButton(
              shape: const CircleBorder(),
              color: Colors.green,
              onPressed: wakeup,
              child: const Icon(Icons.power_settings_new, color: Colors.white, size: 40),
            ),
            MaterialButton(
              shape: const CircleBorder(),
              color: Colors.red,
              onPressed: shutdown,
              child: const Icon(Icons.power_off, color: Colors.white, size: 40),
            ),
            MaterialButton(
              shape: const CircleBorder(),
              color: Colors.blue,
              onPressed: (){
                if (_socket != null) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ControlPage(socket: _socket!)));
                }
              },
              child: const Icon(Icons.mouse, color: Colors.white, size: 40,),
            ),
          ]
        ),
      )
      // body: ListView.builder(
      //   itemCount: computers.length,
      //   itemBuilder: (context, index) {
      //     return Card(
      //       child: Row(
      //         children: [
      //           // ListTile(
      //           //   title: Text(computers[index].name),
      //           //   subtitle: Text(computers[index].addr)),
      //           Text(computers[index].name, selectionColor: Colors.green),
      //           IconButton(onPressed: (){
      //             if (_socket != null) {
      //               Navigator.push(context, MaterialPageRoute(builder: (context) => ControlPage(socket: _socket!)));
      //             }
      //           }, icon: const Icon(Icons.start)),
      //           IconButton(onPressed: wakeup, icon: const Icon(Icons.edit)),
      //         ],
      //       ),
      //     );
      //   },
      // ),
    );
  }
}
