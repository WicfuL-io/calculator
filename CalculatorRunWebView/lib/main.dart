
import 'package:flutter/material.dart';
import 'project.dart';

void main() {
  runApp(const CalculatorApp());
}

class CalculatorApp extends StatelessWidget {
  const CalculatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Kalkulator Matematika',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CalculatorScreen(),
    );
  }
}

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() =>
      _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final Calculator _calculator = Calculator();

  String _output = '0';
  String _currentInput = '';
  double _num1 = 0;
  String _operator = '';
  bool _hasError = false;

  void _buttonPressed(String buttonText) {
    setState(() {
      if (buttonText == 'C') {
        _output = '0';
        _currentInput = '';
        _num1 = 0;
        _operator = '';
        _hasError = false;
        return;
      }

      if (_hasError) {
        _output = '0';
        _currentInput = '';
        _num1 = 0;
        _operator = '';
        _hasError = false;
      }

      if (['+', '-', '*', '/'].contains(buttonText)) {
        if (_currentInput.isNotEmpty) {
          _num1 = double.parse(_currentInput);
          _operator = buttonText;
          _currentInput = '';
        }
        return;
      }

      if (buttonText == '=') {
        if (_operator.isNotEmpty &&
            _currentInput.isNotEmpty) {
          final num2 = double.parse(_currentInput);

          try {
            final result = _calculator.calculate(
              _num1,
              num2,
              _operator,
            );

            _output = _calculator.formatResult(result);
            _currentInput = _output;
          } on ArgumentError catch (error) {
            _output = error.message.toString();
            _currentInput = '';
            _hasError = true;
          }

          _operator = '';
        }
        return;
      }

      _currentInput += buttonText;
      _output = _currentInput;
    });
  }

  Widget _buildButton(
    String buttonText,
    Color buttonColor,
    Color textColor,
  ) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(6),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            padding: const EdgeInsets.all(22),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: () => _buttonPressed(buttonText),
          child: Text(
            buttonText,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text(
          'Kalkulator Matematika',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(
                vertical: 36,
                horizontal: 12,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerRight,
                child: Text(
                  _output,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ),
            const Divider(),
            const Spacer(),
            Column(
              children: [
                Row(
                  children: [
                    _buildButton('7', Colors.white, Colors.black),
                    _buildButton('8', Colors.white, Colors.black),
                    _buildButton('9', Colors.white, Colors.black),
                    _buildButton(
                      '/',
                      Colors.orangeAccent,
                      Colors.white,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('4', Colors.white, Colors.black),
                    _buildButton('5', Colors.white, Colors.black),
                    _buildButton('6', Colors.white, Colors.black),
                    _buildButton(
                      '*',
                      Colors.orangeAccent,
                      Colors.white,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildButton('1', Colors.white, Colors.black),
                    _buildButton('2', Colors.white, Colors.black),
                    _buildButton('3', Colors.white, Colors.black),
                    _buildButton(
                      '-',
                      Colors.orangeAccent,
                      Colors.white,
                    ),
                  ],
                ),
                Row(
                  children: [
                    _buildButton(
                      'C',
                      Colors.redAccent,
                      Colors.white,
                    ),
                    _buildButton('0', Colors.white, Colors.black),
                    _buildButton(
                      '=',
                      Colors.blueAccent,
                      Colors.white,
                    ),
                    _buildButton(
                      '+',
                      Colors.orangeAccent,
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
