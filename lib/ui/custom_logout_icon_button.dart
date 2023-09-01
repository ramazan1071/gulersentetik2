import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../my_home.dart';

class CustomLogoutIconButton extends StatelessWidget {
  // SharedPreferences'den verileri silmek için asenkron metot
  Future<void> _removeUserData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.remove('userData');
  }

  // Çıkış yapma işlemini gerçekleştiren metot
  void _logout(BuildContext context) {
    _removeUserData();
    // Çıkış yapıldığında yönlendireceğiniz sayfayı burada belirleyin.
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MyHome()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.exit_to_app, size: 35),
      onPressed: () {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text("Çıkış Yap"),
              content: Text("Çıkış yapmak istediğinizden emin misiniz?"),
              actions: [
                TextButton(
                  onPressed: () {
                    // Burada çıkış yapma işlemini gerçekleştirebilirsiniz.
                    // Örneğin, kullanıcıyı giriş ekranına yönlendirebilirsiniz.
                    _logout(context);
                    // Çıkış işlemi yapılacak
                  },
                  child: Text("Evet"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // İptal işlemi yapılacak
                  },
                  child: Text("İptal"),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
