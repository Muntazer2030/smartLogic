import 'package:flutter/material.dart';
import 'package:smartlogic/const/colors.dart';
import 'package:smartlogic/services/api.dart';
import 'package:smartlogic/services/mqtt_service.dart';
import 'package:smartlogic/ui/screens/Home/home_screen.dart';
import 'package:smartlogic/ui/widgets/text_widget.dart';

class AuthScreen extends StatefulWidget {
  final Api api;
  const AuthScreen({super.key, required this.api});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool isLogin = true;
 

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Initialize MQTT Service
   
    
  }

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          width: 600, // Nice for tablets
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: darkColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: TextWidget(
                  key: ValueKey(isLogin),
                  text: isLogin ? "Welcome Back" : "Create an Account",
                  color: whiteColor,
                  textSize: 32,
                  isTitle: true,
                  isTextCenterd: true,
                ),
              ),
              const SizedBox(height: 6),
              TextWidget(
                text: isLogin
                    ? "Enter your credentials to login"
                    : "Fill the form to register",
                color: whiteColor2,
                textSize: 16,
                isTextCenterd: true,
              ),
              const SizedBox(height: 30),

              // Register only full name field
              if (!isLogin) _inputField("Full Name", fullNameController),

              _inputField("Username", usernameController),
              _inputField("Password", passwordController, isPassword: true),

              const SizedBox(height: 26),
              SizedBox(
                width: double.infinity,
                child: isLoading
                    ? Center(child: const CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true;
                          });
                          if (isLogin) {
                            final response = await widget.api.login(
                              usernameController.text.trim(),
                              passwordController.text.trim(),
                            );
                            if (response == "Login successful") {
                              // ignore: use_build_context_synchronously
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeScreen(api: widget.api),
                                  ),
                                );
                              }
                            } else {
                              // ignore: use_build_context_synchronously
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: TextWidget(
                                      text: response,
                                      color: whiteColor,
                                      textSize: 16,
                                    ),
                                    backgroundColor: redColor,
                                  ),
                                );
                              }
                            }
                          } else {
                            final response = await widget.api.register(
                              usernameController.text.trim(),
                              passwordController.text.trim(),
                              fullNameController.text.trim(),
                            );
                            if (response == "Registration successful") {
                              if (context.mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        HomeScreen(api: widget.api),
                                  ),
                                );
                              }
                            } else {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: TextWidget(
                                      text: response,
                                      color: whiteColor,
                                      textSize: 16,
                                    ),
                                    backgroundColor: redColor,
                                  ),
                                );
                              }
                            }
                          }
                          setState(() {
                            isLoading = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: backgroundColor,
                          backgroundColor: primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: TextWidget(
                          text: isLogin ? "Login" : "Register",
                          color: backgroundColor,
                          textSize: 18,
                          isTitle: true,
                          isTextCenterd: true,
                        ),
                      ),
              ),
              const SizedBox(height: 18),
              TextButton(
                onPressed: () => setState(() => isLogin = !isLogin),
                child: TextWidget(
                  text: isLogin
                      ? "Don't have an account? Register"
                      : "Already have an account? Login",
                  color: primaryColor,
                  textSize: 16,
                  isTextCenterd: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputField(
    String label,
    TextEditingController controller, {
    bool isPassword = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        style: TextStyle(color: whiteColor),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: whiteColor2),
          filled: true,
          fillColor: backgroundColor,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: greyColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: primaryColor, width: 2),
          ),
        ),
      ),
    );
  }
}
