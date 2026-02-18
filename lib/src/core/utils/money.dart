import 'package:intl/intl.dart';

String formatMoney(num value, {String currency = 'THB'}) {
  final f = NumberFormat.currency(
    name: currency,
    symbol: '',
    decimalDigits: value % 1 == 0 ? 0 : 2,
  );

  final amount = f.format(value).trim();
  return '$amount $currency';
}
