import 'dart:typed_data';

class Users {
  final int? userid;
  final String? userName;
  final String? userEmail;
  final String? level;
  final String? gender;
  final String? password;
  final Uint8List? image; 

  Users({
    this.userid,
    this.userName,
    this.userEmail,
    this.level,
    this.gender,
    this.password,
    this.image, 
  });

  factory Users.fromMap(Map<String, dynamic> json) => Users(
        userid: json["userid"],
        userName: json["userName"],
        userEmail: json["userEmail"],
        level: json["level"],
        gender: json["Gender"],
        password: json["password"],
        image: json["image"], 
      );

  Map<String, dynamic> toMap() => {
        "userid": userid,
        "userName": userName,
        "userEmail": userEmail,
        "level": level,
        "Gender": gender,
        "password": password,
        "image": image, 
      };
}
