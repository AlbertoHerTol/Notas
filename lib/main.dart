import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'BD.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notas',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Notas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  DataBase BD = null;
  UserCredential user;
  String _linkImageProfile = "https://definicion.de/wp-content/uploads/2019/06/perfildeusuario.jpg";
  String _nameUser = "Anónimo";
  String mostrar="Inicio";


  @override
  void initState() {
    print("Init firebase");
    super.initState();
    Firebase.initializeApp().whenComplete(() {
      print("completed");

      signInWithGoogle().then((x){
        setState(() {
          user = x;
          print("EL USUARIO --> "+user.toString());
          _linkImageProfile = user.additionalUserInfo.profile["picture"].toString();
          _nameUser  = user.additionalUserInfo.profile["name"].toString();
          BD= new DataBase(user);
          //_idUser = user.additionalUserInfo.profile["aud"].toString();
        });
      });


    });
  }




  Future<UserCredential> signInWithGoogle() async {
    print("\n\n-----------------------------     ENTRANDO EN SignInWithGoogle");
    //login
    final GoogleSignIn _googleSignIn = GoogleSignIn();
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    print("?");
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
    print("?");
    final AuthCredential credential = GoogleAuthProvider.getCredential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );
    var user = await _auth.signInWithCredential(credential);
    print("\n\n-----------------------------     signed in " + user.toString());
    return user;
  }





  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      drawer: Drawer(
          child: ListView(
            children: <Widget>[
              //1 -------------------------
              DrawerHeader(
                child: ListView(
                    children:[
                      Image(
                        image: NetworkImage(_linkImageProfile),
                      ),
                      Text("Name: " + _nameUser),
                    ]
                ),
              ),
              // 3 -----------------------
              FlatButton(
                onPressed: (){
                  setState(() {
                    mostrar = "Uno";
                  });
                },
                child: Text("Ventana 1"),
              ),
              // 3 -----------------------
              FlatButton(
                onPressed: (){
                  setState(() {
                    mostrar = "Dos";
                  });
                },
                child: Text("Ventana 2"),
              )

            ],
          )
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(

          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text("Hola"),


          ],
        ),
      ),
      // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
