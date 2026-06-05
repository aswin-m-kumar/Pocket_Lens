class CurrencyFormatter {
  static String format(double amount) {
    final bool isNegative = amount < 0;
    final double absAmount = amount.abs();

    final List<String> parts = absAmount.toStringAsFixed(2).split('.');
    final String intPart = parts[0];
    final String decPart = parts[1];

    // standard formatting with commas for thousands
    final RegExp reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final String formattedInt = intPart.replaceAllMapped(reg, (Match m) => '${m[1]},');

    final String formattedAmount = decPart == '00' ? formattedInt : '$formattedInt.$decPart';
    return '${isNegative ? '−' : ''}₹$formattedAmount';
  }
}
