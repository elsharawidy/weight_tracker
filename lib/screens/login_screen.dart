import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

import '../shared/providers/user_provider.dart';
import 'home_page.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Lottie.network(
          'https://assets1.lottiefiles.com/packages/lf20_y7qo8rnh.json',
          height: 300),
      const SizedBox(
        height: 16,
      ),
      Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ElevatedButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(
              Colors.black,
            ),
            padding: MaterialStateProperty.all(const EdgeInsets.all(8)),
            side: MaterialStateProperty.all(const BorderSide(
              color: Colors.transparent,
              width: 1,
            )),
            elevation: MaterialStateProperty.all(8),
            shape: MaterialStateProperty.all(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          onPressed: () async {
            try {
              await context.read<UserProvider>().login().then((value) =>
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const HomePage()),
                      (route) => false));
            } on FirebaseAuthException catch (e) {
              switch (e.code) {
                case "operation-not-allowed":
                  print("Anonymous auth hasn't been enabled for this project.");
                  break;
                default:
                  print("Unknown error.");
              }
            }
          },
          child: const FittedBox(
            child: Text(
              'Sign-In',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    ]));
  }
}
