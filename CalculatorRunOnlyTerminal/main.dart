
import 'dart:io';
import 'project.dart';

void main() {
  final calculator = Calculator();

  print('======================================');
  print('        KALKULATOR DART');
  print('======================================');

  while (true) {
    print('\nPilih operasi matematika:');
    print('1. Penjumlahan (+)');
    print('2. Pengurangan (-)');
    print('3. Perkalian (*)');
    print('4. Pembagian (/)');
    print('0. Keluar');

    stdout.write('\nMasukkan pilihan: ');
    final pilihan = stdin.readLineSync()?.trim();

    if (pilihan == '0') {
      print('\nTerima kasih telah menggunakan kalkulator.');
      break;
    }

    String operator;

    switch (pilihan) {
      case '1':
        operator = '+';
        break;
      case '2':
        operator = '-';
        break;
      case '3':
        operator = '*';
        break;
      case '4':
        operator = '/';
        break;
      default:
        print('Pilihan tidak valid. Silakan coba lagi.');
        continue;
    }

    stdout.write('Masukkan angka pertama: ');
    final num1 = double.tryParse(
      stdin.readLineSync()?.trim() ?? '',
    );

    if (num1 == null || !num1.isFinite) {
      print('Input angka pertama tidak valid.');
      continue;
    }

    stdout.write('Masukkan angka kedua: ');
    final num2 = double.tryParse(
      stdin.readLineSync()?.trim() ?? '',
    );

    if (num2 == null || !num2.isFinite) {
      print('Input angka kedua tidak valid.');
      continue;
    }

    try {
      final result = calculator.calculate(num1, num2, operator);
      final formattedResult = calculator.formatResult(result);

      print('\n--------------------------------------');
      print(
        'Hasil: ${calculator.formatResult(num1)} '
        '$operator ${calculator.formatResult(num2)} '
        '= $formattedResult',
      );
      print('--------------------------------------');
    } on ArgumentError catch (error) {
      print('\nKesalahan: ${error.message}');
    }
  }
}
