import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../Model/ariza_getir_model.dart';
import '../../contans/app_color.dart';
import '../../contans/globals.dart';
import '../../ui/custom_logout_icon_button.dart';
import '../splash_screen.dart';
class MasterIncorrect extends StatefulWidget {
  ArizaGetirModel arizaListesi;

  MasterIncorrect({required this.arizaListesi});

  @override
  State<MasterIncorrect> createState() => _MasterIncorrectState();
}

class _MasterIncorrectState extends State<MasterIncorrect> {
  String? valueChooseNS;
  String? valueChooseBS;
  bool isloading =false;
  List<String> listItemsBolum = [];
  List<String> kullaniciListesi = [];
  bool pressed = false;
  Future<void> getDataFromServer() async {
    kullaniciListesi.clear();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ArizaIsımSoyısımGetir.php"),
        body: {
          'BOLUM': widget.arizaListesi.arizaTuru,
        },
      );
      print("response : ${response.body}");

      if (response.statusCode == 200) {
        // İşlem başarılı, verileri ekrana yazdırma
        print("Veriler başarıyla alındı.");
        var decodedData = json.decode(response.body);
        for (var kullanici in decodedData) {
          String isimSoyisim = kullanici['ISIMSOYISIM'];
          kullaniciListesi.add(isimSoyisim);
        }
        setState(() {
          for (var isimSoyisim in kullaniciListesi) {
            print(isimSoyisim);
          }
        });
      } else {
        // Hata durumu ile ilgili bir işlem yapabilirsiniz.
        // Bu örnekte hata durumlarına özel bir işlem yapılmadı.
      }
    } catch (e) {
      // Hata durumu ile ilgili bir işlem yapabilirsiniz.
      // Bu örnekte hata durumlarına özel bir işlem yapılmadı.
    }
  }
  Future<void> getDataFromServerBolum() async {
    listItemsBolum.clear();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ArizaBolumGetir.php"),
      );
      print("response : ${response.body}");

      if (response.statusCode == 200) {
        // İşlem başarılı, verileri ekrana yazdırma
        print("Veriler başarıyla alındı.");
        var decodedData = json.decode(response.body);
        for (var kullanici in decodedData) {
          String bolum = kullanici['BOLUM'];
          listItemsBolum.add(bolum);
        }
        setState(() {
          for (var bolum in kullaniciListesi) {
            print(bolum);
          }
        });
      } else {
        // Hata durumu ile ilgili bir işlem yapabilirsiniz.
        // Bu örnekte hata durumlarına özel bir işlem yapılmadı.
      }
    } catch (e) {
      // Hata durumu ile ilgili bir işlem yapabilirsiniz.
      // Bu örnekte hata durumlarına özel bir işlem yapılmadı.
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
  //eskisi
  // Future<void> _postDataToServer() async {
  //   final response = await http.post(
  //     Uri.parse("$baseUrl/ArizaCoz.php"),
  //     body: {
  //       'ID_NEW': widget.arizaListesi.id.toString(),
  //       'ARIZABOLUM': widget.arizaListesi.arizaBolum,
  //       'ARIZATURU': valueChooseBS,
  //       'ARIZAACIKLAMA': "Hatalı Gönderim",
  //       'GUN': widget.arizaListesi.gun,
  //       'SAATLER': widget.arizaListesi.saatler,
  //       'ZAMAN': widget.arizaListesi.zaman,
  //       'TEZGAHNO': widget.arizaListesi.tezgahNo,
  //       'ISIMSOYISIM': valueChooseNS,
  //     },
  //   );
  //   print("response stat: ${response.statusCode}");
  //
  //   if (response.statusCode == 200) {
  //     // Check if the response is a valid JSON
  //
  //     print("Veri eklendi.");
  //
  //     // GECENSURE değerini güncelleyelim
  //     final responseGecensure = await http.post(
  //       Uri.parse("$baseUrl/ArizaCozulemedi2.php"),//burası çalışmıyor
  //       body: {
  //         'ID': widget.arizaListesi.id.toString(),
  //         'COZULDU': "2",
  //         'ARIZAACIKLAMA':"Hatalı Gönderim",
  //         'ARIZATURU':valueChooseBS,
  //       },
  //     );
  //     if (responseGecensure.statusCode == 200) {
  //       sendNotificationFirebase("BÖLÜM : ${widget.arizaListesi.arizaBolum}  -  Tip : ${valueChooseBS}", "Arıza Tezgah No: ${widget.arizaListesi.tezgahNo}  -  Gönderen Usta : ${valueChooseNS}  -  Arıza Açıklama : Hatalı Gönderim  !!! (Lütfen Uygulamaya Giriniz) !!!");
  //       print("GECENSURE güncellendi.");
  //       // Show success message to the user
  //       showDialog(
  //         context: context,
  //         barrierDismissible: false,
  //         builder: (context) => AlertDialog(
  //           title: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //             children: [
  //               Text("İşlem Başarılı",style: TextStyle(fontSize: 20,),),
  //               Icon(Icons.check_circle, color: Colors.green),
  //             ],
  //           ),
  //           content: Text("Arıza Gönderildi"),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.of(context).pushAndRemoveUntil(
  //                   MaterialPageRoute(builder: (context) => SplashScreen()),
  //                       (Route<dynamic> route) => false,
  //                 );
  //               },
  //               child: Text("Tamam"),
  //             ),
  //           ],
  //         ),
  //       );
  //     } else {
  //       // Show error message to the user if GECENSURE update fails
  //       showDialog(
  //         barrierDismissible: false,
  //         context: context,
  //         builder: (context) => AlertDialog(
  //           title: Text("Hata"),
  //           content: Text("Sunucu ile bağlantı hatası oluştu."),
  //           actions: [
  //             TextButton(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Text("Tamam"),
  //             ),
  //           ],
  //         ),
  //       );
  //     }
  //
  //   } else {
  //     // Handle other status codes if necessary
  //     print("İstek sırasında bir hata oluştu: ${response.statusCode}");
  //     showDialog(
  //       barrierDismissible: false,
  //       context: context,
  //       builder: (context) => AlertDialog(
  //         title: Text("Hata"),
  //         content: Text("Sunucu ile bağlantı hatası oluştu."),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //             },
  //             child: Text("Tamam"),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  //
  // }
  Future<void> _postDataToServer() async {
    final response = await http.post(
      Uri.parse("$baseUrl/ArizaCozulemedi.php"),
      body: {
        'ID_NEW': widget.arizaListesi.id.toString(),
        'ARIZABOLUM': widget.arizaListesi.arizaBolum,
        'ARIZATURU': valueChooseBS,
        'ARIZAACIKLAMA': "Hatalı Gönderim",
        'GUN': widget.arizaListesi.gun,
        'SAATLER': widget.arizaListesi.saatler,
        'ZAMAN': widget.arizaListesi.zaman,
        'TEZGAHNO': widget.arizaListesi.tezgahNo,
        'ISIMSOYISIM': valueChooseNS,
        'ID': widget.arizaListesi.id.toString(),
        'COZULDU': "2",
      },
    );
    print("response stat: ${response.statusCode}");

    if (response.statusCode == 200) {
      // Check if the response is a valid JSON

      print("Veri eklendi.");

        sendNotificationFirebase("BÖLÜM : ${widget.arizaListesi.arizaBolum}  -  Tip : ${valueChooseBS}", "Arıza Tezgah No: ${widget.arizaListesi.tezgahNo}  -  Gönderen Usta : ${valueChooseNS}  -  Arıza Açıklama : Hatalı Gönderim  !!! (Lütfen Uygulamaya Giriniz) !!!");
        print("GECENSURE güncellendi.");
        // Show success message to the user
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
            content: Text("Arıza Gönderildi"),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => SplashScreen()),
                        (Route<dynamic> route) => false,
                  );
                },
                child: Text("Tamam"),
              ),
            ],
          ),
        );
      } else {
        // Show error message to the user if GECENSURE update fails
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
  void initState() {
    // TODO: implement initState
    print("ariza:${widget.arizaListesi.arizaTuru}");
    print("zamanda:${widget.arizaListesi.zaman.toString()}");
    getDataFromServer();
    getDataFromServerBolum();
    isloading = true;

  }
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
          backgroundColor: AppColors.profilBackground,
          // Replace with your desired background color
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
          actions: [
            CustomLogoutIconButton(),
          ],
        ),
      ),
      body:isloading?Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 3,
                    child: Text(
                      "Bölüm:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 5,
                    child: Text(
                      "${widget.arizaListesi.arizaBolum}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 3,
                    child: Text(
                      "Tezgah No:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 5,
                    child: Text(
                      "${widget.arizaListesi.tezgahNo}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 3,
                    child: Text(
                      "Arıza Türü:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
                Expanded(
                    flex: 5,
                    child: Text(
                      "${widget.arizaListesi.arizaAciklama}",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    )),
              ],
            ),
            Divider(height: 1,color: Colors.grey,),

          Column(mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Hangi Bölüme Yönlendireceksin",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 16.0, bottom: 16.0, right: 16.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: ElevatedButton(
                            onPressed: () {

                              _showDropdownList(
                                context,
                                listItemsBolum.map((item) => item).toList(),
                                "valueChooseBS",
                                listItemsBolum.map((item) => item).toList(),
                              );
                              setState(() {
                                print("değer : ${valueChooseBS}");
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              elevation: 0,
                              side: BorderSide(width: 1, color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Yuvarlaklık değeri burada ayarlanıyor
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      valueChooseBS ?? "Bölüm",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black),
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down,
                                    color: AppColors.profilBackground, size: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
            Column(mainAxisAlignment: MainAxisAlignment.center,children: [
              Center(
                child: Text(
                  "İsim Soyisim Girin",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 5,
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 16.0, bottom: 16.0, right: 16.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: ElevatedButton(
                            onPressed: () {
                              _showDropdownList(
                                context,
                                kullaniciListesi.map((item) => item).toList(),
                                "valueChooseNS",
                                kullaniciListesi.map((item) => item).toList(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              elevation: 0,
                              side: BorderSide(width: 1, color: Colors.grey),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    8), // Yuvarlaklık değeri burada ayarlanıyor
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Text(
                                      valueChooseNS ?? "İsim Soyisim",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.black),
                                      softWrap: true,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_drop_down,
                                    color: AppColors.profilBackground, size: 30),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if(pressed == true){
                        print("v:${valueChooseNS}");
                        _postDataToServer();
                      }

                    });
                  },
                  style: ElevatedButton.styleFrom(
                    primary: pressed ? AppColors.profilBackground : Colors.grey,
                    // Duruma göre arka plan rengi değişir
                    onPrimary: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                  ),
                  child: Padding(
                    padding:
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text(
                      'Bildir',
                      style: TextStyle(fontSize: 24),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ):Center(child: CircularProgressIndicator()),
    );
  }
  void _showDropdownList(BuildContext context, List<String> itemList,
      String secim, List<String> itemList2) {
    final double itemHeight = 50.0;
    final double separatorHeight = 1.0;
    final double bottomPadding = 8.0;

    double listViewHeight = itemList.length * itemHeight +
        (itemList.length - 1) * separatorHeight +
        bottomPadding;
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
                bool isSelected = valueItem ==
                    (secim == "valueChooseNS"
                        ? valueChooseNS
                        : valueChooseBS); // Seçilen öğeyi kontrol ediyoruz

                return ListTile(
                  title: Text(valueItem),
                  tileColor: isSelected ? Colors.green : null,
                  // Seçili öğenin arkaplan rengini ayarlıyoruz (Yeşil renk)
                  onTap: () {
                    setState(() {
                      print("Seçim : ${secim} valueItem: ${valueItem}");
                      if (secim == "valueChooseNS") {
                        valueChooseNS = valueItem;
                      } else if (secim == "valueChooseBS") {
                        valueChooseBS = valueItem;
                      }
                      print("Bölüm  : ${widget.arizaListesi.arizaTuru} : ${valueChooseBS}");
                      if (valueChooseNS != null && valueChooseBS != null && valueChooseBS != widget.arizaListesi.arizaTuru) {
                        print("deneme ${widget.arizaListesi.arizaTuru}");
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
