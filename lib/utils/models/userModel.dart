import 'package:flutter/material.dart';

class UserModel {
  final String userId;
  final String userName;
  final String profilePicUrl;
  UserModel({
    Key? key,
    required this.userId,
    required this.userName,
    required this.profilePicUrl,
  });
}

