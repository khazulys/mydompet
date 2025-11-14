import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/transaction.dart';

class StorageService {
  static const String _transactionsKey = 'transactions';

  Future<List<Transaction>> loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? transactionsJson = prefs.getString(_transactionsKey);
    
    if (transactionsJson == null) return [];
    
    final List<dynamic> decoded = json.decode(transactionsJson);
    return decoded.map((json) => Transaction.fromJson(json)).toList();
  }

  Future<void> saveTransactions(List<Transaction> transactions) async {
    final prefs = await SharedPreferences.getInstance();
    final String encoded = json.encode(
      transactions.map((t) => t.toJson()).toList(),
    );
    await prefs.setString(_transactionsKey, encoded);
  }

  Future<void> addTransaction(Transaction transaction) async {
    final transactions = await loadTransactions();
    transactions.add(transaction);
    await saveTransactions(transactions);
  }

  Future<void> deleteTransaction(String id) async {
    final transactions = await loadTransactions();
    transactions.removeWhere((t) => t.id == id);
    await saveTransactions(transactions);
  }
}
