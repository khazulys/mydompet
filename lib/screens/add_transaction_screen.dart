import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:forui/forui.dart';
import '../models/transaction.dart';
import '../services/storage_service.dart';

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  final _storage = StorageService();
  
  TransactionType _selectedType = TransactionType.income;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _saveTransaction() async {
    if (_formKey.currentState!.validate()) {
      final transaction = Transaction(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        amount: double.parse(_amountController.text),
        type: _selectedType,
        date: _selectedDate,
        category: _categoryController.text.isEmpty ? null : _categoryController.text,
      );

      await _storage.addTransaction(transaction);
      
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FScaffold(
      child: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTypeSelector(context),
                    const SizedBox(height: 24),
                    _buildTextField(
                      context,
                      label: 'Judul',
                      controller: _titleController,
                      validator: (value) =>
                          value?.isEmpty ?? true ? 'Judul tidak boleh kosong' : null,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      label: 'Jumlah',
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Jumlah tidak boleh kosong';
                        if (double.tryParse(value!) == null) return 'Jumlah tidak valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      context,
                      label: 'Kategori (Opsional)',
                      controller: _categoryController,
                    ),
                    const SizedBox(height: 16),
                    _buildDatePicker(context),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: FButton(
                        onPress: _saveTransaction,
                        child: const Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: Text('Simpan Transaksi'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
      child: Row(
        children: [
          FButton(
            onPress: () => Navigator.pop(context),
            child: const Icon(FIcons.chevronLeft, size: 20),
          ),
          const SizedBox(width: 16),
          Text(
            'Tambah Transaksi',
            style: context.theme.typography.xl2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeSelector(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tipe Transaksi',
          style: context.theme.typography.sm.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildTypeButton(
                context,
                'Pemasukan',
                FIcons.trendingUp,
                TransactionType.income,
                Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildTypeButton(
                context,
                'Pengeluaran',
                FIcons.trendingDown,
                TransactionType.expense,
                Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTypeButton(BuildContext context, String label, IconData icon, TransactionType type, Color color) {
    final isSelected = _selectedType == type;
    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.grey.withValues(alpha: 0.3),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? color : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required String label,
    required TextEditingController controller,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.theme.typography.sm.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          validator: validator,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tanggal',
          style: context.theme.typography.sm.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                const Icon(FIcons.calendar, size: 20),
                const SizedBox(width: 12),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: context.theme.typography.base,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
