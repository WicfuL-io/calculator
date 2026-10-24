
class Calculator {
  double calculate(double num1, double num2, String operator) {
    switch (operator) {
      case '+':
        return num1 + num2;

      case '-':
        return num1 - num2;

      case '*':
        return num1 * num2;

      case '/':
        if (num2 == 0) {
          throw ArgumentError('Tidak dapat membagi dengan nol!');
        }
        return num1 / num2;

      default:
        throw ArgumentError('Operator tidak valid!');
    }
  }

  String formatResult(double result) {
    if (!result.isFinite) {
      return result.toString();
    }

    if (result == result.truncateToDouble()) {
      return result.toInt().toString();
    }

    return result.toString();
  }
}
