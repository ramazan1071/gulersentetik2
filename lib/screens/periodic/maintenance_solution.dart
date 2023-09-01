import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:grock/grock.dart';
import 'package:gulersentetik/ui/standart_circuler_progress.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import '../../Data/tezgah_sayisi_repository.dart';
import '../../Model/numeric.dart';
import '../../Model/tezgah_sayisi_model.dart';
import '../../contans/app_color.dart';
import '../../contans/globals.dart';
import '../../ui/custom_logout_icon_button.dart';
import '../splash_screen.dart';


class Item {
  String malzeme;
  int adet;

  Item(this.malzeme, this.adet);
}
class User2 {
  String name;
  bool isEdited;

  User2(this.name, {this.isEdited = false});
}

class MaintenanceSolution extends StatefulWidget {
  String bolum;
  String turu;
  MaintenanceSolution({required this.bolum,required this.turu});

  @override
  State<MaintenanceSolution> createState() => _MaintenanceSolutionState();
}

class _MaintenanceSolutionState extends State<MaintenanceSolution> {
  final TezgahSayisiProvider _tezgahSayisiProvider = TezgahSayisiProvider();
  List<TezgahSayisiModel> _tezgahSayilari = [];
  TextEditingController tezgahNo = TextEditingController(text: "");
  bool isloading = false;
  List<String> kullaniciListesi = [];
  String? valueChooseNS;
  String? valueChooseAT;
  bool pressed = false;
  String sonBakimTarih = "";
  List<Item> items = [];


  final TextEditingController _malzemeNameController = TextEditingController();
  final TextEditingController _malzemeSayisiController = TextEditingController();
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

  });
          }
    else {
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
      if(tezgahNo.text.isNotEmpty &&  items.isNotEmpty && _startTime.isNotEmpty && userList.isNotEmpty && selectedStartDate.isNotEmpty){
        pressed = true;
      }
      else{
        pressed =false;
      }
    });
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
  // başlangıç tarih
  DateTime? selectedStartDate;
  final formatter = NumberFormat('#,###.00', 'tr_TR');


  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedStartDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      locale: Locale('tr', ''),
    );

    if (picked != null && picked != selectedStartDate) {
      setState(() {
        selectedStartDate = picked;
        if(tezgahNo.text.isNotEmpty && items.isNotEmpty && _startTime.isNotEmpty && userList.isNotEmpty && selectedStartDate.isNotEmpty){
          pressed = true;
        }
        else{
          pressed =false;
        }
      });
    }
  }
  //başlangıç saati
  TimeOfDay? _startTime;

  Future<void> _selectStartTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != _startTime) {
      setState(() {
        _startTime = picked;
        if(tezgahNo.text.isNotEmpty && items.isNotEmpty && _startTime.isNotEmpty && userList.isNotEmpty && selectedStartDate.isNotEmpty){
          pressed = true;
        }
        else{
          pressed =false;
        }
      });
    }
  }

  //Usta ekle sil güncelle
  // Ekle butonuna tıklanınca çalışan işlev
  List<User2> userList = [];

  void addUser(String name) {
    setState(() {
      if (!userList.any((user) => user.name == name)) {
        userList.add(User2(name));
      }
    });
  }

  void deleteUser(int index) {
    setState(() {
      userList.removeAt(index);
      if(tezgahNo.text.isNotEmpty && items.isNotEmpty && _startTime.isNotEmpty && userList.isNotEmpty && selectedStartDate.isNotEmpty){
        pressed = true;
      }
      else{
        pressed =false;
      }
    });
  }


  /////////////////
  Future<void> getDataFromServer() async {
    kullaniciListesi.clear();
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/ArizaIsımSoyısımGetir.php"),
        body: {
          'BOLUM': widget.turu,//STATİK
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
  Future<void> _getTezgahSayilari() async {
    try {
      print("deney = ${widget.bolum}");
      final tezgahSayilari = await _tezgahSayisiProvider.getTezgahSayilari(widget.bolum);
      setState(() {
        _tezgahSayilari = tezgahSayilari;
        print("tezgah: ${_tezgahSayilari[0].tezgahSayisi}");
      });
    } catch (e) {
      // Hata yönetimi burada yapılabilir
    }
  }


  Future<void> loadData() async {
    await _getTezgahSayilari();
    await getDataFromServer();
    setState(() {
      // Veriler geldiğinde durumu güncelle
      isloading = true;
    });
  }




  @override
  void initState() {
    // TODO: implement initState
    loadData();
    super.initState();
  }

  Future<void> fetchDataTarih() async {
    final response = await http.post(
      Uri.parse(baseUrl + '/BakimSonTarihGetir.php'), // API URL'sini buraya girin
      body: {
        'TEZGAHNO': tezgahNo.text, // TEZGAH_NO değerini buraya girin
        'ARIZATURU': widget.turu, // ARIZA_TURU değerini buraya girin
        'ARIZABOLUM': widget.bolum, // ARIZA_BOLUM değerini buraya girin
      },
    );

    print("gelen : ${response.body}");
    print("gelen : ${response.statusCode}");

    if (response.statusCode == 200) {

      setState(() {
        if(response.body == "false"){
          sonBakimTarih = 'Yok';
        }
        else{
          sonBakimTarih = json.decode(response.body);
        }

      });
    } else {
      setState(() {
        sonBakimTarih = "Veri çekilemedi";
      });
    }


  }

  Future<void> sendData() async {
    //İTEMS al
    String malzeme ="";
    for(var i =0;i<items.length;i++){
      if(malzeme.isNotEmpty){
        malzeme=malzeme + ","+items[i].malzeme + "(${items[i].adet})";
      }
      else{
        malzeme=items[i].malzeme + "(${items[i].adet})";
      }
    }
    String zaman_saat = "";
    String formatTime(TimeOfDay time) {
      return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
    }
    //başlangıç zamanı aldım
    zaman_saat=formatTime(_startTime!);


    String zaman_tarih ="";
    //başlangıç tarih
    String formatDate(DateTime date) {
      final formatter = DateFormat('yyyy-MM-dd', 'tr_TR');
      return formatter.format(date);
    }
    zaman_tarih = formatDate(selectedStartDate!);

    String isimler ="";

    for(var i =0;i<userList.length;i++) {
      if (isimler.isNotEmpty) {
        isimler =
            isimler + "," + userList[i].name;
      }
      else {
        isimler = userList[i].name;
      }
    }

    final response = await http.post(
      Uri.parse('$baseUrl/BakimEkle.php'), // API URL'sini buraya girin
      body: {
        'TEZGAH_NO': tezgahNo.text,
        'ISIM_SOYISIM': isimler.toString(),
        'MALZEME': malzeme.toString(),
        'ARIZA_BOLUM': widget.bolum,
        'ARIZA_TURU':  widget.turu,
        'BASLANGIC_SAAT': zaman_saat,
        'BASLANGIC_TARIH': zaman_tarih,
      },
    );

      if (response.statusCode == 200) {
        print("bakım ekle");
        print("bakım response : ${response.body}");
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
            content: Text("Bakım Yapıldı"),
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
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final titlePadding = calculateTitlePadding(screenWidth);
    return  Scaffold(appBar: PreferredSize(
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
    ),body: isloading?SingleChildScrollView(child: Column(
      children: [
        Container(),
        Row(mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [  Expanded(flex: 1, child: Container()),
            Expanded(flex:9,child: Text("Tezgah No :",style: TextStyle(fontSize: 18,fontWeight: FontWeight.bold),)),
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
                             fetchDataTarih();
                             if(tezgahNo.text.isNotEmpty &&  items.isNotEmpty && _startTime.isNotEmpty && userList.isNotEmpty && selectedStartDate.isNotEmpty){
                               pressed = true;
                             }
                             else{
                               pressed =false;
                             }
                           // deneme(value);//buraya işte son tarihi bakarak atıyıcağız.
                            // if (valueChooseR != null && valueChooseVS != null && tezgahNo.text.isNotEmpty) {
                            //   pressed = true;
                            // } else {
                            //   pressed = false;
                            // }
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
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Divider(height: 1,color: Colors.grey,),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(flex: 1, child: Container()),
            Expanded(
                flex: 9,
                child: Text(
                  "Son Bakım Tarihi :",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                )),
            Expanded(
              flex: 4,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 16.0, bottom: 16.0, right: 8.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.55,
                    child:Text("${sonBakimTarih}", style: TextStyle(fontSize: 16, )),
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
        //isim soyisim
        Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(flex: 1, child: Container()),
                Expanded(
                    flex: 6,
                    child: Text(
                      "İsim Soyisim :",
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
              child: ElevatedButton(  style: ElevatedButton.styleFrom(
                primary: AppColors.profilBackground, // Düğme rengi
                onPrimary: Colors.white, // Yazı rengi
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Düğme iç içe boşluğu
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10), // Köşeleri yuvarlat
                ),),
                onPressed: (){
                if(valueChooseNS!.isNotEmpty){
                  addUser(valueChooseNS!);
                  valueChooseNS="";
                }
                if(tezgahNo.text.isNotEmpty &&  items.isNotEmpty && _startTime.isNotEmpty && userList.isNotEmpty && selectedStartDate.isNotEmpty){
                  pressed = true;
                }
                else{
                  pressed =false;
                }

              }, child: Text("İsim Ekle",style: TextStyle(fontSize: 16),),),
            ),
          ],
        ),
        userList.isNotEmpty?Padding(
          padding: const EdgeInsets.all(20.0),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.profilBackground),
              color: Colors.grey[300], // Gri arka plan rengi
              borderRadius: BorderRadius.circular(20),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: userList.length,
              separatorBuilder: (context, index) => Divider(), // Araya çizgi ekleniyor
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('İsim ve Soyisim : ${userList[index].name}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.delete,color: AppColors.profilBackground2,),
                        onPressed: () {
                          deleteUser(index);
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
              Container(child: Text("Eklediğiniz kişi yok",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: AppColors.profilBackground),),),

              Container(child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("(Kişi eklemek zorunludur !)",textAlign: TextAlign.center,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: AppColors.profilBackground2),),
              ),), ],
          ),
        ),

        Padding(
          padding: const EdgeInsets.only(right: 8.0,left: 8.0,top: 40.0,bottom: 60.0),
          child: Divider(height: 1,color: Colors.grey,),
        ),

        userList.isNotEmpty?Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0,left: 16.0),
              child: Row(children: [
                Text("Toplam Şu kadar Kişiyi Eklediniz : ", style: TextStyle(
                  fontSize: 15,),),
                Text("${userList.length}",
                  style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18),),
              ],),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 20.0,bottom: 20.0,left: 8.0,right: 8.0),
              child: Divider(height: 1,color: Colors.grey,),
            ),
          ],
        ):Container(),
        //kullanacağı malzeme
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: (){
                        _addItem();
                        if(tezgahNo.text.isNotEmpty && items.isNotEmpty && _startTime.isNotEmpty && userList.isNotEmpty && selectedStartDate.isNotEmpty){
                          pressed = true;
                        }
                        else{
                          pressed =false;
                        }
                      },
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
                              if(tezgahNo.text.isNotEmpty &&  items.isNotEmpty && _startTime.isNotEmpty && userList.isNotEmpty && selectedStartDate.isNotEmpty){
                                pressed = true;
                              }
                              else{
                                pressed =false;
                              }
                            },
                          ),
                          IconButton(
                            icon: Icon(Icons.delete,color: AppColors.profilBackground2,),
                            onPressed: () {
                              _removeItem(index);
                              if(tezgahNo.text.isNotEmpty &&  items.isNotEmpty && _startTime.isNotEmpty && userList.isNotEmpty && selectedStartDate.isNotEmpty){
                                pressed = true;
                              }
                              else{
                                pressed =false;
                              }
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
                  Container(child: Text("Eklediğiniz malzeme yok",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 18,color: AppColors.profilBackground),textAlign: TextAlign.center,),),
                  Container(child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text("(Malzeme kullanmadıysanız yok ve adet 0 giriniz !)",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 14,color: AppColors.profilBackground2),textAlign: TextAlign.center,),
                  ),),

                ],
              ),
            ),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 40.0,bottom: 40.0,left: 8.0,right: 8.0),
          child: Divider(height: 1,color: Colors.grey,),
        ),
        items.isNotEmpty?Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0,left: 16.0),
              child: Row(children: [
                Text("Toplam Şu kadar Malzeme Eklediniz : ", style: TextStyle(
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
        //başlangıç bitiş
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                readOnly: true,
                onTap: () =>
                  _selectStartTime(context),
                decoration: InputDecoration(
                  labelText: 'Başlangıç Saati',
                  suffixIcon: Icon(Icons.access_time),
                ),
                controller: TextEditingController(
                  text: _startTime != null ? '${_startTime!.format(context)}' : '',
                ),
              ),
            ),

          ],
        ),
        SizedBox(height: 25,),
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextFormField(
                readOnly: true,
                onTap: () =>
                    _selectStartDate(context),
                decoration: InputDecoration(
                  labelText: 'Başlangıç Tarihi',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                controller: TextEditingController(
                  text: selectedStartDate != null ? '${selectedStartDate!.day}.${selectedStartDate!.month}.${selectedStartDate!.year}' : '',
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 25,),
        ElevatedButton(
          onPressed: (){
            if(pressed){
              sendData();
              print("fonksiyonu buraya ekle");
            }
          },
          style: ElevatedButton.styleFrom(
            primary: pressed ? AppColors.profilBackground : AppColors.greyy,// Düğme rengi
            onPrimary: Colors.white, // Yazı rengi
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Düğme iç içe boşluğu
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10), // Köşeleri yuvarlat
            ),
          ),
          child: Text('Gönder', style: TextStyle(fontSize: 24)),
        ),
        SizedBox(height: 25,),
      ],
    ),):StandartCircularProgress(),);
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
