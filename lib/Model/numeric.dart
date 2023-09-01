import 'package:flutter/services.dart';

class NumericTextInputFormatter extends TextInputFormatter {
  final int minValue; // Dışarıdan alınacak minimum değeri tutacak değişken
  final int maxValue; // Dışarıdan alınacak maksimum değeri tutacak değişken

  NumericTextInputFormatter({required this.minValue, required this.maxValue});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    // Sadece sayısal değerleri ve dışarıdan alınan minimum ve maksimum değerleri kabul etmek için kontrolleri yapalım
    if (newValue.text.isEmpty) {
      return newValue;
    } else {
      int parsedValue = int.tryParse(newValue.text) ?? 0;

      if (parsedValue < minValue) {
        parsedValue = minValue;
      } else if (parsedValue > maxValue) {
        parsedValue = maxValue;
      }

      return TextEditingValue(
        text: parsedValue.toString(),
        selection: TextSelection.collapsed(offset: parsedValue.toString().length),
      );
    }
  }
}
