import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class CurrencyInfo {
  final String code;
  final String name;
  final String symbol;

  const CurrencyInfo(this.code, this.name, this.symbol);
}

const List<CurrencyInfo> currencies = [
  CurrencyInfo('IDR', 'Rupiah Indonesia', 'Rp'),
  CurrencyInfo('USD', 'Dolar Amerika Serikat', r'$'),
  CurrencyInfo('EUR', 'Euro', '€'),
  CurrencyInfo('GBP', 'Pound Sterling', '£'),
  CurrencyInfo('JPY', 'Yen Jepang', '¥'),
  CurrencyInfo('CNY', 'Yuan Tiongkok', 'CN¥'),
  CurrencyInfo('SGD', 'Dolar Singapura', r'S$'),
  CurrencyInfo('MYR', 'Ringgit Malaysia', 'RM'),
  CurrencyInfo('THB', 'Baht Thailand', '฿'),
  CurrencyInfo('AUD', 'Dolar Australia', r'A$'),
  CurrencyInfo('CAD', 'Dolar Kanada', r'C$'),
  CurrencyInfo('CHF', 'Franc Swiss', 'CHF'),
  CurrencyInfo('HKD', 'Dolar Hong Kong', r'HK$'),
  CurrencyInfo('NZD', 'Dolar Selandia Baru', r'NZ$'),
  CurrencyInfo('KRW', 'Won Korea Selatan', '₩'),
  CurrencyInfo('INR', 'Rupee India', '₹'),
  CurrencyInfo('PHP', 'Peso Filipina', '₱'),
  CurrencyInfo('VND', 'Dong Vietnam', '₫'),
  CurrencyInfo('AED', 'Dirham UEA', 'AED'),
  CurrencyInfo('SAR', 'Riyal Arab Saudi', 'SAR'),
  CurrencyInfo('BRL', 'Real Brasil', 'R\$'),
  CurrencyInfo('MXN', 'Peso Meksiko', r'MX$'),
  CurrencyInfo('ZAR', 'Rand Afrika Selatan', 'R'),
  CurrencyInfo('SEK', 'Krona Swedia', 'kr'),
  CurrencyInfo('NOK', 'Krone Norwegia', 'kr'),
  CurrencyInfo('DKK', 'Krone Denmark', 'kr'),
  CurrencyInfo('PLN', 'Zloty Polandia', 'zł'),
  CurrencyInfo('CZK', 'Koruna Ceko', 'Kč'),
  CurrencyInfo('HUF', 'Forint Hungaria', 'Ft'),
  CurrencyInfo('TRY', 'Lira Turki', '₺'),
  CurrencyInfo('ILS', 'Shekel Israel', '₪'),
  CurrencyInfo('ISK', 'Krona Islandia', 'kr'),
  CurrencyInfo('RON', 'Leu Rumania', 'lei'),
  CurrencyInfo('BGN', 'Lev Bulgaria', 'лв'),
  CurrencyInfo('HRK', 'Kuna Kroasia (historis)', 'kn'),
];

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _amountController = TextEditingController(
    text: '100000',
  );

  String _from = 'IDR';
  String _to = 'USD';

  double? _rate;
  double? _converted;
  String _rateDate = '';
  String _error = '';
  bool _loading = false;

  int _decimalDigits(String code) {
    const zeroDecimal = {'IDR', 'JPY', 'KRW', 'VND', 'CLP', 'ISK'};
    return zeroDecimal.contains(code) ? 0 : 2;
  }

  String _formatMoney(double value, String code) {
    final digits = _decimalDigits(code);
    final locale = code == 'IDR' ? 'id_ID' : 'en_US';

    return NumberFormat.currency(
      locale: locale,
      name: code,
      decimalDigits: digits,
    ).format(value);
  }

  Future<void> _convert() async {
    FocusScope.of(context).unfocus();

    final amountText = _amountController.text
        .trim()
        .replaceAll(' ', '')
        .replaceAll(',', '.');

    final amount = double.tryParse(amountText);

    if (amount == null || !amount.isFinite || amount < 0) {
      setState(() {
        _error = 'Masukkan nominal yang valid dan tidak negatif.';
        _converted = null;
        _rate = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = '';
      _converted = null;
      _rate = null;
      _rateDate = '';
    });

    try {
      double rate;
      String date;

      if (_from == _to) {
        rate = 1;
        date = 'Kurs identik';
      } else {
        final uri = Uri.https('api.frankfurter.dev', '/v1/latest', {
          'base': _from,
          'symbols': _to,
        });

        final response = await http
            .get(uri)
            .timeout(const Duration(seconds: 15));

        if (response.statusCode != 200) {
          throw Exception(
            'Layanan kurs tidak tersedia '
            '(HTTP ${response.statusCode}).',
          );
        }

        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final rates = data['rates'] as Map<String, dynamic>?;
        final rawRate = rates?[_to];

        if (rawRate is! num || rawRate <= 0) {
          throw Exception('Kurs $_from ke $_to tidak ditemukan oleh penyedia.');
        }

        rate = rawRate.toDouble();
        date = data['date']?.toString() ?? 'Tanggal tidak tersedia';
      }

      if (!mounted) return;

      setState(() {
        _rate = rate;
        _converted = amount * rate;
        _rateDate = date;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error =
            'Gagal mengambil kurs. Periksa internet dan '
            'dukungan mata uang pada penyedia kurs. Detail: $e';
      });
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  void _swap() {
    setState(() {
      final oldFrom = _from;
      _from = _to;
      _to = oldFrom;
      _rate = null;
      _converted = null;
      _rateDate = '';
      _error = '';
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Konversi Mata Uang'),
        actions: [
          IconButton(
            tooltip: 'Salin hasil',
            onPressed: _converted == null
                ? null
                : () async {
                    await Clipboard.setData(
                      ClipboardData(text: _formatMoney(_converted!, _to)),
                    );

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Hasil konversi disalin')),
                    );
                  },
            icon: const Icon(Icons.copy_rounded),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF176C59), Color(0xFF223D57)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.currency_exchange_rounded, size: 35),
                  SizedBox(height: 16),
                  Text(
                    'Konversi mata uang',
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Pilih mata uang dan ambil kurs referensi online.',
                    style: TextStyle(color: Colors.white70, height: 1.5),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Nominal',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
              ],
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.payments_outlined),
                hintText: 'Masukkan nominal',
                filled: true,
                fillColor: const Color(0xFF1B1D2A),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _convert(),
            ),
            const SizedBox(height: 20),
            _currencyDropdown(
              label: 'Dari mata uang',
              value: _from,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _from = value;
                  _rate = null;
                  _converted = null;
                  _error = '';
                });
              },
            ),
            Align(
              alignment: Alignment.center,
              child: IconButton.filled(
                onPressed: _swap,
                tooltip: 'Tukar mata uang',
                icon: const Icon(Icons.swap_vert_rounded),
              ),
            ),
            _currencyDropdown(
              label: 'Ke mata uang',
              value: _to,
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _to = value;
                  _rate = null;
                  _converted = null;
                  _error = '';
                });
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: _loading ? null : _convert,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.currency_exchange),
                label: Text(
                  _loading ? 'Mengambil kurs...' : 'Konversi Sekarang',
                ),
              ),
            ),
            if (_error.isNotEmpty) ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFF512B36),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(_error, style: const TextStyle(height: 1.5)),
              ),
            ],
            if (_converted != null && _rate != null) ...[
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B1D2A),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF28C99A).withValues(alpha: 0.5),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Hasil Konversi',
                      style: TextStyle(color: Colors.white70),
                    ),
                    const SizedBox(height: 12),
                    SelectableText(
                      _formatMoney(_converted!, _to),
                      style: const TextStyle(
                        fontSize: 29,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF28C99A),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(color: Colors.white12),
                    Text(
                      '1 $_from = ${_rate!.toStringAsPrecision(8)} $_to',
                      style: const TextStyle(height: 1.6),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Tanggal kurs: $_rateDate',
                      style: const TextStyle(
                        color: Colors.white60,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Kurs referensi, bukan jaminan kurs transaksi. '
                      'Hasil dapat berbeda dari bank atau penyedia '
                      'layanan pembayaran.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white60,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _currencyDropdown({
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: value,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1B1D2A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          items: currencies.map((currency) {
            return DropdownMenuItem<String>(
              value: currency.code,
              child: Text(
                '${currency.code} — ${currency.name}',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
