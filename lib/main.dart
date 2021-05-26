import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
//import 'package:mqtt_client/mqtt_client.dart';
//import 'package:mqtt_client/mqtt_server_client.dart';
//import 'package:typed_data/typed_buffers.dart';



void main() {
  runApp(MyApp());
}



class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter MQTT',
      theme: ThemeData(
        // This is the theme of your application.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'MQTT Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String state = "init";
  String server = "server";
  String mqttMsg = "- -";

  MqttClient? _client;


  updateState(String newState){
    setState(() {
      state = newState;
    });
  }

  updateServer(String newServer){
    setState(() {
      server = newServer;
    });
  }

  updateMsg(String newMsg){
    setState(() {
      mqttMsg = newMsg;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text( 'Server: $server',   ),
            Text( 'State: $state',     ),
            Text( 'MQTT message:',     ),
            Text(
              mqttMsg,
              style: Theme.of(context).textTheme.headline5,
            ),
            ElevatedButton(onPressed: sendMqtt, child: Text('Send'))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: startMqtt,
        tooltip: 'MQTT',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }



  /// Invia un messaggio
  void sendMqtt(){

    if (_client==null){
      updateState("NON CONNESSO");
      return;
    }

    const pubTopic = 'stemmo21/app';

    final builder = MqttClientPayloadBuilder();
    builder.addString('Hello MQTT');

    _client?.publishMessage( pubTopic, MqttQos.atLeastOnce, builder.payload!);
  }

  /// Connessione al broker
  void startMqtt(){
    // Disconnette se attivo
    if (_client!=null) _client?.disconnect();

    updateState("connecting..");
    connect().then(
        (client) {
              _client = client;
              print(client.connectionStatus);
              client.subscribe("stemmo21/#", MqttQos.atLeastOnce);
        }
    );
  }

  Future<MqttServerClient> connect() async {

    // MqttServerClient client = MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 1883);
    //MqttServerClient client = MqttServerClient.withPort('broker.emqx.io', 'flutter_client', 8083);            // websocket ?
    //MqttServerClient client = MqttServerClient.withPort('broker.mqttdashboard.com', 'flutter_client', 8000);  // websocket ?
    MqttServerClient client = MqttServerClient.withPort('test.mosquitto.org', 'flutter_client', 1883);

    client.logging(on: false);  // Aggiunge scritte di debug nel terminale

    updateServer(client.server+":"+client.port.toString());

    // Callbacks
    client.onConnected = onConnected;
    client.onDisconnected = onDisconnected;
    client.onUnsubscribed = onUnsubscribed;
    client.onSubscribed = onSubscribed;
    client.onSubscribeFail = onSubscribeFail;
    // client.pongCallback = pong;

    final connMessage = MqttConnectMessage()
        // SM .authenticateAs('username', 'password')
        // SM deprecated .keepAliveFor(60)
        .withWillTopic('willtopic')
        .withWillMessage('Will message')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMessage;

    try {
      await client.connect();
    } catch (e) {
      print('Exception: $e');
      client.disconnect();
    }

    // In ascolto ..
    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {

      print("Lista n: ${c.length}");

      final message = c[0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message!);
      //print('Received message:$payload from topic: ${c[0].topic}>');

      String msg = "$payload da ${c[0].topic}";
      updateMsg(msg);
      updateState("RX");
    });

    return client;
  }

  void onConnected() {
    print("[MQTT] connect");
    updateState("CONNECTED");
  }

  void onDisconnected() {
    print("[MQTT] disconnect");
    updateState("DISCONNECTED");
  }

  void onSubscribed(String topic) {
    print("[MQTT] onSubscribed $topic");
    updateState("SUBSCRIBED");
  }

  void onSubscribeFail(String topic) {
    print("[MQTT] onSubscribeFail on $topic");
    updateState("SUBSCRIBED FAILED!");
  }

  void onUnsubscribed(String? topic) {
    print("[MQTT] onUnsubscribed from $topic");
  }

  void pong() {
    print("[MQTT] pong");
  }

}
