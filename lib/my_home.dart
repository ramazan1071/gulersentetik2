import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gulersentetik/contans/app_color.dart';
import 'package:gulersentetik/contans/globals.dart';
import 'package:gulersentetik/screens/admin/admin.dart';
import 'package:gulersentetik/screens/master/electric/master_page.dart';
import 'package:gulersentetik/screens/master/mechanic/mechanic_option_page.dart';
import 'package:gulersentetik/screens/periodic/maintenance_page.dart';
import 'package:gulersentetik/screens/worker/worker_option.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'Model/user_model.dart';

class MyHome extends StatefulWidget {
  const MyHome({Key? key}) : super(key: key);

  @override
  State<MyHome> createState() => _MyHomeState();
}

class _MyHomeState extends State<MyHome> {
  String? kullaniciadi;
  TextEditingController _passwordController = TextEditingController(text: "");
  bool isPasswordVisible = false;
  bool pressed = false;
  String _bolum = '';
  bool _isLoading = false;
  List<String> data = [];

  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final password = _passwordController.text.trim();
      final username = kullaniciadi;

      final response = await http.post(
        Uri.parse(baseUrl + "/KullaniciKaydi.php"),
        body: {
          'username': kullaniciadi,
          'password': password,
        },
      );
      print("response değeri : ${response.statusCode}");

      if (response.statusCode == 200) {
        final bolum = jsonDecode(response.body);
        setState(() {
          _bolum = bolum;
          String arananKelime = "PERİYODİK";

          //periyodikse buraya at
          if (_bolum.contains(arananKelime)) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MaintenancePage(turu: _bolum,)),
                  (Route<dynamic> route) => false,

            );
          }
          else{
            //diğer bölümler
            if (_bolum == "isci") {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => WorkerOption()),
                  (Route<dynamic> route) => false,
            );

          } else if (_bolum == "admin") {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => AdminPage()),
                  (Route<dynamic> route) => false,
            );

          } else if (_bolum == "ELEKTRİK") {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MasterPage(bolum: _bolum,)),
                  (Route<dynamic> route) => false,
            );

          }
          else if (_bolum == "MEKANİK") {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MechanicOptionPage(bolum: _bolum,)),
                  (Route<dynamic> route) => false,
            );
          }

            else if (_bolum != "isci" && _bolum !="admin" && _bolum != "ELEKTRİK" && _bolum != "MEKANİK" && _bolum.isNotEmpty){
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MasterPage(bolum: _bolum,)),
                  (Route<dynamic> route) => false,
            );
             }
          }

          // Giriş yapıldığında kullanıcı bilgilerini currentUser'a kaydediyoruz
          currentUser = User(
            username: username!,
            password: password,
            bolum: _bolum,
          );

          // currentUser'ı SharedPreferences üzerine kaydediyoruz
          _saveUserData();


        });
      }

      else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Hata"),
            content: Text("Kullanıcı adı veya şifre hatalı."),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Tamam"),
              ),
            ],
          ),
        );
      }

    } catch (e) {
      print("burada hata : ${e}");
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hata"),
          content: Text("${e}"),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Tamam"),
            ),
          ],
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Kullanıcı bilgilerini SharedPreferences üzerinde kaydeden fonksiyon
  void _saveUserData() async {
    if (currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      final userData = jsonEncode(currentUser!.toJson());
      prefs.setString('userData', userData);
    }
  }


  void _checkUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');

    if (userData != null) {
      // JSON dizesini User nesnesine çevirin
      User user = User.fromJson(jsonDecode(userData));

      // Değerleri ilgili controller'lara atayın
      kullaniciadi = user.username;
      _passwordController.text = user.password;
      _bolum = user.bolum;
    }
  }

  Future<void> fetchData() async {
    String url = '$baseUrl/ArizaKullaniciAdiGetir.php'; // Replace with your PHP file URL
    try {

      final response = await http.get(Uri.parse(url));
      print("çalıştı : ${response.body}");
      if (response.statusCode == 200) {
        setState(() {
          data = List.from(json.decode(response.body));

        });
      } else {
        _isLoading = true;
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        data = [];
      });
    }
  }

  @override
  void initState() {
    print("user: ${kullaniciadi}");
    super.initState();
    fetchData();
    _checkUserData();
    print("user: ${kullaniciadi}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0,bottom: 20,top:50,),
                  child: Image.asset('assets/img/logo.jpeg', width: 300, height: 200),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 16.0, bottom: 16.0, right: 16.0,left: 16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.850,
                      child: ElevatedButton(
                        onPressed: () {
                          _showDropdownList(
                            context,
                            data.map((item) => item).toList(),
                            "kullaniciadi",
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
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  kullaniciadi??"Kullanıcı  Adı",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 20,color:Colors.black54),
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
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextFormField(
                    style: const TextStyle(fontSize: 20),
                    controller: _passwordController,
                    obscureText: isPasswordVisible,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Parola',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.profilBackground),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: IconButton(
                          onPressed: () {
                            setState(() {
                              isPasswordVisible = !isPasswordVisible;
                            });
                          },
                          icon: Icon(
                            isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (_passwordController.text.isNotEmpty && kullaniciadi!.isNotEmpty) {
                        setState(() {
                          pressed = true;
                        });
                      } else {
                        setState(() {
                          pressed = false;
                        });
                      }
                      print("Girilen değer password: $value");
                    },
                  ),
                ),
                _isLoading
                    ? CircularProgressIndicator()
                    : Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_passwordController.text != "" && kullaniciadi!.isNotEmpty) {
                          print("basıldı home");
                          print("name: ${kullaniciadi}");
                          print("password: ${_passwordController.text}");
                          pressed = false;
                          _login();
                          kullaniciadi=null;
                          _passwordController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        primary: pressed ? AppColors.profilBackground : Colors.grey,
                        onPrimary: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: GestureDetector(
                          child: Text(
                            'Giriş Yap',
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top:20.0),
                  child: Column(
                    children: [
                      Text("Stratejik Projeler Müdürlüğü | ABS PROJESİ",style: TextStyle(fontSize: 15),),
                      Text("Created By | Özgür EGE | 2023 | V.1.0.0",style: TextStyle(fontSize: 15),),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

  }
  void _showDropdownList(BuildContext context, List<String> itemList,
      String secim) {
    final double itemHeight = 60.0;
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
                    (secim == "kullaniciadi"
                        ? kullaniciadi
                        : kullaniciadi); // Seçilen öğeyi kontrol ediyoruz

                return ListTile(
                  title: Text(valueItem),
                  tileColor: isSelected ? Colors.green : null,
                  // Seçili öğenin arkaplan rengini ayarlıyoruz (Yeşil renk)
                  onTap: () {
                    setState(() {
                      kullaniciadi = valueItem;
                        pressed = true;
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
