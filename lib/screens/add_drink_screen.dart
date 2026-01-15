import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/flavor.dart';
import '../models/log.dart';
import '../utils/currency_helper.dart';
import '../utils/image_helper.dart';

/// Screen for adding a new drink entry
class AddDrinkScreen extends StatefulWidget {
  const AddDrinkScreen({super.key});

  @override
  State<AddDrinkScreen> createState() => _AddDrinkScreenState();
}

class _AddDrinkScreenState extends State<AddDrinkScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  final _formKey = GlobalKey<FormState>();
  final _priceController = TextEditingController();

  List<Flavor> _flavors = [];
  Flavor? _selectedFlavor;
  DateTime _selectedDateTime = DateTime.now();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadFlavors();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  /// Loads all active flavors from the database
  Future<void> _loadFlavors() async {
    final flavors = await _db.getActiveFlavors();
    setState(() {
      _flavors = flavors;
      _isLoading = false;
      if (_flavors.isNotEmpty) {
        _selectedFlavor = _flavors.first;
      }
    });
  }

  /// Saves the drink entry to the database
  Future<void> _saveDrink() async {
    if (!_formKey.currentState!.validate() || _selectedFlavor == null) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final user = await _db.getDefaultUser();
      if (user == null) {
        throw Exception('No user found');
      }

      final log = Log(
        userId: user.id!,
        flavorId: _selectedFlavor!.id!,
        pricePaid: double.parse(_priceController.text),
        timestamp: DateFormat('yyyy-MM-dd HH:mm:ss').format(_selectedDateTime),
        notes: null, // Notes removed from UI
      );

      await _db.createLog(log);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Drink logged successfully!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      setState(() => _isSaving = false);
    }
  }

  /// Shows date picker dialog
  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (date != null) {
      setState(() {
        _selectedDateTime = DateTime(
          date.year,
          date.month,
          date.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  /// Shows time picker dialog
  Future<void> _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );

    if (time != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Drink'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flavors.isEmpty
              ? _buildNoFlavorsView()
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildFlavorSelector(),
                        const SizedBox(height: 24),
                        _buildPriceField(),
                        const SizedBox(height: 24),
                        _buildDateTimeSelector(),
                        const SizedBox(height: 32),
                        _buildSaveButton(),
                        const SizedBox(height: 24), // Extra padding at bottom
                      ],
                    ),
                  ),
                ),
    );
  }

  /// Builds the view shown when no flavors are available
  Widget _buildNoFlavorsView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_drink_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No flavors available',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Please add some flavors first',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the flavor selector dropdown
  Widget _buildFlavorSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.local_drink,
                  color: Colors.green,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Flavor',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<Flavor>(
            value: _selectedFlavor,
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF0F0F0F),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF00FF00),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            items: _flavors.map((flavor) {
              return DropdownMenuItem(
                value: flavor,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ImageHelper.buildFlavorImage(
                      flavor.imagePath,
                      32,
                      32,
                      isActive: true,
                      fallbackColor: Colors.green,
                    ),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        flavor.name,
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() => _selectedFlavor = value);
            },
            validator: (value) {
              if (value == null) {
                return 'Please select a flavor';
              }
              return null;
            },
          ),
          if (_selectedFlavor != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withValues(alpha: 0.15),
                    Colors.blue.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.withValues(alpha: 0.2),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.water_drop, size: 16, color: Colors.blue[300]),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedFlavor!.ml}ml',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[300],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.bolt, size: 16, color: Colors.yellow[300]),
                  const SizedBox(width: 8),
                  Text(
                    '${_selectedFlavor!.caffeineMg}mg caffeine',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[300],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Builds the price input field
  Widget _buildPriceField() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: Colors.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Price',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _priceController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
                border: const OutlineInputBorder(),
                prefixIcon: Align(
                  alignment: Alignment.centerLeft,
                  widthFactor: 1.0,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Text(
                      CurrencyHelper.getCachedSymbol(),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              hintText: '0.00',
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a price';
                }
                final price = double.tryParse(value);
                if (price == null || price < 0) {
                  return 'Please enter a valid price';
                }
              return null;
            },
          ),
        ],
      ),
    );
  }

  /// Builds the date and time selector
  Widget _buildDateTimeSelector() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calendar_today,
                  color: Colors.purple,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'Date & Time',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide.none,
                      ),
                      icon: const Icon(Icons.calendar_today, size: 20),
                      label: Text(
                        DateFormat('MMM dd, yyyy').format(_selectedDateTime),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F0F0F),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1,
                      ),
                    ),
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide.none,
                      ),
                      icon: const Icon(Icons.access_time, size: 20),
                      label: Text(
                        DateFormat('HH:mm').format(_selectedDateTime),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                ),
              ],
          ),
        ],
      ),
    );
  }

  /// Builds the notes input field
  /// Builds the save button
  Widget _buildSaveButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00FF00), Color(0xFF00CC00)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00FF00).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveDrink,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 18),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                ),
              )
            : const Text(
                'Save Drink',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
      ),
    );
  }
}

