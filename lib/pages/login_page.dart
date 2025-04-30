import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ext/global.dart';
import 'package:ext/pages/dashboard_page.dart';
import 'package:ext/pages/registration_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Login',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: handleLogin,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Login',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: handleGuestLogin,
                child: const Text(
                  'Login as Guest',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 20),
              const Row(
                children: [
                  Expanded(child: Divider()),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text('OR'),
                  ),
                  Expanded(child: Divider()),
                ],
              ),
              const SizedBox(height: 20),
              // ElevatedButton.icon(
              //   onPressed: handleGoogleLogin,
              //   style: ElevatedButton.styleFrom(
              //     backgroundColor: Colors.red,
              //     padding: const EdgeInsets.symmetric(vertical: 16),
              //     shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(8),
              //     ),
              //   ),
              //   icon: const Icon(Icons.g_mobiledata, color: Colors.white),
              //   label: const Text(
              //     'Sign in with Google',
              //     style: TextStyle(fontSize: 16, color: Colors.white),
              //   ),
              // ),
              // const SizedBox(height: 20),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (context) => const RegistrationPage()),
                  );
                },
                child: const Text(
                  "Don't have an account? Register here",
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void handleLogin() async {
    final email = emailController.text;
    final password = passwordController.text;

    debugPrint('Login');
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email or password cannot be empty')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Password must be at least 6 characters long')),
      );
      return;
    }
    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      debugPrint('Login successful: ${userCredential.user?.email}');

      navigateHandle();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        debugPrint('No user found for that email.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No user found for that email.')),
        );
      } else if (e.code == 'wrong-password') {
        debugPrint('Wrong password provided for that user.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Wrong password provided for that user.')),
        );
      } else {
        debugPrint('Login failed: ${e.message}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login failed: ${e.message}')),
        );
      }
    } catch (e) {
      debugPrint('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void handleGuestLogin() async {
    try {
      final userCredential = await FirebaseAuth.instance.signInAnonymously();
      debugPrint('Guest login successful: ${userCredential.user?.uid}');
      Global.instance.isGuest = true;
      navigateHandle();
    } on FirebaseAuthException catch (e) {
      debugPrint('Guest login failed: ${e.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Guest login failed: ${e.message}')),
      );
    } catch (e) {
      debugPrint('An error occurred: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('An error occurred: $e')),
      );
    }
  }

  void navigateHandle() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString("userId");
    if (id != null && id.isEmpty) {
      debugPrint("ID: $id");
    } else {
      debugPrint("ID not found");
      prefs.setString("userId", FirebaseAuth.instance.currentUser?.uid ?? "");
    }
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const DashboardPage()),
    );
  }
  // void handleGoogleLogin() async {
  //   try {
  //     final googleUser = await GoogleSignIn().signIn();

  //     if (googleUser == null) {
  //       debugPrint('Google sign-in aborted by user.');
  //       return;
  //     }

  //     final googleAuth = await googleUser.authentication;

  //     final credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );

  //     final userCredential =
  //         await FirebaseAuth.instance.signInWithCredential(credential);

  //     debugPrint('Google sign-in successful: ${userCredential.user?.email}');

  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => const DashboardPage()),
  //     );
  //   } on FirebaseAuthException catch (e) {
  //     debugPrint('Google sign-in failed: ${e.message}');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Google sign-in failed: ${e.message}')),
  //     );
  //   } catch (e) {
  //     debugPrint('An error occurred: $e');
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('An error occurred: $e')),
  //     );
  //   }
  // }
}
