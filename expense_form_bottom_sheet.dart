import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

import 'package:family_travel_app/core/ocr_stub.dart';
import 'package:family_travel_app/features/expense/controller/expense_notifier.dart';
import 'package:family_travel_app/features/expense/data/expense_category.dart';
import 'package:family_travel_app/features/expense/data/expense_repository.dart';

class ExpenseFormBottomSheet extends ConsumerStatefulWidget {
  final String planId;

  const ExpenseFormBottomSheet({super.key, required this.planId});

  @override
  ConsumerState<ExpenseFormBottomSheet> createState() => _ExpenseFormBottomSheetState();
}

class _ExpenseFormBottomSheetState extends ConsumerState<ExpenseFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  ExpenseCategory? _selectedCategory;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _currencyController = TextEditingController(text: 'JPY'); // Default currency
  final TextEditingController _noteController = TextEditingController();
  File? _receiptImage;
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _currencyController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _receiptImage = File(pickedFile.path);
      });
      _scanReceipt(_receiptImage!);
    }
  }

  Future<void> _scanReceipt(File imageFile) async {
    setState(() {
      _isLoading = true;
    });
    try {
      final ocrResult = await scanReceipt(imageFile);
      _amountController.text = ocrResult.amount.toString();
      _selectedCategory = ocrResult.category;
      _currencyController.text = ocrResult.currency;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt scanned!')), 
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to scan receipt: $e')), 
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final expenseNotifier = ref.read(expenseNotifierProvider(widget.planId).notifier);
      final draft = ExpenseDraft(
        id: const Uuid().v4(),
        planId: widget.planId,
        category: _selectedCategory!,
        amount: double.parse(_amountController.text),
        currency: _currencyController.text,
        note: _noteController.text.isEmpty ? null : _noteController.text,
        receiptFilePath: _receiptImage?.path,
      );

      try {
        await expenseNotifier.addExpense(draft, receiptFile: _receiptImage);
        if (mounted) {
          Navigator.of(context).pop();
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to add expense: $e')), 
          );
        }
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16.0,
        right: 16.0,
        top: 16.0,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Add New Expense',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<ExpenseCategory>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: ExpenseCategory.values.map((category) {
                  return DropdownMenuItem(
                    value: category,
                    child: Text(category.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value;
                  });
                },
                validator: (value) => value == null ? 'Please select a category' : null,
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^[0-9]+.?[0-9]*$'))],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an amount';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _currencyController,
                decoration: const InputDecoration(
                  labelText: 'Currency (e.g., JPY, USD)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a currency';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Note (Optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16.0),
              _receiptImage == null
                  ? ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Add Receipt Image'),
                    )
                  : Image.file(
                      _receiptImage!,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
              const SizedBox(height: 16.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: _submitForm,
                      child: const Text('Save Expense'),
                    ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
    );
  }
}


