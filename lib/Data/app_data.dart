import '../contans/globals.dart';

class AppData{
  static bool checkUserLoggedIn() {
    // Kullanıcı giriş yapmışsa ve currentUser doluysa true döndür, aksi halde false döndür
    return currentUser != null;
  }
}