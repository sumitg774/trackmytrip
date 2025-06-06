import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInAnonymously() async {
    try {
      await _auth.signInAnonymously();
    } catch (e) {
      print('Sign in error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Trip Tracker')),
      body: Center(
        child: user == null
            ? ElevatedButton(
          onPressed: signInAnonymously,
          child: const Text('Sign In Anonymously'),
        )
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Signed in as: ${user.uid}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // We'll implement this later
                Navigator.pushNamed(context, '/trip');
              },
              child: const Text('Start Trip'),
            ),
          ],
        ),
      ),
    );
  }
}
