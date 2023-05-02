import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
class ForgotScreen extends StatefulWidget {
  const ForgotScreen({Key? key}) : super(key: key);

  @override
  State<ForgotScreen> createState() => _ForgotScreenState();
}

class _ForgotScreenState extends State<ForgotScreen> {
  final auth = FirebaseAuth.instance;
  final emailController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Forgot Password"),
      ),
      body:  Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child:  Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TextField(
             controller: emailController,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: OutlineInputBorder()
              )
            ) ,
            const SizedBox(height: 40),
            ElevatedButton(onPressed: (){
              if(emailController.text.toString() == ""){
                Fluttertoast.showToast(msg: 'Please Enter a valid Email');
              }
              else {auth.sendPasswordResetEmail(email: emailController.text.toString()).then((value){
                Fluttertoast.showToast(
                    msg: 'We have sent you an email to recover your password, please check your email');
              }).onError((error, stackTrace){
                Fluttertoast.showToast(msg: 'If that emails exists in our records an email has been sent');
              });
            }},
                child: const Text("Reset Password"))
          ],
        ),
      ),
    );
  }
}
