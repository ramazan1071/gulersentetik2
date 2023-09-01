import 'dart:convert';

import 'package:http/http.dart' as http;

import '../Model/kullanici_model.dart';
import '../contans/globals.dart';


class KullaniciData {
  static Future<KullaniciModel?> loginUser(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + "/KullaniciKaydi.php"),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final bolum = jsonDecode(response.body);
        return KullaniciModel.fromJson(bolum); // Assuming you have a model class to parse the response
      } else {
        throw Exception("Kullanıcı adı veya şifre hatalı.");
      }
    } catch (e) {
      throw Exception("Veri alınırken bir hata oluştu: $e");
    }
  }
}
