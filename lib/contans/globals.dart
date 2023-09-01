 import '../Model/user_model.dart';

String baseUrl = "http://192.168.1.164:85";
 String username = "Administrator";
 String password = "Mefapex123.";
 bool isLogin = false;
 User? currentUser;
 double calculateTitlePadding(double screenWidth) {
  // Calculate the desired padding value based on the screen width
  // You can adjust the multiplier (0.2 in this example) as needed
  return screenWidth * 0.14;
 }