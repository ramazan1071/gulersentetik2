class KullaniciModel {
  final String bolum;

  KullaniciModel({required this.bolum});

  factory KullaniciModel.fromJson(Map<String, dynamic> json) {
    return KullaniciModel(bolum: json['BOLUM']);
  }
}
