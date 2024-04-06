import 'package:calculator/button_values.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class CalculatorScreen extends HookWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final number1 = useState("");
    final operand = useState("");
    final number2 = useState("");
    final screenSize = MediaQuery.of(context).size;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            //sonuc kismi.
            Expanded(
              child: SingleChildScrollView(
                reverse: true,
                child: Container(
                  alignment: Alignment.bottomRight,
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    "${number1.value}${operand.value}${number2.value}".isEmpty
                        ? "0"
                        : "${number1.value}${operand.value}${number2.value}",
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ),
            //butonlarin oldugu kisim.
            Wrap(
              children: Btn.buttonValues
                  .map(
                    (value) => SizedBox(
                      width: value == Btn.n0
                          ? screenSize.width / 2
                          : (screenSize.width / 4),
                      height: screenSize.width / 5,
                      child: buildButton(value, number1, operand, number2),
                    ),
                  )
                  .toList(),
            )
          ],
        ),
      ),
    );
  }

  Widget buildButton(value, ValueNotifier<String> number1,
      ValueNotifier<String> operand, ValueNotifier<String> number2) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Material(
        color: getBtnColor(value),
        clipBehavior: Clip.hardEdge,
        shape: OutlineInputBorder(
          borderSide: const BorderSide(
            color: Colors.white24,
          ),
          borderRadius: BorderRadius.circular(100),
        ),
        child: InkWell(
          onTap: () => onBtnTap(value, number1, operand, number2),
          child: Center(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ########
  void onBtnTap(String value, ValueNotifier<String> number1,
      ValueNotifier<String> operand, ValueNotifier<String> number2) {
    // value'nun ne olduguna gore islem yap.
    if (value == Btn.del) {
      delete(number1, operand, number2);
      return;
    }

    if (value == Btn.clr) {
      clearAll(number1, operand, number2);
      return;
    }

    if (value == Btn.per) {
      convertToPercentage(number1, operand, number2);
      return;
    }

    if (value == Btn.calculate) {
      calculate(number1, operand, number2);
      return;
    }

    appendValue(value, number1, operand, number2);
  }

  // ##############
  // calculates the result
  void calculate(ValueNotifier<String> number1, ValueNotifier<String> operand,
      ValueNotifier<String> number2) {
    if (number1.value.isEmpty) return;
    if (operand.value.isEmpty) return;
    if (number2.value.isEmpty) return;

    // String'den double'a cevir.
    final double num1 = double.parse(number1.value);
    final double num2 = double.parse(number2.value);

    var result = 0.0;
    switch (operand.value) {
      // operatorlere gore islem yap.
      case Btn.add:
        result = num1 + num2;
        break;
      case Btn.subtract:
        result = num1 - num2;
        break;
      case Btn.multiply:
        result = num1 * num2;
        break;
      case Btn.divide:
        result = num1 / num2;
        break;
      default:
    }

    // sonucu String'e cevir.
    number1.value = result.toStringAsPrecision(3);

    // eger tam sayi ise .0'ı sil.
    if (number1.value.endsWith(".0")) {
      number1.value = number1.value.substring(0, number1.value.length - 2);
    }

    operand.value = "";
    number2.value = "";
  }

  // degerleri yuzdeye cevirir.
  void convertToPercentage(ValueNotifier<String> number1,
      ValueNotifier<String> operand, ValueNotifier<String> number2) {
    // ornek: 434+324
    if (number1.value.isNotEmpty &&
        operand.value.isNotEmpty &&
        number2.value.isNotEmpty) {
      // cevirme islemi yapmadan once hesap yap.
      calculate(number1, operand, number2);
    }

    if (operand.value.isNotEmpty) {
      // bu durumda cevirme yapamayiz.
      return;
    }

    final number = double.parse(number1.value);
    number1.value = "${(number / 100)}";
    operand.value = "";
    number2.value = "";
  }

  // butun degerleri temizler.
  void clearAll(ValueNotifier<String> number1, ValueNotifier<String> operand,
      ValueNotifier<String> number2) {
    number1.value = "";
    operand.value = "";
    number2.value = "";
  }

  // son eklenen degeri siler.
  void delete(ValueNotifier<String> number1, ValueNotifier<String> operand,
      ValueNotifier<String> number2) {
    if (number2.value.isNotEmpty) {
      // 12323 => 1232
      number2.value = number2.value.substring(0, number2.value.length - 1);
    } else if (operand.value.isNotEmpty) {
      operand.value = "";
    } else if (number1.value.isNotEmpty) {
      number1.value = number1.value.substring(0, number1.value.length - 1);
    }
  }

  // sona deger ekler.
  void appendValue(String value, ValueNotifier<String> number1,
      ValueNotifier<String> operand, ValueNotifier<String> number2) {
    // number1 operator number2
    // 234       +      5343

    // eger bir operator ise ve deger sayi degilse.
    if (value != Btn.dot && int.tryParse(value) == null) {
      // operator basilmis.
      if (operand.value.isNotEmpty && number2.value.isNotEmpty) {
        calculate(number1, operand, number2);
      }
      operand.value = value;
    }
    // value'u number1'e ata.
    else if (number1.value.isEmpty || operand.value.isEmpty) {
      // eger deger "." ise ve number1'de "." varsa.
      if (value == Btn.dot && number1.value.contains(Btn.dot)) return;
      if (value == Btn.dot &&
          (number1.value.isEmpty || number1.value == Btn.n0)) {
        // ornek: number1 = "" | "0"
        value = "0.";
      }
      number1.value += value;
    }
    // value'u number2'ye ata.
    else if (number2.value.isEmpty || operand.value.isNotEmpty) {
      // eger deger "." ise ve number2'de "." varsa.
      if (value == Btn.dot && number2.value.contains(Btn.dot)) return;
      if (value == Btn.dot &&
          (number2.value.isEmpty || number2.value == Btn.n0)) {
        // number1 = "" | "0"
        value = "0.";
      }
      number2.value += value;
    }
  }

  // ########
  Color getBtnColor(value) {
    return [Btn.del, Btn.clr].contains(value)
        ? Colors.blueGrey
        : [
            Btn.per,
            Btn.multiply,
            Btn.add,
            Btn.subtract,
            Btn.divide,
            Btn.calculate,
          ].contains(value)
            ? Colors.orange
            : Colors.black87;
  }
}
