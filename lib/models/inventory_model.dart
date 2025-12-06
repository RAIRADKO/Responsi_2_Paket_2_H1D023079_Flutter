class Inventory {
  final int id;
  final String name;
  final int price;
  final int quantity;
  final String entryDate;
  final String expiryDate;

  Inventory({
    required this.id,
    required this.name,
    required this.price,
    required this.quantity,
    required this.entryDate,
    required this.expiryDate,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    return Inventory(
      id: json['id'],
      name: json['name'],
      price: json['price'],
      quantity: json['quantity'],
      entryDate: json['entry_date'],
      expiryDate: json['expiry_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'price': price,
      'quantity': quantity,
      'entry_date': entryDate,
      'expiry_date': expiryDate,
    };
  }

  String get formattedEntryDate {
    return _formatDate(entryDate);
  }

  String get formattedExpiryDate {
    return _formatDate(expiryDate);
  }

  String _formatDate(String dateStr) {
    final date = DateTime.parse(dateStr);
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}