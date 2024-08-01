import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var isLoggedIn = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void login() {
    isLoading.value = true;
    errorMessage.value = '';

    // 模拟登录请求
    Future.delayed(const Duration(seconds: 2), () {
      if (emailController.text == 'test' && passwordController.text == '123') {
        isLoading.value = false;
        isLoggedIn.value = true;
        Get.snackbar('Success', 'Login successful', backgroundColor: Colors.green);
        Get.offAllNamed('/home'); // 导航到主页
      } else {
        isLoading.value = false;
        errorMessage.value = 'Invalid email or password';
        Get.snackbar('Error', errorMessage.value, backgroundColor: Colors.red);
      }
    });
  }
}
