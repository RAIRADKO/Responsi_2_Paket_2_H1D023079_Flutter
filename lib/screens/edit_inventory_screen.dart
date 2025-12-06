import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:responsi_mobile/constants.dart';
import 'package:responsi_mobile/inventory_service.dart';
import 'package:responsi_mobile/models/inventory_model.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class EditInventoryScreen extends StatefulWidget {
  final Inventory inventory;

  const EditInventoryScreen({super.key, required this.inventory});

  @override
  State<EditInventoryScreen> createState() => _EditInventoryScreenState();
}

class _EditInventoryScreenState extends State<EditInventoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _quantityController;
  late DateTime _entryDate;
  late DateTime _expiryDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.inventory.name);
    _priceController = TextEditingController(text: widget.inventory.price.toString());
    _quantityController = TextEditingController(text: widget.inventory.quantity.toString());
    _entryDate = DateTime.parse(widget.inventory.entryDate);
    _expiryDate = DateTime.parse(widget.inventory.expiryDate);
  }

  Future<void> _selectDate(BuildContext context, bool isExpiry) async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: isExpiry ? _expiryDate : _entryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: primaryColor,
              onPrimary: Colors.white,
              onSurface: Colors.grey[700]!,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: primaryColor),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      setState(() {
        if (isExpiry) {
          _expiryDate = selectedDate;
        } else {
          _entryDate = selectedDate;
        }
      });
    }
  }

  Future<void> _updateInventory() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        final updatedInventory = Inventory(
          id: widget.inventory.id,
          name: _nameController.text.trim(),
          price: int.parse(_priceController.text),
          quantity: int.parse(_quantityController.text),
          entryDate: DateFormat('yyyy-MM-dd').format(_entryDate),
          expiryDate: DateFormat('yyyy-MM-dd').format(_expiryDate),
        );

        await InventoryService.updateInventory(updatedInventory);
        Fluttertoast.showToast(
          msg: 'Data berhasil diupdate!',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
        Navigator.pop(context, true);
      } catch (e) {
        Fluttertoast.showToast(
          msg: 'Gagal mengupdate: ${e.toString()}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white,
        );
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Inventaris Abimart'),
        backgroundColor: primaryColor,
      ),
      body: _isLoading
          ? const Center(
              child: SpinKitFadingCircle(
                color: primaryColor,
                size: 50.0,
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Nama Bahan',
                        prefixIcon: const Icon(Icons.food_bank),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.7)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Nama wajib diisi';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga (Rp)',
                        prefixIcon: const Icon(Icons.attach_money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.7)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Harga wajib diisi';
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Harga harus angka positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Jumlah',
                        prefixIcon: const Icon(Icons.numbers),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: primaryColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: primaryColor.withOpacity(0.7)),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return 'Jumlah wajib diisi';
                        if (int.tryParse(value) == null || int.parse(value) <= 0) {
                          return 'Jumlah harus angka positif';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectDate(context, false),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tanggal Masuk',
                            prefixIcon: const Icon(Icons.calendar_today),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor.withOpacity(0.7)),
                            ),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('dd MMM yyyy').format(_entryDate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    GestureDetector(
                      onTap: () => _selectDate(context, true),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Tanggal Kedaluwarsa',
                            prefixIcon: const Icon(Icons.hourglass_empty),
                            suffixIcon: const Icon(Icons.arrow_drop_down),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: primaryColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: primaryColor.withOpacity(0.7)),
                            ),
                          ),
                          controller: TextEditingController(
                            text: DateFormat('dd MMM yyyy').format(_expiryDate),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _updateInventory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: const Text(
                        'UPDATE',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}