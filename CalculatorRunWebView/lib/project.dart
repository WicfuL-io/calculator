
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
          throw ArgumentError('Error: Bagi 0!');
        }
        return num1 / num2;

      default:
        throw ArgumentError('Operator tidak valid!');
    }
  }

  String formatResult(double value) {
    if (!value.isFinite) {
      return value.toString();
    }

    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value.toString();
  }
}
