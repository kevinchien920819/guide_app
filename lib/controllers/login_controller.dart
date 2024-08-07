import 'package:flutter/material.dart';
  import 'package:flutter_guide_app/pages/main_page.dart';
import 'package:get/get.dart';
import 'package:mysql1/mysql1.dart';
import '../databases/db_helper.dart';

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

  Future<void> login() async {
    isLoading.value = true;
    String email = emailController.text;
    String password = passwordController.text;

    try {
      DbHelper dbHelper = DbHelper();
      Results userResults = await dbHelper.getUser(email);

      if (userResults.isNotEmpty) {
        var user = userResults.first;
        if (user['password'] == password) {
          // 登錄成功，導航到個人化頁面
          isLoggedIn.value = true;
          Get.offAll(() => MainPage());
        } else {
          errorMessage.value = 'Incorrect password';
        }
      } else {
        errorMessage.value = 'User not found';
      }
    } catch (e) {
      errorMessage.value = 'An error occurred';
    } finally {
      isLoading.value = false;
    }
  }
}