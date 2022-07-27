import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:googleapi/authentication.dart';
import 'package:googleapi/loader.dart';
import 'package:googleapi/rounded_button.dart';
import 'package:url_launcher/url_launcher.dart';

final Uri _url = Uri.parse('https://drive.google.com/drive/my-drive');

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  bool isSuccess = false;
  String infoText = "Google Sheet API";
  bool _isLoggedIn = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: FutureBuilder(
        future: Authentication.initializeFirebase(context: context),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('Error initializing Firebase');
          } else if (snapshot.connectionState == ConnectionState.done) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Text(
                  infoText,
                ),
                !_isLoggedIn
                    ? RoundedButton(
                        text: 'Sign In With Google',
                        onPressed: () async {
                          User? user = await Authentication.signInWithGoogle(
                              context: context);
                          if (user == null) {
                            setState(() {
                              _isLoggedIn = false;
                            });
                          } else {

                            setState(() {
                              infoText = 'Welcome ${user.displayName}\nGoogle Sheet API';
                              _isLoggedIn = true;
                            });
                          }
                        },
                      )
                    : Container(),
                _isLoggedIn ? btnCreateSheet() : Container()
              ],
            );
          }
          return BottomLoader();
        },
      )), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void showLoader(bool show) {
    setState(() {
      if (show)
        isLoading = true;
      else
        isLoading = false;
    });
  }

  Widget btnCreateSheet() {
    return Container(
      child: OutlinedButton(
        onPressed: () async {
          if (isSuccess) {
            _launchUrl();
          } else {
            showLoader(true);
            await Authentication.sheetOpen();
            showLoader(false);
            setState(() {
              isSuccess = true;
              infoText = "Google Sheet Successfully Create";
            });
          }
        },
        child: Text(isSuccess ? 'Open Sheet' : 'Create Sheet'),
      ),
    );
  }

  Future<void> _launchUrl() async {
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }
}
