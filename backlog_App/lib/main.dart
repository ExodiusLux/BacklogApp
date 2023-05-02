import 'package:backlog_app/Backlog_FB.dart';
import 'package:backlog_app/ForgotScreen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'SignUp.dart';
import 'firebase_options.dart';
import 'package:fluttertoast/fluttertoast.dart';
void main ()  async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const LoginAuthPage());
}
class LoginAuthPage extends StatefulWidget {
  const LoginAuthPage({Key? key}) : super(key: key);
  @override
  State<LoginAuthPage> createState() => _LoginAuthPageState();
}

class _LoginAuthPageState extends State<LoginAuthPage> {
  static const String screenTitle = 'Your Helpful Movie/Show Tracker';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: screenTitle,
      home: Scaffold(
        appBar: AppBar(title: const Text(screenTitle)),
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
                'Backlog',
                    style: TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                      fontSize: 30
                    ),
            )
          ),
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
          TextButton(
            onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder:  (context) => const ForgotScreen()));
            },
            child: const Text('Forgot Password?'),
          ),
          Container(
              height: 50,
              padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
              child: ElevatedButton(
                child: const Text('Login'),
                onPressed: () {
                  Future<UserCredential> result = FirebaseAuth.instance.signInWithEmailAndPassword(email: nameController.text, password: passwordController.text);
                  result.then((value) {
                    Fluttertoast.showToast(msg: 'successfully signed in');
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  const MyFBBacklogList())
                    );
                  });
                  result.catchError((error){
                    Fluttertoast.showToast(msg: 'Failed to login');
                    Fluttertoast.showToast(msg: error.toString());
                  });
                },
              )
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Don't Have an account?"),
              TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) =>  const SignUpAuthPage()));
                  },
                child: const Text(
                  'Sign up',
                  style: TextStyle(fontSize: 15),
                ),
              ),
            ],
          )
        ],
      )
    );
  }
}