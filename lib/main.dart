// main.dart
import 'dart:io';

import 'package:anya/web_view.dart';
import 'package:flutter/material.dart'; // Import the new WebViewPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ANYA ROBOTICS',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController macController = TextEditingController();
  TextEditingController portController = TextEditingController();

  String robotMacAddress = "";
  String robotIpAddress = "Fetching...";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ANYA ROBOTICS'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Robot IP Address:',
                style: TextStyle(fontSize: 18),
              ),
              SizedBox(height: 10),
              Text(
                robotIpAddress,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              _buildForm(),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _getRobotIpAddress();
                },
                child: Text('Get Robot IP Address'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  _navigateToWebViewPage();
                },
                child: Text('Open WebView'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _getRobotIpAddress() async {
    if (!validateInputs()) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please check your inputs')));
      return;
    }

    try {
      final interfaces = await NetworkInterface.list();
      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.address.isNotEmpty &&
              addr.type == InternetAddressType.IPv4) {
            setState(() {
              robotIpAddress = addr.address;
            });
            return;
          }
        }
      }
    } catch (e) {
      print('Error fetching IP address: $e');
      setState(() {
        robotIpAddress = "Error fetching IP address";
      });
    }
  }

  bool validateInputs() {
    if (robotMacAddress.isEmpty) {
      _showValidationError("Please enter Robot MAC Address.");
      return false;
    }

    if (!isValidMacAddress(robotMacAddress)) {
      _showValidationError("Please enter a valid MAC Address.");
      return false;
    }

    if (portController.text.isEmpty) {
      _showValidationError("Please enter Port Number.");
      return false;
    }

    if (!isValidPortNumber(portController.text)) {
      _showValidationError("Please enter a valid Port Number.");
      return false;
    }

    return true;
  }

  void _navigateToWebViewPage() {
    if (validateInputs()) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WebViewPage(
            url: 'http://$robotIpAddress:${portController.text}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please check your inputs')));
    }
  }

  bool isValidMacAddress(String macAddress) {
    // You can implement a more specific validation logic if needed
    return RegExp(r'^([0-9A-Fa-f]{2}[:-]){5}([0-9A-Fa-f]{2})$')
        .hasMatch(macAddress);
  }

  bool isValidPortNumber(String portNumber) {
    // You can implement a more specific validation logic if needed
    return int.tryParse(portNumber) != null;
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Validation Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildForm() {
    return Column(
      children: [
        TextFormField(
          controller: macController,
          decoration: InputDecoration(labelText: 'Robot MAC Address'),
          onChanged: (value) {
            setState(() {
              robotMacAddress = value;
            });
          },
        ),
        TextFormField(
          controller: portController,
          decoration: InputDecoration(labelText: 'Port Number'),
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
