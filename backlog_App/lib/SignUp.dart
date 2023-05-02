import 'package:backlog_app/main.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class SignUpAuthPage extends StatefulWidget {
  const SignUpAuthPage({Key? key}) : super(key: key);
  @override
  State<SignUpAuthPage> createState() => _SignUpAuthPageState();
}

class _SignUpAuthPageState extends State<SignUpAuthPage> {
  static const String screenTitle = 'Sign Up Test';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: screenTitle,
      home: Scaffold(
        appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: (){
                Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) =>  const LoginAuthPage())
                );
              },
            ),
            title: const Text(screenTitle)),
        body: const MyStatefulWidget(),
      ),
    );
  }
}

class MyStatefulWidget extends StatefulWidget{
  const MyStatefulWidget({Key?  key}) : super(key: key);
  @override
  State<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends State<MyStatefulWidget> {
  TextEditingController nameController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final dbREF = FirebaseDatabase.instance.ref("Users");
  @override
  Widget build(BuildContext context){
    return Padding(
        padding: const EdgeInsets.all(10),
        child: ListView(
          children: <Widget>[
            Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(10),
                child: const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 20),
                )),
            Container(
              padding: const EdgeInsets.all(10),
              child: TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Email',
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: TextField(
                obscureText: true,
                controller: passwordController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password',
                ),
              ),
            ),
            Container(
                height: 70,
                padding: const EdgeInsets.fromLTRB(10, 20, 10, 0),
                child: ElevatedButton(
                  child: const Text('Sign Up'),
                  onPressed: () {
                    Future<UserCredential> result = FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                        email: nameController.text,
                        password: passwordController.text);
                    result.then((value) {
                      String uID = FirebaseAuth.instance.currentUser!.uid
                          .toString();
                      Fluttertoast.showToast(msg: 'Successfully Signed up');
                      dbREF.child(uID).set({ // Users/UID
                        'UID': FirebaseAuth.instance.currentUser!.uid.toString()
                      });
                      dbREF.child("$uID/Lists").set({
                        DateTime.now().millisecondsSinceEpoch.toString() : {
                          'Episodes': "0 ",
                          'Title': "Welcome to Backlog",
                          'id': DateTime
                              .now()
                              .millisecondsSinceEpoch
                              .toString(),
                          'imgURL': 'https://creazilla-store.fra1.digitaloceanspaces.com/cliparts/13905/cute-fox-clipart-lg.png',
                          'numberOfEpisodes': '0',
                          'numberOfSeasons' : '0',
                          'onEpisode': 1,
                          'overview': 'Welcome to your Movie/TV show tracker',
                          'releaseDate': '',
                          'tvID': ''
                        },
                        });
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) =>  const LoginAuthPage())
                      );
                    }).catchError((error){
                      Fluttertoast.showToast(msg: 'Failed to Sign Up');
                      Fluttertoast.showToast(msg: error.toString());
                    });
                  })),
          ],
        )
    );
  }
}