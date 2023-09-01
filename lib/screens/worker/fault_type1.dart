import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gulersentetik/contans/globals.dart';
import 'package:gulersentetik/screens/worker/fault_report_screen.dart';
import 'package:http/http.dart' as http;

import '../../contans/app_color.dart';

class FaultType1 extends StatefulWidget {
  String type;


  FaultType1({required this.type});

  @override
  State<FaultType1> createState() => _FaultType1State();
}

class _FaultType1State extends State<FaultType1> {
  List<String> arizaListesi = [];
  bool isloading = false;

  Future<void> fetchArizalar() async {
    final response = await http.post(
      Uri.parse('$baseUrl/GenelArizaBolumGetir.php'),
    );

    if (response.statusCode == 200) {
      setState(() {
        arizaListesi = List.from(json.decode(response.body));
        isloading = true;
      });
    }

  }
  double calculateTitlePadding(double screenWidth) {
    // Calculate the desired padding value based on the screen width
    // You can adjust the multiplier (0.2 in this example) as needed
    return screenWidth * 0.14;
  }
@override
  void initState() {
    // TODO: implement initState
    fetchArizalar();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final titlePadding = calculateTitlePadding(screenWidth);

    return Scaffold(
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
          actions: [IconButton(
            onPressed: () {
              setState(() {
                isloading = false;
              });
              fetchArizalar();
            },
            icon: Icon(Icons.refresh,size: 40,), // Yenileme ikonu
          ),],
        ),
      ),
      body: isloading?Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 16.0,bottom: 8.0,right: 8.0,left: 8.0),
                    child: Center(
                      child: Text(
                        "${widget.type}",
                        style: TextStyle(fontSize: 24, color: AppColors.profilBackground,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text(
                        "Arıza Türünü Seçin",
                        style: TextStyle(fontSize: 24, color: AppColors.profilBackground,fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 4,
              child: ListView.builder(
                itemCount: arizaListesi.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.all(10.0),
                    child: GestureDetector(
                      onTap: () {
                        String selectedFault = arizaListesi[index];
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => FaultReportScreen(fault_type: selectedFault, section: widget.type),
                        ));
                      },
                      child: Container(
                        height: screenHeight * 0.1,
                        decoration: BoxDecoration(
                          color: AppColors.profilBackground,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          child: Text(
                            arizaListesi[index],
                            style: TextStyle(fontSize: 24, color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ) :Center(child: CircularProgressIndicator()),
    );
  }
}
