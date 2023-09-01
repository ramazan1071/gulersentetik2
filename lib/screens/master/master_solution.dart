  import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grock/grock.dart';
import 'package:gulersentetik/contans/globals.dart';
import 'package:gulersentetik/screens/splash_screen.dart';
import 'package:http/http.dart' as http;

import '../../Model/ariza_getir_model.dart';
import '../../Model/ariza_veri_model.dart';
import '../../contans/app_color.dart';
import '../../ui/custom_logout_icon_button.dart';

  class Item {
    String malzeme;
    int adet;

    Item(this.malzeme, this.adet);
  }


  class MasterSolution extends StatefulWidget {
    ArizaGetirModel arizaListesi;

    MasterSolution({required this.arizaListesi});

    @override
    State<MasterSolution> createState() => _MasterSolutionState();
  }

  class _MasterSolutionState extends State<MasterSolution> {
    String? valueChooseNS;
    String? valueChooseAT;
    List<String> kullaniciListesi = [];
    List<ArizaVeri> listItemsFault =[];
    //TextEditingController malzemeController = TextEditingController(text: "");
    bool pressed = false;
    bool isloading =false;
    bool onaylandi = false;
    final TextEditingController _malzemeNameController = TextEditingController();
    final TextEditingController _malzemeSayisiController = TextEditingController();
    List<Item> items = [];
    Future<void> getArizaVerileri() async {
      final url = baseUrl+'/ArizaTipleriGetir.php'; // PHP API adresini buraya yazın
      final response = await http.post(
        Uri.parse(url),
        body: {
          'ariza_bolum':  widget.arizaListesi.arizaBolum,
          'ariza_turu': widget.arizaListesi.arizaTuru,
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
    void updateDataTime(int idToUpdate) async {
      print("GÜNCEL ID: ${idToUpdate}");
      final response = await http.post(
        Uri.parse('$baseUrl/ArizaToplamSure.php'), // PHP betiği URL'si
        body: {'ID': idToUpdate.toString()},
      );


      if (response.statusCode == 200) {
        print("deney ${idToUpdate}");
      } else {
        print('Hata oluştu: ${response.reasonPhrase}');
      }
    }

    Future<void> _postDataToServer() async {
      if(valueChooseAT.isEmpty){
        valueChooseAT = widget.arizaListesi.arizaAciklama;
        print("burası aktif oldu");
      }
      String itemsAsString = items.map((item) => "${item.malzeme} (${item.adet})").join(" , ");
      print("malzemeler : ${itemsAsString}");
            final responseGecensure = await http.post(
              Uri.parse("$baseUrl/ArizaCoz2.php"),
              body: {
                'ID_NEW': widget.arizaListesi.id.toString(),
                'ARIZABOLUM': widget.arizaListesi.arizaBolum,
                'ARIZATURU': widget.arizaListesi.arizaTuru,
                'ARIZAACIKLAMA': valueChooseAT,
                'GUN': widget.arizaListesi.gun,
                'SAATLER': widget.arizaListesi.saatler,
                'ZAMAN': widget.arizaListesi.zaman,
                'TEZGAHNO': widget.arizaListesi.tezgahNo,
                'ISIMSOYISIM': valueChooseNS,
                'ID': widget.arizaListesi.id.toString(),
                'COZULDU': "1",
                'TESPIT_ARIZA_ACIKLAMA':valueChooseAT,
                'MALZEME':itemsAsString,
              },

            );
            if (responseGecensure.statusCode == 200) {
              print("GECENSURE güncellendi.");
              updateDataTime(widget.arizaListesi.id);
              // Show success message to the user
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: [
                      Text("İşlem Başarılı",style: TextStyle(fontSize: 20,),),
                      Icon(Icons.check_circle, color: Colors.green),
                    ],
                  ),
                  content: Text("Arıza Çözüldü"),
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

    Future<void> loadData() async {
      await getDataFromServer();
      await getArizaVerileri();
      setState(() {
        // Veriler geldiğinde durumu güncelle
        isloading = true;
      });
    }

    //malzeme giriş

    @override
    void dispose() {
      _malzemeNameController.dispose();
      _malzemeSayisiController.dispose();
      super.dispose();
    }
    void _addItem() {
      String name = _malzemeNameController.text;
      int quantity = int.tryParse(_malzemeSayisiController.text) ?? 0;

      if (name.trim().isNotEmpty && quantity >= 0 && quantity <= 999) {
        setState(() {
          items.add(Item(name, quantity));
          _malzemeNameController.clear();
          _malzemeSayisiController.clear();

          if (items.isNotEmpty && valueChooseNS.isNotEmpty && widget.arizaListesi.arizaAciklama != "Hatalı Gönderim") {
            pressed = true;
          } else if (items.isNotEmpty && valueChooseNS.isNotEmpty && widget.arizaListesi.arizaAciklama == "Hatalı Gönderim") {
            if (valueChooseAT.isNotEmpty) {
              pressed = true;
            } else {
              pressed = false;
            }
          } else {
            pressed = false;
          }
        });
      } else {
        // Malzeme adı boş veya geçersiz, kullanıcıya uyarı ver
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Hata'),
              content: Text('Malzeme adı boş olamaz.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Tamam'),
                ),
              ],
            );
          },
        );
      }
    }

    void _removeItem(int index) {
      setState(() {
        items.removeAt(index);
      });
      if (items.isNotEmpty && valueChooseNS.isNotEmpty && widget.arizaListesi.arizaAciklama != "Hatalı Gönderim")
      {
        setState(() {
          pressed = true;
        });
      }
      else if(items.isNotEmpty && valueChooseNS.isNotEmpty && widget.arizaListesi.arizaAciklama == "Hatalı Gönderim")
      {
        if(valueChooseAT.isNotEmpty){
          setState(() {
            pressed = true;
          });
        }
        else{
          setState(() {
            pressed = false;
          });
        }
      }
      else {
        setState(() {
          pressed = false;
        });
      }
    }

    void _editItem(int index) async {
      await showDialog(
        context: context,
        builder: (BuildContext context) {
          String malzeme = items[index].malzeme;
          int adet = items[index].adet;

          return AlertDialog(
            title: Text('Öğe Düzenle'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: TextEditingController(text: malzeme),
                  onChanged: (value) {
                    malzeme = value;
                  },
                  decoration: InputDecoration(labelText: 'Malzeme Adı'),
                ),
                SizedBox(height: 10),
                TextField(
                  controller: TextEditingController(text: adet.toString()),
                  onChanged: (value) {
                    adet = int.tryParse(value) ?? 0;
                  },
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: 'Adet (0-999)'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('İptal'),
              ),
              TextButton(
                onPressed: () {
                  if (malzeme.trim().isEmpty) {
                    // Malzeme alanı boşsa uyarı ver
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Hata'),
                          content: Text('Malzeme adı boş olamaz.'),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Tamam'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // Malzeme alanı doluysa kaydet
                    setState(() {
                      items[index].malzeme = malzeme;
                      items[index].adet = adet;
                      Navigator.of(context).pop();
                    });
                  }
                },
                child: Text('Kaydet'),
              ),
            ],
          );
        },
      );
    }


    @override
    void initState() {
      print("widget.arizaListesi.arizaBolum:${widget.arizaListesi.arizaBolum}");
      print("widget.arizaListesi.arizaTuru:${widget.arizaListesi.arizaTuru}");
    // TODO: implement initState
      print("ariza:${widget.arizaListesi.arizaTuru}");
      loadData();
      print("kullanici: ${kullaniciListesi.length}");
    super.initState();
  }
    Widget build(BuildContext context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final titlePadding = calculateTitlePadding(screenWidth);
      return Scaffold(
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
        body:isloading?ListView( shrinkWrap: true,children: [ Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Text(
                          "Bölüm:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    Expanded(
                        flex: 10,
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
                        flex: 6,
                        child: Text(
                          "Tezgah No:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    Expanded(
                        flex: 10,
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
                        flex: 6,
                        child: Text(
                          "Gelen Arıza Türü:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    Expanded(
                        flex: 10,
                        child: Text(
                          "${widget.arizaListesi.arizaAciklama}",
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
                        flex: 6,
                        child: Text(
                          "Tespit Arıza Türü:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    Expanded(
                      flex: 10,
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
                                  listItemsFault.map((item) => item.arizaAciklama).toList(),
                                  "valueChooseAT",
                                  listItemsFault.map((item) => item.arizaAciklama).toList(),
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
                                        valueChooseAT ?? "Arıza Türü",
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(flex: 1, child: Container()),
                    Expanded(
                        flex: 6,
                        child: Text(
                          "İsim Soyisim:",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        )),
                    Expanded(
                      flex: 10,
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
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Divider(height: 1,color: Colors.grey,),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Text("Kullanacağınız Malzemeleri Listeye Ekleyin",style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: _malzemeNameController,
                              decoration: InputDecoration(labelText: 'Malzeme Adı'),
                            ),
                          ),
                          SizedBox(width: 10),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: TextField(
                              controller: _malzemeSayisiController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(labelText: 'Adet (0-999)'),
                            ),
                          ),
                          SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: _addItem,
                            style: ElevatedButton.styleFrom(
                              primary: AppColors.profilBackground, // Düğme rengi
                              onPrimary: Colors.white, // Yazı rengi
                              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Düğme iç içe boşluğu
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10), // Köşeleri yuvarlat
                              ),
                            ),
                            child: Text('Malzeme Ekle', style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ),
                    items.isNotEmpty?Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: AppColors.profilBackground),
                          color: Colors.grey[300], // Gri arka plan rengi
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          itemCount: items.length,
                          separatorBuilder: (context, index) => Divider(), // Araya çizgi ekleniyor
                          itemBuilder: (context, index) {
                            return ListTile(
                              title: Text('Malzeme : ${items[index].malzeme}'),
                              subtitle: Text('Adet: ${items[index].adet}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit,color: AppColors.green,),
                                    onPressed: () {
                                      _editItem(index);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,color: AppColors.profilBackground2,),
                                    onPressed: () {
                                      _removeItem(index);
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ):Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Container(child: Text("Eklediğiniz malzeme yok",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16,color: AppColors.profilBackground),textAlign: TextAlign.center,),),
                          Container(child: Padding(
                            padding: const EdgeInsets.all(4.0),
                            child: Text("(Malzeme kullanmadıysanız yok ve adet 0 giriniz !)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 13,color: AppColors.profilBackground2),textAlign: TextAlign.center,),
                          ),),

                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0,bottom: 20.0,left: 8.0,right: 8.0),
                  child: Divider(height: 1,color: Colors.grey,),
                ),
                items.isNotEmpty?Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0,left: 16.0),
                      child: Row(children: [
                        Text("Toplam Şu kadar Malzeme Ekledin : ", style: TextStyle(
                          fontSize: 15,),),
                        Text("${items.length}",
                          style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
                      ],),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0,bottom: 20.0,left: 8.0,right: 8.0),
                      child: Divider(height: 1,color: Colors.grey,),
                    ),
                  ],
                ):Container(),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          print("v:${valueChooseNS}");
                          print("value değeri :${valueChooseNS}");
                          print("value2 : ${widget.arizaListesi.id}");
                          if(pressed == true ){
                              pressed = false;
                              _postDataToServer();

                            }
                            else {
                                pressed = false;
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
                          'ÇÖZ',
                          style: TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),],
        ): Center(child: CircularProgressIndicator()),
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
                          : valueChooseAT); // Seçilen öğeyi kontrol ediyoruz

                  return ListTile(
                    title: Text(valueItem),
                    tileColor: isSelected ? Colors.green : null,
                    // Seçili öğenin arkaplan rengini ayarlıyoruz (Yeşil renk)
                    onTap: () {
                      setState(() {
                        if (secim == "valueChooseNS") {
                          valueChooseNS = valueItem;
                        } else if (secim == "valueChooseAT") {
                          valueChooseAT = valueItem;
                        }
                        if (items.isNotEmpty && valueChooseNS.isNotEmpty && widget.arizaListesi.arizaAciklama != "Hatalı Gönderim")
                        {
                          setState(() {
                            pressed = true;
                          });
                        }
                       else if(items.isNotEmpty && valueChooseNS.isNotEmpty && widget.arizaListesi.arizaAciklama == "Hatalı Gönderim")
                        {
                          if(valueChooseAT.isNotEmpty){
                            setState(() {
                              pressed = true;
                            });
                          }
                          else{
                            setState(() {
                              pressed = false;
                            });
                          }
                        }
                        else {
                          setState(() {
                            pressed = false;
                          });
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

