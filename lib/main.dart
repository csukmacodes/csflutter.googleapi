import 'package:flutter/material.dart';
import 'package:googleapi/authentication.dart';
import 'package:googleapi/loader.dart';
import 'package:url_launcher/url_launcher.dart';

/**url to open google drive*/
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
      home: const MyHomePage(title: 'Flutter Google Sheet API'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              /**only info text at the top*/
              Text(
                infoText,
              ),

              /**check while the process is in progress
               * T= show circle loader
               * F= show button create spreadsheet*/
              isLoading ? BottomLoader() : btnCreateSheet()
            ],
          )),
    );
  }

  void showLoader(bool show) {
    /**set state loader*/
    setState(() {
      if (show)
        isLoading = true;
      else
        isLoading = false;
    });
  }

  Widget btnCreateSheet() {
    /**button for the process of creating a spreadsheet*/
    return Container(
      child: OutlinedButton(
        onPressed: () async {
          if (isSuccess) {
            /**if it is successful, open google drive via browser*/
            _launchUrl();
          } else {
            showLoader(true);
            /**process of creating spreadsheets*/
            await Authentication.sheetOpen();
            showLoader(false);
            setState(() {
              /**after successful creating spreadsheets, modify info value*/
              isSuccess = true;
              infoText = "Google Sheet Successfully Create";
            });
          }
        },
        /**change text depending on value isSuccess*/
        child: Text(isSuccess ? 'Open Sheet' : 'Create Sheet'),
      ),
    );
  }

  Future<void> _launchUrl() async {
    /**browser launcher*/
    if (!await launchUrl(_url)) {
      throw 'Could not launch $_url';
    }
  }
}
