
import 'dart:math' as math;

class CalculatorEngine {
  late List<String> _tokens;
  int _position = 0;

  double calculate(String expression) {
    final normalized = expression
        .replaceAll('×', '*')
        .replaceAll('÷', '/')
        .replaceAll('−', '-')
        .replaceAll('π', 'pi')
        .replaceAll('√', 'sqrt')
        .replaceAll('²', '^2')
        .replaceAll('³', '^3')
        .replaceAll('٪', '%')
        .replaceAll(' ', '');

    if (normalized.isEmpty) {
      throw const FormatException('Masukkan perhitungan.');
    }

    final regex = RegExp(
      r'(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?'
      r'|[a-zA-Z]+|[+\-*/^()%!,]',
    );

    _tokens = [];
    int index = 0;

    for (final match in regex.allMatches(normalized)) {
      if (match.start != index) {
        throw const FormatException('Ekspresi tidak valid.');
      }
      _tokens.add(match.group(0)!);
      index = match.end;
    }

    if (index != normalized.length || _tokens.isEmpty) {
      throw const FormatException('Ekspresi tidak valid.');
    }

    _position = 0;
    final result = _expression();

    if (_position != _tokens.length) {
      throw const FormatException('Operator tidak valid.');
    }

    if (!result.isFinite) {
      throw const FormatException('Hasil di luar batas.');
    }

    return result;
  }

  String _peek() =>
      _position < _tokens.length ? _tokens[_position] : '';

  bool _match(String token) {
    if (_peek() == token) {
      _position++;
      return true;
    }
    return false;
  }

  double _expression() {
    double value = _term();

    while (_peek() == '+' || _peek() == '-') {
      final op = _tokens[_position++];
      final right = _term();
      value = op == '+' ? value + right : value - right;
    }

    return value;
  }

  double _term() {
    double value = _unary();

    while (_peek() == '*' || _peek() == '/') {
      final op = _tokens[_position++];
      final right = _unary();

      if (op == '/' && right == 0) {
        throw const FormatException('Tidak dapat membagi nol.');
      }

      value = op == '*' ? value * right : value / right;
    }

    return value;
  }

  double _unary() {
    if (_match('+')) return _unary();
    if (_match('-')) return -_unary();
    return _power();
  }

  double _power() {
    double value = _postfix();

    if (_match('^')) {
      final exponent = _unary();

      if (value == 0 && exponent < 0) {
        throw const FormatException('Hasil tidak terdefinisi.');
      }

      value = math.pow(value, exponent).toDouble();
    }

    return value;
  }

  double _postfix() {
    double value = _primary();

    while (true) {
      if (_match('%')) {
        value /= 100;
      } else if (_match('!')) {
        if (value < 0 ||
            value > 170 ||
            value != value.truncateToDouble()) {
          throw const FormatException(
            'Faktorial hanya untuk bilangan bulat 0–170.',
          );
        }

        double factorial = 1;
        for (int i = 2; i <= value.toInt(); i++) {
          factorial *= i;
        }
        value = factorial;
      } else {
        break;
      }
    }

    return value;
  }

  double _primary() {
    if (_match('(')) {
      final value = _expression();

      if (!_match(')')) {
        throw const FormatException('Kurung belum ditutup.');
      }

      return value;
    }

    final token = _peek();

    if (token.isEmpty) {
      throw const FormatException('Angka belum lengkap.');
    }

    if (RegExp(
      r'^(?:\d+(?:\.\d*)?|\.\d+)(?:[eE][+-]?\d+)?$',
    ).hasMatch(token)) {
      _position++;
      return double.parse(token);
    }

    if (RegExp(r'^[a-zA-Z]+$').hasMatch(token)) {
      _position++;
      final name = token.toLowerCase();

      if (name == 'pi') return math.pi;
      if (name == 'e') return math.e;

      if (name == 'ans') {
        throw const FormatException(
          'Gunakan hasil sebelumnya dengan menyalin hasil.',
        );
      }

      if (!_match('(')) {
        throw FormatException('Fungsi $name memerlukan tanda kurung.');
      }

      final x = _expression();

      double result;

      switch (name) {
        case 'sqrt':
          if (x < 0) {
            throw const FormatException('Akar negatif tidak real.');
          }
          result = math.sqrt(x);
          break;

        case 'cbrt':
          result = x < 0
              ? -math.pow(-x, 1 / 3).toDouble()
              : math.pow(x, 1 / 3).toDouble();
          break;

        case 'sin':
          result = math.sin(x * math.pi / 180);
          break;

        case 'cos':
          result = math.cos(x * math.pi / 180);
          break;

        case 'tan':
          if ((x % 180).abs() == 90) {
            throw const FormatException(
              'Tan tidak terdefinisi pada sudut ini.',
            );
          }
          result = math.tan(x * math.pi / 180);
          break;

        case 'asin':
          if (x < -1 || x > 1) {
            throw const FormatException('Nilai asin harus -1 sampai 1.');
          }
          result = math.asin(x) * 180 / math.pi;
          break;

        case 'acos':
          if (x < -1 || x > 1) {
            throw const FormatException('Nilai acos harus -1 sampai 1.');
          }
          result = math.acos(x) * 180 / math.pi;
          break;

        case 'atan':
          result = math.atan(x) * 180 / math.pi;
          break;

        case 'log':
          if (x <= 0) {
            throw const FormatException('Log harus lebih besar dari nol.');
          }
          result = math.log(x) / math.ln10;
          break;

        case 'ln':
          if (x <= 0) {
            throw const FormatException('Ln harus lebih besar dari nol.');
          }
          result = math.log(x);
          break;

        case 'abs':
          result = x.abs();
          break;

        case 'exp':
          result = math.exp(x);
          break;

        case 'floor':
          result = x.floorToDouble();
          break;

        case 'ceil':
          result = x.ceilToDouble();
          break;

        case 'round':
          result = x.roundToDouble();
          break;

        case 'recip':
          if (x == 0) {
            throw const FormatException('Tidak dapat membagi nol.');
          }
          result = 1 / x;
          break;

        default:
          throw FormatException('Fungsi $name tidak dikenal.');
      }

      if (!_match(')')) {
        throw const FormatException('Kurung fungsi belum ditutup.');
      }

      return result;
    }

    throw const FormatException('Angka atau fungsi tidak valid.');
  }

  String formatResult(double value) {
    if (!value.isFinite) return 'Tidak terdefinisi';

    if (value == 0) return '0';

    if (value.abs() < 1e15 &&
        value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsPrecision(12)
        .replaceAll(RegExp(r'0+$'), '')
        .replaceAll(RegExp(r'\.$'), '');
  }
}
