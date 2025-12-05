import 'package:smartlogic/services/api_service.dart';

class Api {
  String token = "";

  Future login(String username, String password) async {
    final response = await ApiService.post("auth/login", {
      "username": username,
      "password": password,
    });
    if (response.containsKey("access_token")) {
      token = response["access_token"];
      return "Login successful";
    }
    return response["msg"];
  }

  Future register(String username, String password, String name) async {
    final response = await ApiService.post("auth/register", {
      "username": username,
      "password": password,
      "name": name,
    });
    if (response.containsKey("users")) {
      return "Registration successful";
    }
    return response["msg"];
  }

  Future fetchUserData() async {
    final response = await ApiService.get("users/me", token: token);
    if (response.containsKey("profile")) {
      return response["profile"];
    }
    return response["msg"];
  }

  Future createUserData(Map<String, dynamic> data) async {
    final response = await ApiService.post("users/profile", {
      "extra": data,
    }, token: token);
    if (response.containsKey("profile")) {
      return "Profile created successfully";
    }
    return response["msg"];
  }

  Future updateUserData(Map<String, dynamic> data) async {
    final response = await ApiService.put("users/profile", {
      "extra": data,
    }, token: token);
    if (response.containsKey("profile")) {
      return "Profile updated successfully";
    }
    return response["msg"];
  }
}
