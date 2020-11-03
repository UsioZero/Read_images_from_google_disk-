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

  void _signIn() async {
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [ga.DriveApi.DriveScope]);
    account = await googleSignIn.signIn();
    print("User account $account");
  }

  Future<void> _downloadGoogleDriveFile(String fName, String gdID) async {
    var client = GoogleAuthClient(await account.authHeaders);
    var drive = ga.DriveApi(client);
    ga.Media file = await drive.files.get(gdID);
    print(file.stream);

    final directory = await getExternalStorageDirectory();
    print(directory.path);
    final saveFile = File(
        '${directory.path}/${new DateTime.now().millisecondsSinceEpoch}$fName');
    List<int> dataStore = [];
    file.stream.listen((data) {
      print("DataReceived: ${data.length}");
      dataStore.insertAll(dataStore.length, data);
    }, onDone: () {
      print("Task Done");
      saveFile.writeAsBytes(dataStore);
      print("File saved at ${saveFile.path}");
    }, onError: (error) {
      print("Some Error");
    });
  }

  Future<void> _listGoogleDriveFiles() async {
    var client = GoogleAuthClient(await account.authHeaders);
    var drive = ga.DriveApi(client);
    drive.files.list(q: "'root' in parents").then((value) {
      setState(() {
        list = value;
      });
    });
    // drive.files.list(spaces: 'appDataFolder').then((value) {
    //   setState(() {
    //     list = value;
    //   });
    //   for (var i = 0; i < list.files.length; i++) {
    //     print("Id: ${list.files[i].id} File Name:${list.files[i].name}");
    //   }
    // });
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
            Expanded(flex: 10, child: buildGridView()),
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

  List<Widget> generateFilesWidget() {
    List<Widget> listItem = List<Widget>();
    if (list != null) {
      for (var i = 0; i < list.files.length; i++) {
        listItem.add(Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width * 0.05,
              child: Text('${i + 1}'),
            ),
            Expanded(
              child: Text(list.files[i].name),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
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
                      list.files[i].name, list.files[i].id);
                },
              ),
            ),
          ],
        ));
      }
    }
    return listItem;
  }

  ListView buildGridView() {
    if (list != null)
      return ListView.builder(
        itemCount: list.files.length,
        itemBuilder: (context, index) {
          return Card(
            child: Row(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width * 0.05,
                  child: Text('${index + 1}'),
                ),
                Expanded(
                  child: Text(list.files[index].name),
                ),
                Container(
                  width: MediaQuery.of(context).size.width * 0.3,
                  child: FlatButton(
                    child: Text(
                      'Download',
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    color: Colors.indigo,
                    onPressed: () {
                      // _downloadGoogleDriveFile(
                      //     list.files[index].name, list.files[index].id);
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    else
      return ListView.builder(itemBuilder: (context, index) {});
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
