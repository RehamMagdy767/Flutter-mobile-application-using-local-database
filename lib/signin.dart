import 'package:ass1/JSON/users.dart';
import 'package:ass1/SQlite/database_helper.dart';
import 'package:ass1/profile.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login Page'),
        backgroundColor: const Color.fromARGB(255, 13, 13, 104),
        toolbarHeight: 85,
      ),
      body: const SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(left: 15.0, top: 23, right: 15),
          child: LoginForm(),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  bool islogg = false;
  final db = DatabaseHelper();
  login() async {
    var res = await db
        .authenticate(Users(userEmail: email.text, password: password.text));
    if (res == true) {
      if (!mounted) return;
      _showSuccessDialog();
    } else {
      setState(() {
        islogg = true;
      });
      _showFailureDialog();
    }
  } // Added for password visibility toggle

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: email,
            decoration: const InputDecoration(labelText: 'Email'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter your email';
              } else if (!_isFCIEmail(value)) {
                return 'Please Enter a valid FCI Email address';
              }

              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: password,
            obscureText: obscurePassword, // Password visibility toggle
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                child: Icon(
                  obscurePassword ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter your password';
              } else if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 36.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                login();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 13, 13, 104),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

void _showSuccessDialog() async {
  // Fetch the userName from the database based on the provided email
  String? userName = await db.getUserNameByEmail(email.text);
  
  if (userName != null) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("Login successful!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Profile(userName: userName),
                  ),
                );
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  } else {
    // Handle error if userName is not found
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Error"),
          content: const Text("Failed to retrieve user information."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}



  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Failure"),
          content: const Text("Login failed!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  bool _isFCIEmail(String email) {
    RegExp fciEmailPattern = RegExp(r'^[a-zA-Z0-9]+@stud\.fci-cu\.edu\.eg$');
    return fciEmailPattern.hasMatch(email);
  }
}
