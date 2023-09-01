import 'dart:convert';

import 'package:gulersentetik/contans/globals.dart';
import 'package:http/http.dart' as http;

import '../Model/tezgah_sayisi_model.dart';

class TezgahSayisiProvider {
  Future<List<TezgahSayisiModel>> getTezgahSayilari(String bolum) async {
    final url = '$baseUrl/TezgahSayisi.php'; // PHP API adresini buraya yazın
    final response = await http.post(Uri.parse(url), body: {'bolum': bolum});
    print("response tezgahsayısı:${response.statusCode}");

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = jsonDecode(decodedResponse);
      print("tezgah response: $decodedResponse");
      return List<TezgahSayisiModel>.from(
          data.map((item) => TezgahSayisiModel.fromJson(item)));
    } else {
      throw Exception('Veri alınamadı');
    }
  }
  }
