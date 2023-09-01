import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gulersentetik/screens/periodic/maintenance_solution.dart';
import 'package:http/http.dart' as http;

import '../../contans/app_color.dart';
import '../../contans/globals.dart';
import '../../ui/custom_logout_icon_button.dart';

class WorkerOptionData {
  String name;
  Color tileColor;
  bool isTapped;
  int sayi;

  WorkerOptionData({
    required this.name,
    required this.tileColor,
    this.isTapped = false,
    this.sayi =0,
  });
}

class MaintenancePage extends StatefulWidget {
  String turu;


  MaintenancePage({required this.turu});

  @override
  State<MaintenancePage> createState() => _MaintenancePageState();
}

class _MaintenancePageState extends State<MaintenancePage> {
  bool isloading = false;
  List<WorkerOptionData> listItems = [];

  void fetchData() async {
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
          listItems = workerOptions;
          isloading = true;
        });
      } else {
        print('Veri çekme hatası: ${response.statusCode}');
      }
    } catch (e) {
      print('Hata: $e');
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
    final screenWidth = MediaQuery.of(context).size.width;
    final titlePadding = calculateTitlePadding(screenWidth);
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          backgroundColor: AppColors.profilBackground, // Replace with your desired background color
          title: Container(
            alignment: Alignment.center,
            child: Text(
              "Güler Sentetik",
              style: TextStyle(fontSize: 25, color: Colors.white),
            ),
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
                padding: EdgeInsets.all(itemHeight * 0.1),
                itemBuilder: (context, index) {
                  WorkerOptionData item = listItems[index];

                  return Column(
                    children: [
                      Container(height: itemHeight * 0.5),
                      Padding(
                        padding: EdgeInsets.all(itemHeight * 0.2),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              print("Seçilen bolum ${item.name}");
                              //Periyodik_ kısmının çıkarma
                              String sabitKisim = "PERİYODİK_";
                              String sonuc = "";

                              if (widget.turu.startsWith(sabitKisim)) { 
                                sonuc = widget.turu.substring(sabitKisim.length);
                              } else {
                                print("Belirtilen sabit kısım bulunamadı.");
                              }

                              Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MaintenanceSolution(bolum: item.name,turu:sonuc),
                              ));
                            });
                            print('${item.name} seçildi.');
                          },
                          child: Container(
                            height: itemHeight,
                            decoration: BoxDecoration(
                              color: item.tileColor,
                              borderRadius: BorderRadius.circular(itemHeight * 0.2),
                            ),
                            child: Center(
                              child: Text(
                                item.name,
                                style: TextStyle(fontSize: 24, color: Colors.white),
                              ),
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
