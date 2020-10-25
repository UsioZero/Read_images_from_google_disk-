import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:google_sign_in/google_sign_in.dart' as signIn;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void _sign_in() async {
    final googleSignIn =
        signIn.GoogleSignIn.standard(scopes: [ga.DriveApi.DriveScope]);
    final signIn.GoogleSignInAccount account = await googleSignIn.signIn();
    print("User account $account");
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
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _sign_in,
        tooltip: 'Increment',
        child: Icon(Icons.people),
      ),
    );
  }
}
