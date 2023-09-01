import 'package:flutter/material.dart';
import 'package:gulersentetik/screens/master/master_incorrect.dart';
import 'package:gulersentetik/screens/master/master_solution.dart';

import '../../Model/ariza_getir_model.dart';
import '../../contans/app_color.dart';
import '../../ui/custom_logout_icon_button.dart';
import '../worker/worker_option.dart';

class MasterOption extends StatefulWidget {
  ArizaGetirModel arizaListesi;

  MasterOption({required this.arizaListesi});

  @override
  State<MasterOption> createState() => _MasterOptionState();
}

class _MasterOptionState extends State<MasterOption> {
  List<WorkerOptionData> listItems = [
    WorkerOptionData(name: 'ÇÖZ', tileColor: Colors.blue),
    WorkerOptionData(name: 'HATALI BÖLÜM BİLDİR', tileColor: Colors.red),
    // WorkerOptionData(name: 'Mekanik Genel', tileColor: Colors.orange),
    // WorkerOptionData(name: 'Elektrik Genel', tileColor: Colors.purple),
  ];

  double calculateTitlePadding(double screenWidth) {
    // Calculate the desired padding value based on the screen width
    // You can adjust the multiplier (0.2 in this example) as needed
    return screenWidth * 0.14;
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
        body: Center(
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

                    return Center(
                      child: Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: itemHeight * 2),
                          Padding(
                            padding: EdgeInsets.all(itemHeight * 0.2),
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  switch (index) {
                                    case 0:
                                    // Code to execute when the first list item ('İplik') is tapped
                                      print('Çöz seçildi.');
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MasterSolution(arizaListesi: widget.arizaListesi),));
                                      break;
                                    case 1:
                                    // Code to execute when the second list item ('Dokuma') is tapped
                                      print('Hatalı bölüm bildir seçildi.');
                                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => MasterIncorrect(arizaListesi: widget.arizaListesi),));
                                      break;
                                  }
                                });
                                print('${item.name} seçildi.');
                              },
                              child: Container(
                                height: itemHeight,
                                decoration: BoxDecoration(
                                  color: item.tileColor,
                                  borderRadius: BorderRadius.circular(itemHeight *
                                      0.2), // Kenarları yuvarlatmak için değer ayarlayın
                                ),
                                child: Center(
                                  child: Text(
                                    item.name,
                                    style: TextStyle(
                                        fontSize: 24, color: Colors.white),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ));
  }
}
