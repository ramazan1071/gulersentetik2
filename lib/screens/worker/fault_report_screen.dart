import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gulersentetik/Model/ariza_veri_model.dart';
import 'package:gulersentetik/Model/vardiye_saatleri_model.dart';
import 'package:gulersentetik/contans/globals.dart';
import 'package:gulersentetik/screens/worker/worker_option.dart';
import 'package:http/http.dart' as http;

import '../../Data/tezgah_sayisi_repository.dart';
import '../../Model/numeric.dart';
import '../../Model/tezgah_sayisi_model.dart';
import '../../contans/app_color.dart';


class FaultReportScreen extends StatefulWidget {
  String section;
  String fault_type;


  FaultReportScreen({required this.section,required this.fault_type});

  @override
  State<FaultReportScreen> createState() => _FaultReportScreenState();
}


class _FaultReportScreenState extends State<FaultReportScreen> {

  String? valueChooseVS;
  String? valueChooseR;
  String? valueChooseVG;
  List<VardiyeSaatleriModel>listItemsVardiye =[];
  List<ArizaVeri> listItemsFault =[];
  TextEditingController tezgahNo = TextEditingController(text: "");
  bool pressed = false;
  bool isloading =false;
  Future<void> getArizaVerileri() async {
    final url = baseUrl+'/ArizaTipleriGetir.php'; // PHP API adresini buraya yazın
    final response = await http.post(
      Uri.parse(url),
      body: {
        'ariza_bolum':  widget.section.toUpperCase(),
        'ariza_turu': widget.fault_type,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        listItemsFault= List<ArizaVeri>.from(data.map((item) => ArizaVeri.fromJson(item)));
        print("uzunluğu : ${listItemsFault.length}");
      });
    } else {
      throw Exception('Veri alınamadı');
    }
  }
  @override


  void initState() {
    // TODO: implement initState
    super.initState();
    loadData();
  }
  Future<void> loadData() async {
    await getArizaVerileri();
    await _getVardiyeSaatleri();
    await _getTezgahSayilari();
    setState(() {
      // Veriler geldiğinde durumu güncelle
      isloading = true;
    });
  }
  Future<void> _getVardiyeSaatleri() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/VardiyeSaatleri.php'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final turkishDayVardiyeSaatleri = data.map((item) {
          String englishDay = item['GUN']; // GUN alanını İngilizce gün adı olarak alıyoruz
          String turkishDay = convertToTurkishDay(englishDay);
          return VardiyeSaatleriModel(
            id: int.parse(item['ID']),
            gun: turkishDay,
            saatler: item['SAATLER'],
          );
        }).toList();

        setState(() {
          listItemsVardiye = turkishDayVardiyeSaatleri;
          print("bak: ${listItemsVardiye[0].gun}");
        });
      } else {
        throw Exception('Veri alınamadı');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }


  final TezgahSayisiProvider _tezgahSayisiProvider = TezgahSayisiProvider();
  List<TezgahSayisiModel> _tezgahSayilari = [];

  Future<void> _getTezgahSayilari() async {
    try {

      final tezgahSayilari = await _tezgahSayisiProvider.getTezgahSayilari(widget.section);
      setState(() {
        _tezgahSayilari = tezgahSayilari;
        print("tezgah: ${_tezgahSayilari[0].tezgahSayisi}");
      });
    } catch (e) {
      // Hata yönetimi burada yapılabilir
    }
  }
  Future<void> veriSorgula() async {

      String url = "${baseUrl}/ArizaSorgula.php";

      Map<String, String> headers = {"Content-Type": "application/x-www-form-urlencoded"};

      Map<String, String> body = {
        "ARIZABOLUM": widget.section,
        "ARIZATURU": widget.fault_type,
        "ARIZAACIKLAMA": valueChooseR!,
        "TEZGAHNO":tezgahNo.text,
      };
      var response = await http.post(Uri.parse(url), headers: headers, body: body);
      print("response : {${response.statusCode}");
      print("response request: {${response.request}");
      print("response contentLength: {${response.contentLength}");
      print("responsebody : {${response.body}");
      if (response.statusCode == 200) {
        // PHP'den dönen mesajı alıyoruz
        String message = response.body;
        // Dönen mesaja göre işlem yapıyoruz
        if (message == "1") {
          valueChooseR="";
          valueChooseVG="";
          valueChooseVS="";
          tezgahNo.clear();
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text("İşlem başarısız",style: TextStyle(fontSize: 20,),),
                  Icon(Icons.warning, color: Colors.red),
                ],
              ),
              content: Text("Bu arıza daha önce gönderilmiştir.",style: TextStyle(fontSize: 15,),), // PHP tarafından dönen mesajı AlertDialog içinde gösterir.
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Tamam"),
                ),
              ],
            ),
          );
          // Veri varsa yapılacak işlemler
          print("Veri var");
        } else if (message == "0") {
          veriEkle();
          // Veri bulunamadıysa yapılacak işlemler
          print("Veri bulunamadı");
        } else {
          // Bilinmeyen bir durum varsa yapılacak işlemler
          print("Bilinmeyen durum: $message");
        }
      } else {
        throw Exception('Veri alınamadı');
      }
  }
  Future<void> sendNotificationFirebase(String title, String message) async {
    try {
      String url = "${baseUrl}/ArizaBildirimFirebase.php"; // PHP dosyanızın URL'sini buraya girin

      Map<String, String> headers = {"Content-Type": "application/x-www-form-urlencoded"};

      Map<String, String> body = {
        "title": title,
        "message": message,
      };

      var response = await http.post(Uri.parse(url), headers: headers, body: body);
      print("deneme firebase");

      if (response.statusCode == 200) {
        print("Bildirim gönderildi");
      } else {
        print("Bildirim gönderme hatası: ${response.statusCode}");
      }
    } catch (e) {
      print("Hata: $e");
    }
  }
  Future<void> veriEkle() async {
    print("GUn: ${valueChooseVG}");
    String url = "${baseUrl}/ArizaGonder.php";

    Map<String, String> headers = {"Content-Type": "application/x-www-form-urlencoded"};
    print("tezgah: ${tezgahNo.text}");

    Map<String, String> body = {
      "ARIZABOLUM": widget.section,
      "ARIZATURU": widget.fault_type,
      "ARIZAACIKLAMA": valueChooseR!,
      "GUN": valueChooseVG!,
      "SAATLER": valueChooseVS!,
      "TEZGAHNO":tezgahNo.text,
    };

    var response = await http.post(Uri.parse(url), headers: headers, body: body);

    if (response.statusCode == 200) {
      print("tezgah no: ${tezgahNo.text}");
      print("arıza no: ${ widget.fault_type}");
      print("arıza acıklama: ${valueChooseR}");
      sendNotificationFirebase("BÖLÜM : ${widget.section}  -  Tip : ${widget.fault_type}", "Arıza Tezgah No: ${tezgahNo.text}  -  Arıza Açıklama : ${valueChooseR}  !!! (Lütfen Uygulamaya Giriniz) !!!");
      var jsonResponse = jsonDecode(response.body);
      print(jsonResponse);
      // PHP tarafından dönen mesajı konsola yazdırır.
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Text("İşlem Başarılı",style: TextStyle(fontSize: 20,),),
              Icon(Icons.check_circle, color: Colors.green),
            ],
          ),
          content: Text("Arıza Gönderildi",style: TextStyle(fontSize: 15,),), // PHP tarafından dönen mesajı AlertDialog içinde gösterir.
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => WorkerOption()),
                (Route<dynamic> route) => false,
                );
              },
              child: Text("Tamam"),
            ),
          ],
        ),
      );

    } else {
      showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hata"),
          content: Text("Sunucu ile bağlantı hatası oluştu."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Tamam"),
            ),
          ],
        ),
      );
    }
  }
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Sadece sayısal değerleri ve belirli bir maksimum değeri kabul etmek için kontrolleri yapalım
    if (newValue.text.isEmpty) {
      return newValue;
    } else {
      int parsedValue = int.tryParse(newValue.text) ?? 0;
      int maxValue = _tezgahSayilari[0].tezgahSayisi; // Maksimum değeri burada belirleyebilirsiniz
      if (parsedValue > maxValue) {
        parsedValue = maxValue;
      }
      return TextEditingValue(
        text: parsedValue.toString(),
        selection: TextSelection.collapsed(offset: parsedValue.toString().length),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titlePadding = calculateTitlePadding(screenWidth);
    return  Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: AppColors.profilBackground, // Replace with your desired background color
          leading: Transform.scale(
            scale: 1,
            child: IconButton(
              icon: Icon(Icons.arrow_back,size: 40,),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ),
          title: Padding(
            padding: EdgeInsets.only(right: titlePadding),
            child: Container(
              alignment: Alignment.center,
              child: Text(
                "Güler Sentetik",
                style: TextStyle(fontSize: 25, color: Colors.white),
              ),
            ),
          ),
        ),
      ),
      body: isloading?Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Row(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex:1,
                  child: Container()),
              Expanded(flex:3,child: Text("Vardiya Saati:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
              Expanded(flex: 5,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0,bottom: 16.0,right: 16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: ElevatedButton(
                        onPressed: () {
                          _showDropdownList(context, listItemsVardiye.map((item) => item.saatler).toList(),"valueChooseV",listItemsVardiye.map((item) => item.gun).toList(),);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          elevation: 0,
                          side: BorderSide(width: 1, color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Yuvarlaklık değeri burada ayarlanıyor
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  valueChooseVS ?? "Vardiye Saati",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black),
                                  softWrap: true,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: AppColors.profilBackground, size: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex:1,
                  child: Container()),
              Expanded(flex:3,child: Text("Tezgah No:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
      Expanded(
        flex: 5,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 16.0, bottom: 16.0, right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey, width: 1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 4.0, bottom: 4.0, right: 16.0, left: 16.0),
                child: TextFormField(
                  style: const TextStyle(fontSize: 15,),
                  controller: tezgahNo,
                  keyboardType: TextInputType.number,
                  inputFormatters: [NumericTextInputFormatter(maxValue: _tezgahSayilari[0].tezgahSayisi,minValue: 1)], // Kontrolleri uygulamak için formatter'ı ekleyin
                  decoration: InputDecoration(
                    hintText: '(1 - ${_tezgahSayilari[0].tezgahSayisi})',
                    border: UnderlineInputBorder(
                      borderSide: BorderSide.none, // Altındaki çizgiyi kaldırmak için BorderSide.none kullanın
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      if (valueChooseR != null && valueChooseVS != null && tezgahNo.text.isNotEmpty) {
                        pressed = true;
                      } else {
                        pressed = false;
                      }
                    });

                    // Kullanıcı her veri girdiğinde bu işlev çağrılır
                    // value, metin alanına girilen yeni değeri temsil eder
                  },
                ),
              ),
            ),
          ),
        ),
      ),
            ],
          ),
          Row(mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(flex:1,
                  child: Container()),
              Expanded(flex:3,child: Text("Arıza Tipi:",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
              Expanded(flex: 5,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0,bottom: 16.0,right: 16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: ElevatedButton(
                        onPressed: () {
                          _showDropdownList(context, listItemsFault.map((item) => item.arizaAciklama).toList(),"valueChooseR",listItemsFault.map((item) => item.arizaBolum).toList(),);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          elevation: 0,
                          side: BorderSide(width: 1, color: Colors.grey),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8), // Yuvarlaklık değeri burada ayarlanıyor
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Text(
                                  valueChooseR ?? "Arıza Tipi",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: Colors.black),
                                  softWrap: true,
                                ),
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: AppColors.profilBackground, size: 30),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    print("v:${valueChooseVS}");
                    print("valueChooseR:${valueChooseR}");
                    print("tezgahNo:${tezgahNo.text}");
                    if(valueChooseR != null && valueChooseVS != null && tezgahNo.text!="")
                    {
                      print("basıldı");
                      pressed = false;
                      veriSorgula();
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  primary: pressed ? AppColors.profilBackground : Colors.grey, // Duruma göre arka plan rengi değişir
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text(
                    'Arıza Gönder',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              ),
            ),
          ),
        ],
      ):
        Center(child: CircularProgressIndicator()),
    );
  }
  void _showDropdownList(BuildContext context, List<String> itemList, String secim, List<String> itemList2) {
    final double itemHeight = 50.0;
    final double separatorHeight = 1.0;
    final double bottomPadding = 8.0;

    double listViewHeight = itemList.length * itemHeight + (itemList.length - 1) * separatorHeight + bottomPadding;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Container(
            height: listViewHeight,
            width: double.maxFinite,
            child: ListView.separated(
              itemCount: itemList.length,
              separatorBuilder: (BuildContext context, int index) {
                return Divider(
                  height: separatorHeight,
                  thickness: 1,
                  color: Colors.grey,
                );
              },
              itemBuilder: (BuildContext context, int index) {
                final valueItem = itemList[index];
                bool isSelected = valueItem == (secim == "valueChooseR" ? valueChooseR : valueChooseVS); // Seçilen öğeyi kontrol ediyoruz

                return ListTile(
                  title: Text(valueItem),
                  tileColor: isSelected ? Colors.green : null, // Seçili öğenin arkaplan rengini ayarlıyoruz (Yeşil renk)
                  onTap: () {
                    setState(() {
                      if (secim == "valueChooseR") {
                        valueChooseR = valueItem;
                      } else if (secim == "valueChooseV") {
                        valueChooseVS = valueItem;
                        valueChooseVG = itemList2[0];
                      }
                      if (valueChooseR != null && valueChooseVS != null && tezgahNo.text.isNotEmpty) {
                        pressed = true;
                      } else {
                        pressed = false;
                      }
                    });

                    // Dikkat: onPressed'ta setState kullanıyorsanız, Navigator.of(context).pop() öncesinde setState yapmanız gerekebilir.
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }


}

