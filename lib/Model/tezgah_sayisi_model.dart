class TezgahSayisiModel {
  final int id;
  final String arizaBolum;
  final int tezgahSayisi;

  TezgahSayisiModel({required this.id, required this.arizaBolum, required this.tezgahSayisi});

  factory TezgahSayisiModel.fromJson(Map<String, dynamic> json) {
    return TezgahSayisiModel(
      id: int.parse(json['ID']),
      arizaBolum: json['ARIZABOLUM'],
      tezgahSayisi: int.parse(json['TEZGAHSAYISI']),
    );
  }
}
