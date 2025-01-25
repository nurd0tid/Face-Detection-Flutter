import 'package:flutter/material.dart';
import 'register_screen.dart';
import 'verify_screen.dart';
import '../config/constants.dart'; // Import untuk DEFAULT_USER_ID

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Check if the user has registered by checking DEFAULT_USER_ID
    bool isUserRegistered = DEFAULT_USER_ID.isNotEmpty; // Assuming DEFAULT_USER_ID is a String

    return Scaffold(
      appBar: AppBar(
        title: const Text('Face Recognition App'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Show Register Face button only if the user is not registered
            if (isUserRegistered) 
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const RegisterScreen()),
                  );
                },
                child: const Text('Register Face'),
              ),
            const SizedBox(height: 20),
            // Always show Verify Face button
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const VerifyScreen()),
                );
              },
              child: const Text('Verify Face'),
            ),
          ],
        ),
      ),
    );
  }
}