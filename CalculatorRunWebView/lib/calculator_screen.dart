import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'calculator_engine.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  State<CalculatorScreen> createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final CalculatorEngine _engine = CalculatorEngine();
  final TextEditingController _controller = TextEditingController();

  String _expression = '';
  String _result = '0';
  String _error = '';
  bool _calculated = false;

  final List<List<String>> _buttons = const [
    ['AC', 'DEL', '(', ')', '÷'],
    ['sin', 'cos', 'tan', '√', '×'],
    ['7', '8', '9', 'x²', '-'],
    ['4', '5', '6', 'xʸ', '+'],
    ['1', '2', '3', '%', 'π'],
    ['0', '.', '±', '!', '='],
    ['log', 'ln', 'asin', 'acos', 'atan'],
    ['cbrt', 'exp', 'abs', '1/x', 'e'],
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _press(String key) {
    setState(() {
      _error = '';

      if (key == 'AC') {
        _expression = '';
        _result = '0';
        _calculated = false;
        return;
      }

      if (key == 'DEL') {
        if (_expression.isNotEmpty) {
          _expression = _expression.substring(0, _expression.length - 1);
        }
        _calculated = false;
        return;
      }

      if (key == '=') {
        _calculate();
        return;
      }

      if (key == '±') {
        if (_expression.isEmpty) {
          _expression = '-';
        } else if (_expression.startsWith('-')) {
          _expression = _expression.substring(1);
        } else {
          _expression = '-($_expression)';
        }
        _calculated = false;
        return;
      }

      if (_calculated && RegExp(r'^[0-9.]$').hasMatch(key)) {
        _expression = '';
      }
      _calculated = false;

      switch (key) {
        case '×':
          _expression += '*';
          break;
        case '÷':
          _expression += '/';
          break;
        case 'x²':
          _expression += '^2';
          break;
        case 'xʸ':
          _expression += '^';
          break;
        case '√':
          _expression += 'sqrt(';
          break;
        case 'cbrt':
        case 'sin':
        case 'cos':
        case 'tan':
        case 'asin':
        case 'acos':
        case 'atan':
        case 'log':
        case 'ln':
        case 'exp':
        case 'abs':
          _expression += '$key(';
          break;
        case '1/x':
          _expression += 'recip(';
          break;
        default:
          _expression += key;
      }
    });
  }

  void _calculate() {
    if (_expression.isEmpty) return;

    try {
      final value = _engine.calculate(_expression);
      _result = _engine.formatResult(value);
      _expression = _result;
      _error = '';
      _calculated = true;
    } catch (e) {
      _error = e.toString().replaceFirst('FormatException: ', '');
    }
  }

  Color _buttonColor(String key) {
    if (key == '=') return const Color(0xFF8875FF);
    if (key == 'AC') return const Color(0xFFB83E58);
    if (key == 'DEL') return const Color(0xFF6B3F50);
    if ('+-×÷^%()!'.contains(key) || key == 'x²' || key == 'xʸ') {
      return const Color(0xFF34334F);
    }
    if ([
      'sin',
      'cos',
      'tan',
      '√',
      'log',
      'ln',
      'asin',
      'acos',
      'atan',
      'cbrt',
      'exp',
      'abs',
      '1/x',
      'π',
      'e',
    ].contains(key)) {
      return const Color(0xFF25273A);
    }
    return const Color(0xFF1D1F2D);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalkulator Ilmiah'),
        actions: [
          IconButton(
            tooltip: 'Salin hasil',
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: _result));

              if (!context.mounted) return;

              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Hasil disalin')));
            },
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 10),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1D2A),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _expression.isEmpty ? '0' : _expression,
                        style: const TextStyle(
                          color: Colors.white60,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      reverse: true,
                      child: Text(
                        _result,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    if (_error.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        _error,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          color: Color(0xFFFF8297),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final rowHeight = constraints.maxHeight / _buttons.length;
                    return Column(
                      children: _buttons.map((row) {
                        return SizedBox(
                          height: rowHeight,
                          child: Row(
                            children: row.map((key) {
                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.all(3),
                                  child: Material(
                                    color: _buttonColor(key),
                                    borderRadius: BorderRadius.circular(13),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(13),
                                      onTap: () => _press(key),
                                      child: Center(
                                        child: FittedBox(
                                          child: Text(
                                            key,
                                            style: TextStyle(
                                              fontSize: key.length > 3
                                                  ? 14
                                                  : 19,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
