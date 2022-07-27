import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapi/google_auth_client.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis/sheets/v4.dart';

class Authentication {
  /**set mime type for spreadsheet*/
  static String gSheetMime = "application/vnd.google-apps.spreadsheet";

  static Future<void> sheetOpen() async {
    /**scope for using google sheet api
     * for file storage, google drive api scope is needed */
    final googleSignIn = GoogleSignIn.standard(scopes: [
      SheetsApi.spreadsheetsScope,
      SheetsApi.driveFileScope,
      SheetsApi.driveScope,
    ]);

    /**sign in google account first
     * in this process will display an OAuth consent screen for user authentication */
    final GoogleSignInAccount? account = await googleSignIn.signIn();
    final authHeaders = await account?.authHeaders;
    final authenticateClient = GoogleAuthClient(authHeaders!);

    /** after successful login, proceed to create a spreadsheet file on Google Drive*/
    var sheetID = await _createSpreadSheet(authenticateClient);

    /** after successfully creating a spreadsheet file,
     * update the contents of the spreadsheet according to sheetid that has been created*/
    _writeToSheet(authenticateClient, sheetID);
  }

  static Future _createSpreadSheet(GoogleAuthClient authenticateClient) async {
    /**use DriveApi to create files*/
    final driveApi = drive.DriveApi(authenticateClient);
    var driveFile = new drive.File();

    /**set filename and mimetype*/
    driveFile.name = "hello_gsheetapi";
    driveFile.mimeType = gSheetMime;

    /**save file in google drive*/
    final result = await driveApi.files.create(driveFile);

    /**fileId created*/
    return result.id;
  }

  static _writeToSheet(GoogleAuthClient authenticateClient, String sheetID) {
    /**use SheetApi to modify files*/
    final sheetsApi = SheetsApi(authenticateClient);

    /**set content to modify as needed*/
    ValueRange vr = new ValueRange.fromJson({
      "values": [
        ["2022/07/05", "via Flutter", "5", "3", "3", "3", "3", "3", "3", "3"]
      ]
    });

    /**add content to the sheet file that has been created*/
    sheetsApi.spreadsheets.values
        .append(vr, sheetID, 'A:J', valueInputOption: 'USER_ENTERED')
        .then((AppendValuesResponse r) {
      print('append completed hello_gsheetapi');
    });
  }
}
