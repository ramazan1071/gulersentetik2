class ArizaVeri {
  String arizaBolum;
  String arizaTuru;
  String arizaAciklama;

  ArizaVeri({
    required this.arizaBolum,
    required this.arizaTuru,
    required this.arizaAciklama,
  });

  factory ArizaVeri.fromJson(Map<String, dynamic> json) {
    return ArizaVeri(
      arizaBolum: json['ARIZABOLUM'],
      arizaTuru: json['ARIZATURU'],
      arizaAciklama: json['ARIZAACIKLAMA'],
    );
  }
}
