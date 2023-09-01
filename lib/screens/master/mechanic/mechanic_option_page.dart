import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../../Model/ariza_getir_model.dart';
import '../../../contans/app_color.dart';
import '../../../contans/globals.dart';
import '../../../ui/custom_logout_icon_button.dart';
import '../../worker/worker_option.dart';
import 'mechanic_page.dart';


class MechanicOptionPage extends StatefulWidget {
  String bolum;


  MechanicOptionPage({required this.bolum});

  @override
  State<MechanicOptionPage> createState() => _MechanicOptionPageState();
}

class _MechanicOptionPageState extends State<MechanicOptionPage> {
  bool isloading = false;
  List<WorkerOptionData> listItems = [WorkerOptionData(name: "TÜMÜ", tileColor: AppColors.profilBackground2)];
  List<WorkerOptionData> listItems2 = [];
  List<ArizaGetirModel> arizaListesi = [];
  int sayac = 0;
  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ArizaIsciBolumGetir.php'));

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);

        List<WorkerOptionData> workerOptions = data.asMap().entries.map((entry) {
          int index = entry.key;
          String item = entry.value;

          return WorkerOptionData(name: item, tileColor: AppColors.profilBackground2);
        }).toList();

        // Name'e göre sıralama yapalım
        workerOptions.sort((a, b) => a.name.compareTo(b.name));

        setState(() {
          listItems2 = workerOptions;
          WorkerOptionData tumuOption = listItems.firstWhere((option) => option.name == "TÜMÜ");
          listItems = [tumuOption,...listItems2];
          _verileriGetir(widget.bolum);
        });
      } else {
        print('Veri çekme hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
    }
  }


  void renkdegisimi(){
    for(var i = 0;i<listItems.length;i++){
      if(listItems[i].sayi == 0){
        listItems[i].tileColor = AppColors.green;
      }
    }
    isloading = true;
  }

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

          //bölümleri karşılaştırma
          for(var i =0;i<listItems.length;i++){
            for(var a = 0;a<arizaListesi.length;a++)

              {
                if(listItems[i].name =="TÜMÜ"){
                  listItems[i].sayi = arizaListesi.length;
                  print("a : ${arizaListesi.length}");
                  print("i : ${i}");
                  break;
                }

                else if(listItems[i].name == arizaListesi[a].arizaBolum){
                  print("a : ${a}");
                  print("i : ${i}");
                      sayac++;

                }
                if(a == arizaListesi.length-1)
                {
                  listItems[i].sayi = sayac;
                  sayac = 0;
                  break;
                }

              }
          }
         //renk değişimi
          renkdegisimi();
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

  double calculateTitlePadding(double screenWidth) {
    // Calculate the desired padding value based on the screen width
    // You can adjust the multiplier (0.2 in this example) as needed
    return screenWidth * 0.14;
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }
  @override
  Widget build(BuildContext context) {

    return  Scaffold(
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
                isloading = false;
                fetchData();
              });
            },
            icon: Icon(Icons.refresh,size: 40,), // Yenileme ikonu
          ),
          actions: [
            CustomLogoutIconButton(),
          ],
        ),
      ),
      body: isloading
          ? Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Ekrana göre responsive boyut hesaplaması yapalım
            double itemHeight = constraints.maxHeight * 0.1;
            return Center(
              // Wrap the ListView with a Center widget
              child: ListView.builder(
                itemCount: listItems.length,
                padding: EdgeInsets.all(itemHeight * 0.2),
                itemBuilder: (context, index) {
                  WorkerOptionData item = listItems[index];
                  return Column(
                    children: [
                      Container(height: itemHeight * 0.5),
                      Padding(
                        padding: EdgeInsets.all(itemHeight * 0.04),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              print("Seçilen bolum ${item.name}");
                              if(item.name == "TÜMÜ")
                                {
                                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => MechanicPage(arizaTuru: widget.bolum,arizaBolum:"TUMU"),));
                                }
                              else{
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => MechanicPage(arizaTuru: widget.bolum,arizaBolum:item.name),));
                              }

                            });
                            print('${item.name} seçildi.');
                          },
                          child: Container(
                            height: itemHeight,
                            decoration: BoxDecoration(
                              color: item.tileColor,
                              borderRadius: BorderRadius.circular(itemHeight * 0.2),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Text(
                                  item.name,
                                  style: TextStyle(fontSize: 24, color: Colors.white),
                                ),
                                Text(
                                  "(${item.sayi.toString()})",
                                  style: TextStyle(fontSize: 24, color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      )
          : Center(child: CircularProgressIndicator()),
    );
  }
}
