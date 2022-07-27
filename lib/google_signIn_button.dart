import 'package:flutter/material.dart';
import 'package:googleapi/loader.dart';
import 'package:googleapi/rounded_button.dart';

class GoogleSignInButton extends StatefulWidget {
  final Function() onPressed;
  const GoogleSignInButton({Key? key,required this.onPressed}) : super(key: key);

  @override
  _GoogleSignInButtonState createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton> {
  bool _isSigningIn = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: _isSigningIn
            ? Container(
                child: BottomLoader(),
              )
            : RoundedButton(
                text: 'Sign In With Google',
                onPressed: widget.onPressed
              ));
  }
}
