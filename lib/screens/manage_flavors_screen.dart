import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../database/database_helper.dart';
import '../models/flavor.dart';
import '../utils/image_helper.dart';

/// Screen for managing Red Bull energy drink flavors
class ManageFlavorsScreen extends StatefulWidget {
  const ManageFlavorsScreen({super.key});

  @override
  State<ManageFlavorsScreen> createState() => _ManageFlavorsScreenState();
}

class _ManageFlavorsScreenState extends State<ManageFlavorsScreen> {
  final DatabaseHelper _db = DatabaseHelper.instance;
  List<Flavor> _flavors = [];
  bool _isLoading = true;
  bool _showInactive = false;

  @override
  void initState() {
    super.initState();
    _loadFlavors();
  }

  /// Loads flavors from the database
  Future<void> _loadFlavors() async {
    setState(() => _isLoading = true);
    final flavors = _showInactive
        ? await _db.getAllFlavors()
        : await _db.getActiveFlavors();
    setState(() {
      _flavors = flavors;
      _isLoading = false;
    });
  }

  /// Shows dialog to add a new flavor
  Future<void> _showAddFlavorDialog() async {
    final nameController = TextEditingController();
    final mlController = TextEditingController(text: '250');
    final caffeineController = TextEditingController(text: '80');
    final formKey = GlobalKey<FormState>();
    String? selectedImagePath;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Flavor'),
        content: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Flavor Name',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: mlController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Volume (ml)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter volume';
                    }
                    final ml = int.tryParse(value);
                    if (ml == null || ml <= 0) {
                      return 'Please enter a valid volume';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: caffeineController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Caffeine (mg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter caffeine amount';
                    }
                    final caffeine = int.tryParse(value);
                    if (caffeine == null || caffeine < 0) {
                      return 'Please enter a valid amount';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                final flavor = Flavor(
                  name: nameController.text,
                  ml: int.parse(mlController.text),
                  caffeineMg: int.parse(caffeineController.text),
                  imagePath: selectedImagePath,
                );
                await _db.createFlavor(flavor);
                if (context.mounted) {
                  Navigator.pop(context);
                  _loadFlavors();
                }
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  /// Shows dialog to edit an existing flavor
  Future<void> _showEditFlavorDialog(Flavor flavor) async {
    final nameController = TextEditingController(text: flavor.name);
    final mlController = TextEditingController(text: flavor.ml.toString());
    final caffeineController =
        TextEditingController(text: flavor.caffeineMg.toString());
    final formKey = GlobalKey<FormState>();
    String? selectedImagePath = flavor.imagePath;

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Edit Flavor'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Flavor Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: mlController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Volume (ml)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter volume';
                      }
                      final ml = int.tryParse(value);
                      if (ml == null || ml <= 0) {
                        return 'Please enter a valid volume';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: caffeineController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Caffeine (mg)',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter caffeine amount';
                      }
                      final caffeine = int.tryParse(value);
                      if (caffeine == null || caffeine < 0) {
                        return 'Please enter a valid amount';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Image picker section
                  Text(
                    'Flavor Image (Optional)',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 8),
                  if (selectedImagePath != null) ...[
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: ImageHelper.buildFlavorImage(selectedImagePath!, 200, 100),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.camera,
                              imageQuality: 85,
                            );
                            if (image != null) {
                              final appDir = await getApplicationDocumentsDirectory();
                              final flavorsDir = Directory(path.join(appDir.path, 'user_flavors'));
                              if (!await flavorsDir.exists()) {
                                await flavorsDir.create(recursive: true);
                              }
                              final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
                              final savedImage = File(path.join(flavorsDir.path, fileName));
                              await File(image.path).copy(savedImage.path);
                              setState(() {
                                selectedImagePath = savedImage.path;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image captured!')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('Take Photo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            final XFile? image = await picker.pickImage(
                              source: ImageSource.gallery,
                              imageQuality: 85,
                            );
                            if (image != null) {
                              final appDir = await getApplicationDocumentsDirectory();
                              final flavorsDir = Directory(path.join(appDir.path, 'user_flavors'));
                              if (!await flavorsDir.exists()) {
                                await flavorsDir.create(recursive: true);
                              }
                              final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
                              final savedImage = File(path.join(flavorsDir.path, fileName));
                              await File(image.path).copy(savedImage.path);
                              setState(() {
                                selectedImagePath = savedImage.path;
                              });
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Image selected!')),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.photo_library),
                          label: const Text('From Gallery'),
                        ),
                      ),
                    ],
                  ),
                  if (selectedImagePath != null) ...[
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: () {
                        setState(() {
                          selectedImagePath = null;
                        });
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Remove Image', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final updatedFlavor = flavor.copyWith(
                    name: nameController.text,
                    ml: int.parse(mlController.text),
                    caffeineMg: int.parse(caffeineController.text),
                    imagePath: selectedImagePath,
                  );
                  await _db.updateFlavor(updatedFlavor);
                  if (context.mounted) {
                    Navigator.pop(context);
                    _loadFlavors();
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  /// Toggles a flavor's active status
  Future<void> _toggleFlavorActive(Flavor flavor) async {
    final updatedFlavor = flavor.copyWith(isActive: !flavor.isActive);
    await _db.updateFlavor(updatedFlavor);
    _loadFlavors();
  }

  /// Deletes a flavor with confirmation
  Future<void> _deleteFlavor(Flavor flavor) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Flavor'),
        content: Text(
          'Are you sure you want to delete "${flavor.name}"? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _db.deleteFlavor(flavor.id!);
      _loadFlavors();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Flavors'),
        actions: [
          IconButton(
            icon: Icon(_showInactive ? Icons.visibility : Icons.visibility_off),
            onPressed: () {
              setState(() => _showInactive = !_showInactive);
              _loadFlavors();
            },
            tooltip: _showInactive ? 'Hide Inactive' : 'Show Inactive',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _flavors.isEmpty
              ? _buildEmptyView()
              : RefreshIndicator(
                  onRefresh: _loadFlavors,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _flavors.length,
                    itemBuilder: (context, index) {
                      return _buildFlavorCard(_flavors[index]);
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddFlavorDialog,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Flavor',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        backgroundColor: const Color(0xFF00FF00),
        foregroundColor: Colors.black,
      ),
    );
  }

  /// Builds the view shown when no flavors exist
  Widget _buildEmptyView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.local_drink_outlined, size: 64, color: Colors.grey[600]),
            const SizedBox(height: 16),
            Text(
              'No flavors yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add your first Red Bull flavor',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a card for a single flavor
  Widget _buildFlavorCard(Flavor flavor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: flavor.isActive
              ? Colors.green.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Flavor image
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImageHelper.buildFlavorImage(
                flavor.imagePath,
                64,
                64,
                isActive: flavor.isActive,
              ),
            ),
            const SizedBox(width: 16),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    flavor.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      decoration: flavor.isActive ? null : TextDecoration.lineThrough,
                      color: flavor.isActive ? Colors.white : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.water_drop,
                        size: 14,
                        color: Colors.blue[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${flavor.ml}ml',
                        style: TextStyle(
                          color: flavor.isActive
                              ? Colors.grey[400]
                              : Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.bolt,
                        size: 14,
                        color: Colors.yellow[300],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${flavor.caffeineMg}mg caffeine',
                        style: TextStyle(
                          color: flavor.isActive
                              ? Colors.grey[400]
                              : Colors.grey[700],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Menu button
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditFlavorDialog(flavor);
                    break;
                  case 'toggle':
                    _toggleFlavorActive(flavor);
                    break;
                  case 'delete':
                    _deleteFlavor(flavor);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'toggle',
                  child: Row(
                    children: [
                      Icon(
                        flavor.isActive ? Icons.visibility_off : Icons.visibility,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(flavor.isActive ? 'Deactivate' : 'Activate'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 20, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

