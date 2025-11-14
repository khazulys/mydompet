import 'package:intl/intl.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final DateTime date;
  final String? category;

  Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
    this.category,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'date': date.toIso8601String(),
        'category': category,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values.firstWhere((e) => e.name == json['type']),
        date: DateTime.parse(json['date'] as String),
        category: json['category'] as String?,
      );

  String get formattedAmount {
    final formatter = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
  }

  String get formattedDate {
    return DateFormat('dd MMM yyyy', 'id_ID').format(date);
  }
}
