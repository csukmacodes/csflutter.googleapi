import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapi/google_auth_client.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart';

class Authentication {
  static String gSheetMime = "application/vnd.google-apps.spreadsheet";

  static Future<FirebaseApp> initializeFirebase({
    required BuildContext context,
  }) async {
    FirebaseApp firebaseApp = await Firebase.initializeApp();
    return firebaseApp;
  }

  static Future<User?> signInWithGoogle({required BuildContext context}) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;
    if (kIsWeb) {
      GoogleAuthProvider authProvider = GoogleAuthProvider();
      try {
        final UserCredential userCredential =
            await auth.signInWithPopup(authProvider);
        user = userCredential.user;
      } catch (e) {
        print(e);
      }
    } else {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      final GoogleSignInAccount? googleSignInAccount =
          await googleSignIn.signIn();

      if (googleSignInAccount != null) {
        final GoogleSignInAuthentication googleSignInAuthentication =
            await googleSignInAccount.authentication;

        final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleSignInAuthentication.accessToken,
          idToken: googleSignInAuthentication.idToken,
        );

        try {
          final UserCredential userCredential =
              await auth.signInWithCredential(credential);
          user = userCredential.user;
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'The account already exists with a different credential',
              ),
            );
          } else if (e.code == 'invalid-credential') {
            ScaffoldMessenger.of(context).showSnackBar(
              Authentication.customSnackBar(
                content:
                    'Error occurred while accessing credentials. Try again.',
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            Authentication.customSnackBar(
              content: 'Error occurred using Google Sign In. Try again.',
            ),
          );
        }
      }
    }

    return user;
  }

  static Future<void> sheetOpen() async {
    final googleSignIn = GoogleSignIn.standard(scopes: [
      SheetsApi.spreadsheetsScope,
      SheetsApi.driveFileScope,
      SheetsApi.driveScope,
    ]);
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    final authHeaders = await account?.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders!);
    var sheetID = await _createSpreadSheet(authenticateClient);
    _writeToSheet(authenticateClient, sheetID);
  }

  static Future _createSpreadSheet(GoogleAuthClient authenticateClient) async {
    final driveApi = drive.DriveApi(authenticateClient);
    var driveFile = new drive.File();
    driveFile.name = "hello_gsheetapi";
    driveFile.mimeType = gSheetMime;
    final result = await driveApi.files.create(driveFile);
    return result.id;
  }

  static _writeToSheet(GoogleAuthClient authenticateClient, String sheetID) {
    final sheetsApi = SheetsApi(authenticateClient);
    ValueRange vr = new ValueRange.fromJson({
      "values": [
        ["2022/07/05", "via Flutter", "5", "3", "3", "3", "3", "3", "3", "3"]
      ]
    });
    sheetsApi.spreadsheets.values
        .append(vr, sheetID, 'A:J', valueInputOption: 'USER_ENTERED')
        .then((AppendValuesResponse r) {
      print('append completed hello_gsheetapi');
    });
  }

  static SnackBar customSnackBar({required String content}) {
    return SnackBar(
      backgroundColor: Colors.black,
      content: Text(
        content,
        style: TextStyle(color: Colors.redAccent, letterSpacing: 0.5),
      ),
    );
  }
}
