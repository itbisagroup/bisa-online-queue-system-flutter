
import 'package:queue_system/utils/constan.dart';
import 'package:queue_system/view_models/controller/auth_controller.dart';
import 'package:queue_system/widget/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final auhtController = Get.put(AuthController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Card(
        elevation: 20,
        child: Container(
          padding: const EdgeInsets.all(20),
          color: AppColors.white,
          height: 450,
          width: 450,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image.asset('assets/images/logo.webp'),
              const AppText(
                text: 'QUEUE SYSTEM',
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.black,
              ),
              Form(
                key: auhtController.gKfS,
                child: TextFormField(
                  controller: auhtController.keyController,
                  style: const TextStyle(
                    fontFamily: 'poppins',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    letterSpacing: 1,
                    wordSpacing: 1,
                  ),
                  decoration: const InputDecoration(
                      hintText: 'exm: xxxx-xxx-xxx-xxx',
                      hintStyle: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                        wordSpacing: 1,
                        fontStyle: FontStyle.italic,
                      ),
                      border: OutlineInputBorder(),
                      labelStyle: TextStyle(
                        fontFamily: 'poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1,
                        wordSpacing: 1,
                      ),
                      labelText: 'License Key'),
                  validator: (val) {
                    if (val!.trim().isEmpty) {
                      return "🔴 Key still empty";
                    }
                    return null;
                  },
                ),
              ),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.maroon),
                  onPressed: auhtController.registerLicense,
                  child: const Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login,
                        color: AppColors.white,
                        size: 30,
                      ),
                      SizedBox(width: 3),
                      AppText(
                        text: 'Submit',
                        fontWeight: FontWeight.bold,
                        color: AppColors.white,
                        fontSize: 14,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
