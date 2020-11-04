import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:google_sign_in/google_sign_in.dart' as signIn;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';

import 'GoogleAuthClient.dart';

class FilesPage extends StatefulWidget {
  FilesPage({Key key}) : super(key: key);

  @override
  _FilesPageState createState() => _FilesPageState();
}

class _FilesPageState extends State<FilesPage> {
  var fileId;
  signIn.GoogleSignInAccount account;
  ga.FileList list;
  File fileSaveImage;

  void _signIn() async {
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [ga.DriveApi.DriveScope]);
    account = await googleSignIn.signIn();
    print("User account $account");
  }

  Future<void> _downloadGoogleDriveFile(String fName, String gdID) async {
    var client = GoogleAuthClient(await account.authHeaders);
    var drive = ga.DriveApi(client);
    ga.Media file = await drive.files
        .get(gdID, downloadOptions: ga.DownloadOptions.FullMedia);
    print(file.stream);

    final directory = await getExternalStorageDirectory();
    print(directory.path);
    fileSaveImage = File(
        '${directory.path}/${new DateTime.now().millisecondsSinceEpoch}$fName');
    List<int> dataStore = [];
    file.stream.listen((data) {
      print("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      print("Task Done");
      fileSaveImage.writeAsBytes(dataStore);
      print("File saved at ${fileSaveImage.path}");
    }, onError: (error) {
      print("Some Error");
    });
  }

  Future<void> _showImage() async {
    showCupertinoDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Oh sheet, you pressed button'),
          content: Image.file(fileSaveImage),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Add'),
              onPressed: () {},
            ),
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
      });
    });
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
            FlatButton(
              child: Text('List Google Drive Files'),
              onPressed: _listGoogleDriveFiles,
              color: Colors.green,
            ),
            buildGridView(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _signIn,
        tooltip: 'Increment',
        child: Icon(Icons.people),
      ),
    );
  }

  Expanded buildGridView() {
    if (list != null)
      return Expanded(
        child: ListView.builder(
          itemCount: list.files.length,
          itemBuilder: (context, index) {
            return list.files[index].name
                            .substring(list.files[index].name.length - 3) ==
                        'jpg' ||
                    list.files[index].name
                            .substring(list.files[index].name.length - 4) ==
                        'jpeg' ||
                    list.files[index].name
                            .substring(list.files[index].name.length - 3) ==
                        'png'
                ? buildCard(index)
                : Container();
          },
        ),
      );
    else
      return Expanded(child: Container());
  }

  Card buildCard(int index) {
    return Card(
      child: Column(
        children: [
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text('${index + 1}'),
              ),
              Expanded(
                flex: 13,
                child: Text(list.files[index].name),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              FlatButton(
                child: Text(
                  'Show image',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                color: Colors.green[800],
                onPressed: () {
                  _showImage();
                },
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.4),
                child: FlatButton(
                  child: Text(
                    'Download',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  color: Colors.indigo,
                  onPressed: () {
                    _downloadGoogleDriveFile(
                        list.files[index].name, list.files[index].id);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // FutureBuilder buildImagesFuture(int index) {
  //   return FutureBuilder(
  //       future: picturesList[index].thumbData,
  //       builder: (context, snapshot) {
  //         if (snapshot.connectionState == ConnectionState.done)
  //           return FlatButton(
  //             child: Image.memory(snapshot.data),
  //             onPressed: () {},
  //           );
  //         return Container();
  //       },
  //     );
  // }
}
