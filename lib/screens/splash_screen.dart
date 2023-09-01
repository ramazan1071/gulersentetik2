import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gulersentetik/my_home.dart';
import 'package:gulersentetik/screens/admin/admin.dart';
import 'package:gulersentetik/screens/master/electric/master_page.dart';
import 'package:gulersentetik/screens/periodic/maintenance_page.dart';
import 'package:gulersentetik/screens/worker/worker_option.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../Data/app_data.dart';
import '../Model/user_model.dart';
import '../contans/globals.dart';
import '../service.dart';
import '../ui/standart_circuler_progress.dart';
import 'master/mechanic/mechanic_option_page.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override

  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isLoading = false;
  @override
  final _service =FirebaseNotificationService();
  void initState() {
    _service.connectNotification();
    super.initState();
    asyncInit();
  }

  // SharedPreferences'den verileri alacak asenkron metot
  Future<User?> _getUserDataFromSharedPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString('userData');
    final savedBolum = prefs.getString('bolum');

    if (userData != null) {
      // JSON dizesini User nesnesine çevirin
      User user = User.fromJson(jsonDecode(userData));
      return User(username: user.username, password: user.password, bolum: user.bolum);
    }
     else {
      return null;
    }
  }
  // Giriş yapıldıysa veya currentUser boşsa yönlendirilecek metot
  void _checkUserLoggedIn() {
    print("buraya düştü : ${currentUser}");
    if (currentUser != null) {
      // Giriş yapılmışsa yönlendirilecek sayfa

      print("burası çalıştı ${currentUser}");
      print("içindeki bolum: ${currentUser?.bolum}");
      _login();
    } else {
      // Giriş yapılmamışsa veya currentUser boşsa yönlendirilecek sayfa
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => MyHome()),
            (Route<dynamic> route) => false,
      );
    }
  }
  void _login() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        Uri.parse(baseUrl + "/KullaniciKaydi.php"),
        body: {
          'username': currentUser?.username,
          'password': currentUser?.password,
        },
      );

      if (response.statusCode == 200) {
        print("bolum : ${response.statusCode}");

        final bolum = jsonDecode(response.body);
        setState(() {
          print("current : ${currentUser?.bolum}");
          String arananKelime = "PERİYODİK";
          print("hello : ${currentUser!.bolum.contains(arananKelime)}");

          //periyodikse buraya at
          if (currentUser!.bolum.contains(arananKelime)) {

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => MaintenancePage(turu: currentUser!.bolum,)),
                  (Route<dynamic> route) => false,

            );
          }
          //diğer girişler
          else {
            if (currentUser?.bolum == "isci") {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => WorkerOption()),
                    (Route<dynamic> route) => false,
              );
            }
            else if (currentUser?.bolum == "admin") {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => AdminPage()),
                    (Route<dynamic> route) => false,
              );
            }
            else if (currentUser?.bolum == "ELEKTRİK") {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) =>
                    MasterPage(bolum: currentUser!.bolum,)),
                    (Route<dynamic> route) => false,
              );
            }
            else if (currentUser?.bolum == "MEKANİK") {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) =>
                    MechanicOptionPage(bolum: currentUser!.bolum,)),
                    (Route<dynamic> route) => false,
              );
            }
            else
            if (currentUser?.bolum != "isci" && currentUser?.bolum != "admin" &&
                currentUser?.bolum != "ELEKTRİK" &&
                currentUser?.bolum != "MEKANİK" &&
                currentUser!.bolum.isNotEmpty) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) =>
                    MasterPage(bolum: currentUser!.bolum,)),
                    (Route<dynamic> route) => false,
              );
            }
          }
        });
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyHome()),
              (Route<dynamic> route) => false,
        );
      }
    }
    catch (e) {
      // Hata mesajını göster
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hata"),
          content: Text("Veri alınırken bir hata oluştu."),
        ),
      );

      // SharedPreferences'den verileri temizle (isteğe bağlı olarak)
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      // MyHome sayfasına yönlendir (isteğe bağlı olarak)
      Future.delayed(Duration.zero, () {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => MyHome()),
              (Route<dynamic> route) => false,
        );
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  asyncInit() async {
    currentUser = await _getUserDataFromSharedPreferences();
    print("currentuser ${currentUser?.password}");
    _checkUserLoggedIn();
    if (AppData.checkUserLoggedIn()) {
      // TODO: Giriş yapıldıysa yönlendirilecek sayfa
      // Örneğin:
      _login();
      print("ilk if çalıştı ${currentUser?.username}");
    }
    else {
    // TODO: Giriş yapılmamışsa veya currentUser boşsa yönlendirilecek sayfa
    // Örneğin:
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyHome()),
          (Route<dynamic> route) => false,
    );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                child: Image.asset("assets/img/logo.jpeg",width: 700),
              ),
            ),
            StandartCircularProgress()
          ],
        ),
      ),
    );
  }
}
