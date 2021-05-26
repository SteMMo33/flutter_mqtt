# flutter_mqtt

A Flutter test application for MQTT

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.


MQTT
--

Articles:
https://www.fatalerrors.org/a/using-mqtt-in-a-flutter-project.html


Plugin
------
https://pub.dev/packages/mqtt_client



Test
--
$ mosquitto_sub -h test.mosquitto.org -p 1883 -t stemmo21/#

$ mosquitto_pub -h test.mosquitto.org -p 1883 -t stemmo21/21 -m Ciao



