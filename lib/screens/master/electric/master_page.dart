import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gulersentetik/Model/ariza_getir_model.dart';
import 'package:http/http.dart' as http;

import '../../../contans/app_color.dart';
import '../../../contans/globals.dart';
import '../../../ui/custom_logout_icon_button.dart';
import '../master_option.dart';

class MasterPage extends StatefulWidget {
  String bolum;


  MasterPage({required this.bolum});

  @override
  State<MasterPage> createState() => _MasterPageState();
}

class _MasterPageState extends State<MasterPage> {
  List<ArizaGetirModel> arizaListesi = [];
  bool isLoading = true;
  int toplam = 0;

  Future<void> _verileriGetir(String arizaTuru) async {
    print("arıza turu : ${arizaTuru}");
    try {
      final response = await http.post(Uri.parse("$baseUrl/ArizaGetir.php"), body: {
        'ARIZATURU': arizaTuru,
      });
      print("response : ${response.body}");

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        setState(() {
          arizaListesi = jsonList.map((json) => ArizaGetirModel.fromMap(json)).toList();

// ZAMAN değerine göre sıralama
          arizaListesi.sort((a, b) => b.zaman.compareTo(a.zaman));

          // ZAMAN değeri çakışma durumunda ID değerine göre sıralama
          for (int i = 0; i < arizaListesi.length - 1; i++) {
            for (int j = i + 1; j < arizaListesi.length; j++) {
              if (arizaListesi[i].zaman == arizaListesi[j].zaman) {
                if (arizaListesi[i].id.compareTo(arizaListesi[j].id) < 0) {
                  // Swap i and j elements
                  ArizaGetirModel temp = arizaListesi[i];
                  arizaListesi[i] = arizaListesi[j];
                  arizaListesi[j] = temp;
                }
              }
            }
          }
          for (int i = 0; i < arizaListesi.length - 1; i++) {
            for (int j = i + 1; j < arizaListesi.length; j++) {
              if (arizaListesi[i].zaman == arizaListesi[j].zaman) {
                if (arizaListesi[i].id.compareTo(arizaListesi[j].id) < 0) {
                  // Swap i and j elements
                  ArizaGetirModel temp = arizaListesi[i];
                  arizaListesi[i] = arizaListesi[j];
                  arizaListesi[j] = temp;
                }
              }
            }
          }

          // Sonuçları yazdırma
          arizaListesi.forEach((ariza) {
            print("id: ${ariza.id}, zaman: ${ariza.zaman}");
          });

          print(arizaListesi);
          toplam = arizaListesi.length;
          isLoading = false;
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

  @override
  void initState() {
    super.initState();
    _verileriGetir(widget.bolum);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titlePadding = calculateTitlePadding(screenWidth);
    String getFormattedGun(String gun) {
      switch (gun) {
        case 'Monday':
          return 'Pazartesi';
        case 'Tuesday':
          return 'Salı';
        case 'Wednesday':
          return 'Çarşamba';
        case 'Thursday':
          return 'Perşembe';
        case 'Friday':
          return 'Cuma';
        case 'Saturday':
          return 'Cumartesi';
        case 'Sunday':
          return 'Pazar';
        default:
          return gun;
      }
    }


    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,

          ),
          backgroundColor: AppColors.profilBackground,
          title: Container(
            alignment: Alignment.center,
            child: Text(
              "Güler Sentetik",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
          ),
          leading: IconButton(
            onPressed: () {
              setState(() {
                isLoading = true; // Yenileme işlemi başladığında loading göstermek için
              });
              _verileriGetir(widget.bolum);
            },
            icon: Icon(Icons.refresh,size: 40,), // Yenileme ikonu
          ),
          actions: [
            CustomLogoutIconButton(),
          ],
        ),
      ),
      body: isLoading!
          ? Center(child: CircularProgressIndicator())
          : Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: arizaListesi.length,
              itemBuilder: (context, index) {
                final ariza = arizaListesi[index];
                return InkWell(
                  onTap: () {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => MasterOption(arizaListesi: arizaListesi[index],),));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0), // Kenarları yuvarlatalım
                      color: Colors.grey[300], // Arkaplanı hafif gri yapalım
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 1,
                          blurRadius: 4,
                          offset: Offset(0, 1),
                        ),
                      ],
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0), // Yatayda 16, dikeyde 8 birimlik boşluk bırakalım
                    child: ListTile(
                      title: Column(
                        children: [
                          Divider(color: Colors.grey,height: 1,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Bölüm : ${ariza.arizaBolum}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                          ),
                        ],
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start, // Satırların başlangıcı sola hizalansın
                        children: [
                          Divider(color: Colors.grey,height: 1,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Tezgah Numarası: ${ariza.tezgahNo}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),),
                          ),
                          Divider(color: Colors.grey,height: 1,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Arıza Türü: ${ariza.arizaAciklama}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),),
                          ),
                          Divider(color: Colors.grey,height: 1,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Gün: ${getFormattedGun(ariza.gun)}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),),
                          ),
                          Divider(color: Colors.grey,height: 1,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Vardiye: (${ariza.saatler})",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),),
                          ),
                          Divider(color: Colors.grey,height: 1,),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text("Tarih: ${ariza.zaman}",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500),),
                          ),
                          Divider(color: Colors.grey,height: 1,),
                          // Diğer verileri buraya ekleyebilirsiniz
                        ],
                      ),

                      trailing: Icon(Icons.arrow_forward_ios),
                    ),
                  ),
                );
              },
            ),
          ),

        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: null,
        child: Text(toplam.toString(),style: TextStyle(fontSize: 25),), // FAB içeriği (ikon)
      ),
    );
  }
}