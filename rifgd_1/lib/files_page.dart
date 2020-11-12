import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'google_auth_client.dart';
import 'image_file_data.dart';

class FilesPage extends StatefulWidget {
  FilesPage({Key key}) : super(key: key);

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  signIn.GoogleSignInAccount account;
  ga.FileList list;
  List<ImageFileData> imagesFiles = [];
  int filesDownloaded = 0;
  int numPart = 0;
  bool isStartDownload = false;
  bool isLoading = false;

  void _signIn() async {
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [ga.DriveApi.DriveScope]);
    account = await googleSignIn.signIn();
    setState(() {
      numPart = 1;
    });
    // print("User account $account");
  }

  Future<void> _downloadGoogleDriveFile(String fName, String gdID) async {
    File tmpFile;
    setState(() {
      isLoading = true;
    });
    var client = GoogleAuthClient(await account.authHeaders);
    var drive = ga.DriveApi(client);
    ga.Media file = await drive.files
        .get(gdID, downloadOptions: ga.DownloadOptions.FullMedia);
    // print(file.stream);
    final directory = await getExternalStorageDirectory();
    // print(directory.path);
    tmpFile = File(
        '${directory.path}/${new DateTime.now().millisecondsSinceEpoch}$fName');

    List<int> dataStore = [];
    file.stream.listen((data) {
      // print("DataReceived: ${data.length}");
      dataStore.addAll(data);
    }, onDone: () {
      // print("Task Done");

      tmpFile.writeAsBytesSync(dataStore);
      // print("File saved at ${imagesFiles[tmpIndex].file.path}");
      imagesFiles.add(ImageFileData(gdID, tmpFile));
      setState(() {
        filesDownloaded++;
      });
      setState(() {
        isLoading = false;
      });
    }, onError: (error) {
      // print("Some Error");
    });
  }

  Future<void> _downloadAllFiles() async {
    var length = list.files.length;
    for (int i = 0; i < length; i++) {
      if (list.files[i].name.substring(list.files[i].name.length - 3) ==
              'jpg' ||
          list.files[i].name.substring(list.files[i].name.length - 4) ==
              'jpeg' ||
          list.files[i].name.substring(list.files[i].name.length - 3) == 'png')
        await _downloadGoogleDriveFile(list.files[i].name, list.files[i].id);
      else
        setState(() {
          filesDownloaded++;
        });
    }
    setState(() {
      numPart = 4;
    });
  }

  Future<void> _showImage(String gdID) async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Oh sheet, you pressed button'),
          content: Image.file(
              imagesFiles.firstWhere((element) => element.id == gdID).file),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Back'),
              onPressed: () => Navigator.pop(context),
            )
          ],
        );
      },
    );
  }

  Future<void> _listGoogleDriveFiles() async {
    var client = GoogleAuthClient(await account.authHeaders);
    var drive = ga.DriveApi(client);
    drive.files
        .list(
      q: "'root' in parents",
    )
        .then((value) {
      setState(() {
        list = value;
        // await _downloadAllFiles();
        numPart = 2;
      });
    });
  }

  // Card buildCard(int index, int number) {
  //   return Card(
  //     child: Column(
  //       children: [
  //         Row(
  //           children: <Widget>[
  //             Expanded(
  //               flex: 1,
  //               child: Text('$number'),
  //             ),
  //             Expanded(
  //               flex: 13,
  //               child: Text(list.files[index].name),
  //             ),
  //           ],
  //         ),
  //         Row(
  //           mainAxisAlignment: MainAxisAlignment.start,
  //           children: [
  //             FlatButton(
  //               child: Text(
  //                 'Show image',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                 ),
  //               ),
  //               color: Colors.green[800],
  //               onPressed: () {
  //                 _showImage(list.files[index].id);
  //               },
  //             ),
  //             Padding(
  //               padding: EdgeInsets.only(
  //                   left: MediaQuery.of(context).size.width * 0.4),
  //               child: FlatButton(
  //                 child: Text(
  //                   'Download',
  //                   style: TextStyle(
  //                     color: Colors.white,
  //                   ),
  //                 ),
  //                 color: Colors.indigo,
  //                 onPressed: () {
  //                   _downloadGoogleDriveFile(
  //                       list.files[index].name, list.files[index].id);
  //                 },
  //               ),
  //             ),
  //           ],
  //         ),
  //       ],
  //     ),
  //   );
  // }

  Expanded buildPicture(String id) {
    return Expanded(
        child: FlatButton(
      child: Image.file(
          imagesFiles.firstWhere((element) => element.id == id).file),
      onPressed: () => _showImage(id),
    ));
  }

  Expanded buildGridView() {
    if (list != null)
      return Expanded(
        child: GridView.builder(
          itemCount: imagesFiles.length,
          gridDelegate:
              SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
          itemBuilder: (context, index) => buildPicture(imagesFiles[index].id),
        ),
      );
    else
      return Expanded(child: Container());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jeshe odno CHERTOVO prilogenije'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            numPart == 0
                ? FlatButton(
                    child: Text('1. sign in google'),
                    onPressed: _signIn,
                    color: Colors.green,
                  )
                : numPart == 1
                    ? FlatButton(
                        child: Text('2. list files'),
                        onPressed: _listGoogleDriveFiles,
                        color: Colors.green,
                      )
                    : numPart == 2
                        ? FlatButton(
                            child: Text('3. download files'),
                            onPressed: () {
                              _downloadAllFiles();
                              setState(() {
                                numPart = 3;
                              });
                            },
                            color: Colors.green,
                          )
                        : Container(),
            numPart == 4 ? buildGridView() : Container(),
            isLoading ? Text('loading...') : Container(),
            Text(
                'Downloaded $filesDownloaded/${list == null ? 0 : list.files.length} files'),
            // buildGridView(),
          ],
        ),
      ),
    );
  }
}
