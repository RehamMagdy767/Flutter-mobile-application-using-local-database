import 'package:ass1/JSON/users.dart';
import 'package:ass1/SQlite/database_helper.dart';
import 'package:ass1/signin.dart';
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
      home: SignUpScreen(),
    );
  }
}

class SignUpScreen extends StatelessWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up Page'),
        backgroundColor: const Color.fromARGB(255, 13, 13, 104),
        toolbarHeight: 85,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(left: 15.0, top: 3, right: 15),
          child: Column(
            children: [
              SignUpForm(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Already have an account? ',
                    style: TextStyle(color: Colors.black),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    },
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpForm extends StatefulWidget {
  const SignUpForm({Key? key}) : super(key: key);

  @override
  _SignUpFormState createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController id = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController confirm = TextEditingController();
  String? gender;
  String? level;
  final _formKey = GlobalKey<FormState>();
  bool obscurePassword = true;
  final db = DatabaseHelper();
  signup() async {
    var res = await db.createUser(Users(
        userid: int.parse(id.text),
        userName: name.text,
        userEmail: email.text,
        level: level ?? " ",
        gender: gender ?? " ",
        password: password.text));
    if (res > 0) {
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } else {
      _showFailureDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: name,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
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
            controller: id,
            decoration: const InputDecoration(labelText: 'Student ID'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter your student ID';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: password,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Password',
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                child: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please Enter a password';
              } else if (value.length < 8) {
                return 'Password must be at least 8 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: confirm,
            obscureText: obscurePassword,
            decoration: InputDecoration(
              labelText: 'Confirm Password',
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() {
                    obscurePassword = !obscurePassword;
                  });
                },
                child: Icon(
                  obscurePassword ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey,
                ),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              } else if (value.length < 8) {
                return 'Confirm Password must be at least 8 characters';
              } else if (value != password.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 36.0),
          DropdownButton<String>(
            value: level,
            onChanged: (String? newValue) {
              setState(() {
                level = newValue;
              });
            },
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down_rounded),
            underline: Container(
              height: 2,
              color: const Color.fromARGB(59, 8, 15, 20),
            ),
            hint: Container(
              margin: const EdgeInsets.only(top: 2, bottom: 30),
              child: const Text(
                'Select Level',
              ),
            ),
            items: <String>['1', '2', '3', '4']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(height: 26.0),
          const Text(
            'Gender',
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 3.0),
          Row(
            children: [
              Radio<String>(
                value: 'Male',
                groupValue: gender,
                onChanged: (value) {
                  setState(() {
                    gender = value;
                  });
                },
              ),
              const Text('Male'),
              Radio<String>(
                value: 'Female',
                groupValue: gender,
                onChanged: (value) {
                  setState(() {
                    gender = value;
                  });
                },
              ),
              const Text('Female'),
            ],
          ),
          const SizedBox(height: 15.0),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                // All fields are valid, proceed with sign up
                _showSuccessDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 13, 13, 104),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
            ),
            child: const Text('Sign Up'),
          ),
        ],
      ),
    );
  }

  bool _isFCIEmail(String email) {
    RegExp fciEmailPattern = RegExp(r'^[a-zA-Z0-9]+@stud\.fci-cu\.edu\.eg$');
    return fciEmailPattern.hasMatch(email);
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Success"),
          content: const Text("Data stored successfully!"),
          actions: [
            TextButton(
              onPressed: () {
                signup();
                name.clear();
                email.clear();
                id.clear();
                password.clear();
                confirm.clear();
                gender = null;
                level = null;
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showFailureDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Failure"),
          content: const Text("Failed to insert data!"),
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
