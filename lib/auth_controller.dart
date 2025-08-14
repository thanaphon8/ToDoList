import 'package:get/get.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  // เก็บค่าผู้ใช้ปัจจุบันแบบจำลอง
  final RxString currentUserEmail = ''.obs;
  final RxBool isLoggedIn = false.obs;

  // mock user database
  final List<Map<String, String>> _userDB = [
    {'email': 'admin@gmail.com', 'password': '123456'},
  ];

  // ฟังก์ชันสมัครสมาชิก
  void register(String email, String password, BuildContext context) {
    final existingUser = _userDB.any((user) => user['email'] == email);

    if (existingUser) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('อีเมลนี้มีผู้ใช้แล้ว')));
      return;
    }

    _userDB.add({'email': email, 'password': password});

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('สมัครสมาชิกสำเร็จ')));
    Get.back(); // กลับไปหน้า login
  }

  // ฟังก์ชันเข้าสู่ระบบ
  void login(String email, String password, BuildContext context) {
    final foundUser = _userDB.firstWhereOrNull(
      (user) => user['email'] == email && user['password'] == password,
    );

    if (foundUser != null) {
      currentUserEmail.value = email;
      isLoggedIn.value = true;
      Get.offAllNamed('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('อีเมลหรือรหัสผ่านไม่ถูกต้อง')),
      );
    }
  }

  // ออกจากระบบ
  void logout() {
    currentUserEmail.value = '';
    isLoggedIn.value = false;
    Get.offAllNamed('/login');
  }
}
