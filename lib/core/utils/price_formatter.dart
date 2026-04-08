class PriceFormatter {
  PriceFormatter._();

  static String format(double price) {
    final intPrice = price.toInt();
    return intPrice.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  static String formatJPY(double price) => '¥${format(price)}';

  static String formatVND(double price) => 'VND ${format(price)}';
}
