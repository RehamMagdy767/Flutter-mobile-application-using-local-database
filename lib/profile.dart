import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:ass1/SQlite/database_helper.dart';
import 'package:ass1/JSON/users.dart';
import 'package:image_picker/image_picker.dart';

class Profile extends StatefulWidget {
  final String userName;
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  Profile({Key? key, required this.userName}) : super(key: key);

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;
  late Future<Users?> _userFuture;
  String? _selectedLevel;
  String? _selectedGender;
  late TextEditingController _nameController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;
  late TextEditingController _studentIdController;
  final _formKey = GlobalKey<FormState>();
  Uint8List? _image;
  File? selectedImage;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userFuture = widget._databaseHelper.getUser(widget.userName);
    _nameController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
    _studentIdController = TextEditingController();

    _userFuture.then((user) {
      if (user != null) {
        setState(() {
          _nameController.text = user.userName ?? '';
          _selectedLevel = user.level;
          _selectedGender = user.gender;
          _passwordController.text = user.password ?? '';
          _confirmPasswordController.text = user.password ?? '';
          _studentIdController.text = user.userid.toString();
          _image = user.image;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(left: 70),
          child: Text('Edit Profile'),
        ),
        actions: [],
      ),
      body: FutureBuilder<Users?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData && snapshot.data != null) {
            return SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          _image != null
                              ? CircleAvatar(
                                  radius: 100,
                                  backgroundImage: MemoryImage(_image!))
                              : const CircleAvatar(
                                  radius: 70,
                                  backgroundImage: NetworkImage(
                                      "https://cdn.pixabay.com/photo/2015/10/05/22/37/blank-profile-picture-973460_960_720.png"),
                                ),
                          Positioned(
                            right: -11,
                            bottom: -11,
                            child: IconButton(
                              onPressed: () {
                                showImagePickerOption(context);
                              },
                              icon: const Icon(Icons.add_a_photo),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(labelText: 'Name'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a valid name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        initialValue: snapshot.data!.userEmail ?? '',
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Email'),
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _studentIdController,
                        readOnly: true,
                        decoration: InputDecoration(labelText: 'Student ID'),
                      ),
                      SizedBox(height: 16.0),
                      DropdownButtonFormField<String>(
                        value: _selectedLevel,
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedLevel = newValue;
                          });
                        },
                        items: ['1', '2', '3', '4'].map((level) {
                          return DropdownMenuItem<String>(
                            value: level,
                            child: Text(level),
                          );
                        }).toList(),
                        decoration: InputDecoration(labelText: 'Level'),
                      ),
                      SizedBox(height: 16.0),
                      Padding(
                        padding: const EdgeInsets.only(right: 312),
                        child: Text('Gender'),
                      ),
                      Row(
                        children: [
                          Radio<String>(
                            value: 'Male',
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                          Text('Male'),
                          Radio<String>(
                            value: 'Female',
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                          Text('Female'),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: !_showPassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          suffixIcon: IconButton(
                            icon: Icon(_showPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _showPassword = !_showPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a password';
                          } else if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 16),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: !_showConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
                          suffixIcon: IconButton(
                            icon: Icon(_showConfirmPassword
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              setState(() {
                                _showConfirmPassword = !_showConfirmPassword;
                              });
                            },
                          ),
                        ),
                        validator: (value) {
                          if (value != _passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            // Prepare the updated user object
                            Users updatedUser = Users(
                              userName: _nameController.text,
                              level: _selectedLevel ?? '',
                              gender: _selectedGender ?? '',
                              password: _passwordController.text,
                              userEmail: snapshot.data!.userEmail,
                              userid: snapshot.data!.userid,
                              image: _image ?? snapshot.data!.image,
                            );

                            // Update the user data in the database
                            int rowsAffected = await widget._databaseHelper
                                .updateUser(updatedUser);

                            if (rowsAffected > 0) {
                              // Data updated successfully
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('User data updated successfully'),
                                ),
                              );
                            } else {
                              // Failed to update data
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update user data'),
                                ),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 13, 13, 104),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 105, right: 105),
                          child: Text('Save Updates'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          } else {
            return Center(child: Text('No data available'));
          }
        },
      ),
    );
  }

  void showImagePickerOption(BuildContext context) {
    showModalBottomSheet(
        backgroundColor: Colors.blue[100],
        context: context,
        builder: (builder) {
          return Padding(
            padding: const EdgeInsets.all(18.0),
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height / 4.5,
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromGallery();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.image,
                              size: 70,
                            ),
                            Text("Gallery")
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        _pickImageFromCamera();
                      },
                      child: const SizedBox(
                        child: Column(
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 70,
                            ),
                            Text("Camera")
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Future _pickImageFromGallery() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (returnImage == null) return;
    setState(() {
      //The file path of the selected image is assigned to selectedImage
      selectedImage = File(returnImage.path);
      //reads the image bytes into a Uint8List and assigns it to _image
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }

  Future _pickImageFromCamera() async {
    final returnImage =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (returnImage == null) return;
    setState(() {
      selectedImage = File(returnImage.path);
      _image = File(returnImage.path).readAsBytesSync();
    });
    Navigator.of(context).pop();
  }
}
