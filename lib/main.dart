import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';
import 'dart:math';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) => MaterialApp(home: MyHomePage(),debugShowCheckedModeBanner: false,);
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _textController = TextEditingController();

  late Uint8List _imageData = Uint8List(0);
  bool _isLoading = false; // Add this line


  void _convertTextToImage() async {
    setState(() {
      _isLoading = true;
    });

    const baseUrl = 'https://api.stability.ai';
      final List<String> phrases = ['black tulip', 'dark', 'ink', 'health', 'spiritual'];
  
  // Generate a random number between 1 and the length of the array
      int randomCount = Random().nextInt(phrases.length) + 1;
      
      // Shuffle the array to randomize the order of the phrases
      phrases.shuffle();
      
      // Select a random subset of the array and join the items into a string
      String randomString = phrases.take(randomCount).join(', ');
    final url = Uri.parse(
        '$baseUrl/v1alpha/generation/stable-diffusion-512-v2-0/text-to-image');

    // Make the HTTP POST request to the Stability Platform API
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer sk-dXm7DtUnSxg7Psd957ibYbriyonEbXwgwZfOxBmq1OojghoJ',
        'Accept': 'image/png',
      },
      body: jsonEncode({
        'cfg_scale': 7,
        'clip_guidance_preset': 'FAST_BLUE',
        'height': 512,
        'width': 512,
        'samples': 1,
        'steps': 50,
        'text_prompts': [
          {
            'text': randomString, 
            'weight': 1,
          }
        ],
      }),
    );

    setState(() {
      _isLoading = false;
    });

    if (response.statusCode != 200) {
      _showErrorDialog('Failed to generate image');
    }
    else {
      try {
        _imageData = (response.bodyBytes);
        setState(() {});
      } on Exception
      catch (e){
        _showErrorDialog('Failed to generate image');
      }
    }
  }

  @override
  Widget build(BuildContext context) =>
      SafeArea(
        child: Scaffold(
          backgroundColor:Colors.black54,
          appBar: AppBar(title: const Text('Black Tulip Image Generation'),centerTitle: true,backgroundColor: Colors.lightBlue,

          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 30,),
              Container(
                width: 250,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,

                  ),
                  onPressed: _convertTextToImage,
                  child: _isLoading
                      ? const SizedBox(height:30, width:30,child: CircularProgressIndicator(color: Colors.redAccent))
                      : const Text('Generate Image'),
                ),
              ),
              SizedBox(height: 30,),
              if (_imageData != null) Image.memory(_imageData)
            ],
          ),
        ),
      );

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('Ok'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }
}