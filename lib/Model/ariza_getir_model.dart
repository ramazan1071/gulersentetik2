class ArizaGetirModel {
  final int id;
  final String arizaBolum;
  final String arizaTuru;
  final String arizaAciklama;
  final String gun;
  final String saatler;
  final String tezgahNo;
  final String zaman;
  final String cozuldu;

  ArizaGetirModel({
    required this.id,
    required this.arizaBolum,
    required this.arizaTuru,
    required this.arizaAciklama,
    required this.gun,
    required this.saatler,
    required this.tezgahNo,
    required this.zaman,
    required this.cozuldu,

  });

  // Fabrika metodu - JSON verisini ArizaGetirModel nesnesine dönüştürür
  factory ArizaGetirModel.fromMap(Map<String, dynamic> map) {
    return ArizaGetirModel(
      id: int.parse(map['ID']),
      arizaBolum: map['ARIZABOLUM'],
      arizaTuru: map['ARIZATURU'],
      arizaAciklama: map['ARIZAACIKLAMA'],
      gun: map['GUN'],
      saatler: map['SAATLER'],
      tezgahNo: map['TEZGAHNO'],
      zaman: map['ZAMAN'],
      cozuldu: map['COZULDU'],
    );
  }
}
