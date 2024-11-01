import 'package:flutter/material.dart';
import 'dart:convert';

class HelpPage extends StatelessWidget {
  static const String _jsonData = '''
[
  {
    "title": "How to use the app",
    "content": "This is a detailed explanation of how to use the app..."
  },
  {
    "title": "Account settings",
    "content": "Here's how you can manage your account settings..."
  }
]
''';

  @override
  Widget build(BuildContext context) {
    List<dynamic> helpItems = json.decode(_jsonData);

    return Scaffold(
      appBar: AppBar(
        title: Text('Help'),
      ),
      body: ListView.builder(
        itemCount: helpItems.length,
        itemBuilder: (context, index) {
          return ExpansionTile(
            title: Text(helpItems[index]['title']),
            children: [
              Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(helpItems[index]['content']),
              ),
            ],
          );
        },
      ),
    );
  }
}

class HelpButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      icon: Icon(Icons.help, size: 24),
      label: Text('Help'),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => HelpPage(),
          ),
        );
      },
    );
  }
}

// Usage example:
// // In your widget tree:
// HelpButton()