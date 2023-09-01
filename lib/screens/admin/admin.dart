import 'package:flutter/material.dart';
import 'package:gulersentetik/screens/admin/kullanici/kullanici_option.dart';

import '../../contans/app_color.dart';
import '../../ui/custom_logout_icon_button.dart';
import '../worker/worker_option.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List<WorkerOptionData> listItems = [
    WorkerOptionData(name: 'Kullanıcı', tileColor: Colors.red),
    WorkerOptionData(name: 'Tezgah', tileColor: Colors.blue),
    WorkerOptionData(name: 'Arıza', tileColor: Colors.brown),
    WorkerOptionData(name: 'Vardiye', tileColor: Colors.green),
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
    return Scaffold(appBar:PreferredSize(
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
        actions: [
          CustomLogoutIconButton(),
        ],
      ),
    ),body: Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Ekrana göre responsive boyut hesaplaması yapalım
          double itemHeight = constraints.maxHeight * 0.1;
          return Center( // Wrap the ListView with a Center widget
            child: ListView.builder(
              itemCount: listItems.length,
              padding: EdgeInsets.all(itemHeight * 0.1),
              itemBuilder: (context, index) {
                WorkerOptionData item = listItems[index];

                return Column(
                  children: [
                    Container(height:itemHeight * 0.5),
                    Padding(
                      padding: EdgeInsets.all(itemHeight * 0.2),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            switch (index) {
                              case 0:
                                print('kullanıcı seçildi.');
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => KullaniciOption(),
                                ));
                                break;
                              case 1:
                              // Code to execute when the second list item ('Dokuma') is tapped
                              //   Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => FaultType1(type: "DOKUMA"),
                              //   ));
                                print('Dokuma seçildi.');
                                break;
                              case 2:
                              // Code to execute when the third list item ('Baskı') is tapped
                              //   Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => FaultType1(type: "BASKI"),
                              //   ));
                                print('Baskı seçildi.');
                                break;
                              case 3:
                              // Code to execute when the fourth list item ('Konfeksiyon') is tapped
                              //   Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => FaultType1(type: "KONFEKSİYON"),
                              //   ));
                                print('Konfeksiyon seçildi.');
                                break;
                              case 4:
                              // Code to execute when the fifth list item ('Laminasyon') is tapped
                              //   Navigator.of(context).push(MaterialPageRoute(
                              //     builder: (context) => FaultType1(type: "LAMİNASYON"),
                              //   ));
                                print('Laminasyon seçildi.');
                                break;
                            // Add more cases for other list items if needed
                            }

                          });
                          print('${item.name} seçildi.');
                        },
                        child: Container(
                          height: itemHeight,
                          decoration: BoxDecoration(
                            color: item.tileColor,
                            borderRadius: BorderRadius.circular(itemHeight * 0.2), // Kenarları yuvarlatmak için değer ayarlayın
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
    ),

    );
  }
}
