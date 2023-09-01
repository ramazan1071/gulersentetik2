import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:grock/grock.dart';
import 'package:http/http.dart' as http;

import 'contans/globals.dart';
class FirebaseNotificationService {
  late final FirebaseMessaging messaging;

  void settingNotification() async {
    await messaging.requestPermission(
      alert: true,
      sound: true,
      badge: true,
    );

  }
  void addDeviceToken(String token) async {
    String url = '$baseUrl/DeviceTokenAl.php';

    print("token : ${token}");
    print("bolum: ${currentUser?.bolum}");
    try {
      String bolumal=currentUser?.bolum??"isci";
      print("bolumal: ${bolumal}");
      var response = await http.post(
        Uri.parse(url),
        body: {'device': token,'bolum':bolumal}, // Cihaz token'ınızı buraya ekleyin
      );

      if (response.statusCode == 200) {
        print('Veri eklendi: ${response.body}');
      } else {
        print('Hata: ${response.statusCode}');
      }
    } catch (e) {
      print('Bağlantı hatası: $e');
    }
  }


  void connectNotification() async {
    await Firebase.initializeApp();
    messaging = FirebaseMessaging.instance;
    messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      sound: true,
      badge: true,
    );

    settingNotification();
    FirebaseMessaging.onMessage.listen((RemoteMessage event) {
      Grock.snackBar(title: "${event.notification?.title}",
          description: "${event.notification?.body}",
          opacity: 0.5,
          position: SnackbarPosition.top,
          );
    });
    messaging.getToken().then((value) => addDeviceToken(value!));
  }

 static Future<void>backgrounMessage(RemoteMessage message)async{
    await Firebase.initializeApp();
  }
}