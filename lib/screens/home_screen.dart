import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';
import 'add_transaction_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final StorageService _storage = StorageService();
  List<Transaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final transactions = await _storage.loadTransactions();
    setState(() {
      _transactions = transactions..sort((a, b) => b.date.compareTo(a.date));
      _isLoading = false;
    });
  }

  double get _totalIncome => _transactions
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get _totalExpense => _transactions
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get _balance => _totalIncome - _totalExpense;

  Future<void> _deleteTransaction(String id) async {
    await _storage.deleteTransaction(id);
    await _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Colors.grey.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Pencatat Keuangan',
                style: context.theme.typography.xl2.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              FButton(
                onPress: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                  await _loadTransactions();
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FIcons.plus, size: 16),
                    SizedBox(width: 4),
                    Text('Tambah'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildBalanceCard(context),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildSummaryCard(context, 'Pemasukan', _totalIncome, FIcons.trendingUp, true)),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard(context, 'Pengeluaran', _totalExpense, FIcons.trendingDown, false)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCard(BuildContext context) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Saldo Total',
              style: context.theme.typography.sm.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${_balance.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
              style: context.theme.typography.xl4.copyWith(
                fontWeight: FontWeight.bold,
                color: _balance >= 0 ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, String label, double amount, IconData icon, bool isIncome) {
    return FCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: context.theme.typography.xs.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Rp ${amount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d)(?=(\d{3})+(?!\d))'), (match) => '${match[1]}.')}',
              style: context.theme.typography.lg.copyWith(
                fontWeight: FontWeight.w600,
                color: isIncome ? Colors.green : Colors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    if (_transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              FIcons.fileText,
              size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Belum ada transaksi',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _transactions.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final transaction = _transactions[index];
        return FCard(
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: transaction.type == TransactionType.income
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.red.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                transaction.type == TransactionType.income ? FIcons.arrowDown : FIcons.arrowUp,
                color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                size: 20,
              ),
            ),
            title: Text(
              transaction.title,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${transaction.formattedDate}${transaction.category != null ? ' • ${transaction.category}' : ''}',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  transaction.formattedAmount,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: transaction.type == TransactionType.income ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
            onLongPress: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Hapus Transaksi'),
                  content: const Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                    TextButton(
                      onPressed: () {
                        _deleteTransaction(transaction.id);
                        Navigator.pop(context);
                      },
                      child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}
