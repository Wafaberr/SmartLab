import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import 'package:smartlaboratory/features/products/data/models/category_model.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // ============================================================
  // CONTROLLERS
  // ============================================================

  final TextEditingController nameController =
      TextEditingController();

  final TextEditingController referenceController =
      TextEditingController();

  final TextEditingController barcodeController =
      TextEditingController();

  final TextEditingController minimumStockController =
      TextEditingController();

  final TextEditingController maximumStockController =
      TextEditingController();

  final TextEditingController purchasePriceController =
      TextEditingController();

  final TextEditingController expirationDateController =
      TextEditingController();

  final TextEditingController temperatureController =
      TextEditingController();

  final TextEditingController descriptionController =
      TextEditingController();

  // ============================================================
  // IMAGE
  // ============================================================

  final ImagePicker _picker = ImagePicker();

  File? selectedImage;

  // ============================================================
  // CATEGORY
  // ============================================================

  CategoryModel? selectedCategory;

  // ============================================================
  // SUPPLIER
  // ============================================================

  int? selectedSupplier;

  // ============================================================
  // UNIT
  // ============================================================

  String selectedUnit = 'piece';

  // ============================================================
  // TEMPORARY CATEGORIES
  // ============================================================
  // Plus tard, on les récupérera depuis Django.
  // ============================================================

  final List<CategoryModel> categories = [
    CategoryModel(
      id: 1,
      name: 'Réactifs',
      description: '',
    ),
    CategoryModel(
      id: 2,
      name: 'Consommables',
      description: '',
    ),
    CategoryModel(
      id: 3,
      name: 'Tubes de prélèvement',
      description: '',
    ),
  ];

  @override
  void dispose() {
    nameController.dispose();
    referenceController.dispose();
    barcodeController.dispose();
    minimumStockController.dispose();
    maximumStockController.dispose();
    purchasePriceController.dispose();
    expirationDateController.dispose();
    temperatureController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // ============================================================
  // PICK IMAGE
  // ============================================================

  Future<void> _pickImage() async {
    final ImageSource? source =
        await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(
                  Icons.photo_library_outlined,
                ),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.pop(
                    bottomSheetContext,
                    ImageSource.gallery,
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.camera_alt_outlined,
                ),
                title: const Text('Caméra'),
                onTap: () {
                  Navigator.pop(
                    bottomSheetContext,
                    ImageSource.camera,
                  );
                },
              ),
            ],
          ),
        );
      },
    );

    if (source == null) {
      return;
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1200,
    );

    if (pickedFile == null) {
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      selectedImage = File(pickedFile.path);
    });
  }

  // ============================================================
  // SAVE PRODUCT
  // ============================================================

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Veuillez sélectionner une catégorie.',
          ),
        ),
      );
      return;
    }

    final double? minimumStock = double.tryParse(
      minimumStockController.text.replaceAll(',', '.'),
    );

    final double? maximumStock = double.tryParse(
      maximumStockController.text.replaceAll(',', '.'),
    );

    final double? purchasePrice = double.tryParse(
      purchasePriceController.text.replaceAll(',', '.'),
    );

    if (minimumStock == null ||
        maximumStock == null ||
        purchasePrice == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Vérifiez les valeurs numériques.',
          ),
        ),
      );
      return;
    }

    final ProductModel product = ProductModel(
      // Le backend donnera le vrai ID après création.
      id: 0,

      name: nameController.text.trim(),

      reference: referenceController.text.trim(),

      barcode: barcodeController.text.trim().isEmpty
          ? null
          : barcodeController.text.trim(),

      category: selectedCategory!,

      supplier: selectedSupplier,

      unit: selectedUnit,

      // Un nouveau produit commence sans stock.
      stockQuantity: 0,

      minimumStock: minimumStock,

      maximumStock: maximumStock,

      purchasePrice: purchasePrice,

      expirationDate:
          expirationDateController.text.trim().isEmpty
              ? null
              : expirationDateController.text.trim(),

      storageTemperature:
          temperatureController.text.trim(),

      // IMPORTANT :
      // image = URL venant de Django.
      // Le fichier local est envoyé séparément.
      image: null,

      description:
          descriptionController.text.trim(),

      isLowStock: false,
    );

    // Le File est envoyé séparément au Cubit.
    context.read<ProductCubit>().createProduct(
          product,
          imageFile: selectedImage,
        );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Ajouter un produit',
        ),
        centerTitle: true,
      ),

      body: BlocListener<ProductCubit, ProductState>(
        listener: (context, state) {
          // ============================
          // SUCCESS
          // ============================

          if (state is ProductLoaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Produit ajouté avec succès.',
                ),
              ),
            );

            Navigator.pop(
              context,
              true,
            );
          }

          // ============================
          // ERROR
          // ============================

          if (state is ProductError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                ),
              ),
            );
          }
        },

        child: BlocBuilder<ProductCubit, ProductState>(
          builder: (context, state) {
            final bool isLoading =
                state is ProductLoading;

            return Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  // ==================================================
                  // IMAGE
                  // ==================================================

                  _buildImagePicker(),

                  const SizedBox(height: 25),

                  // ==================================================
                  // NAME
                  // ==================================================

                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du produit',
                      hintText: 'Ex : Réactif CRP',
                      prefixIcon: Icon(
                        Icons.science_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'Le nom est obligatoire.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // REFERENCE
                  // ==================================================

                  TextFormField(
                    controller: referenceController,
                    decoration: const InputDecoration(
                      labelText: 'Référence',
                      hintText: 'Ex : CRP-001',
                      prefixIcon: Icon(
                        Icons.tag,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null ||
                          value.trim().isEmpty) {
                        return 'La référence est obligatoire.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // BARCODE
                  // ==================================================

                  TextFormField(
                    controller: barcodeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Code-barres',
                      prefixIcon: Icon(
                        Icons.qr_code_scanner,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // CATEGORY
                  // ==================================================

                  DropdownButtonFormField<CategoryModel>(
                    initialValue: selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      prefixIcon: Icon(
                        Icons.category_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map(
                      (CategoryModel category) {
                        return DropdownMenuItem<CategoryModel>(
                          value: category,
                          child: Text(
                            category.name,
                          ),
                        );
                      },
                    ).toList(),
                    onChanged: (CategoryModel? value) {
                      setState(() {
                        selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return 'Sélectionnez une catégorie.';
                      }

                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // UNIT
                  // ==================================================

                  DropdownButtonFormField<String>(
                    initialValue: selectedUnit,
                    decoration: const InputDecoration(
                      labelText: 'Unité',
                      prefixIcon: Icon(
                        Icons.straighten,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'piece',
                        child: Text('Pièce'),
                      ),
                      DropdownMenuItem(
                        value: 'ml',
                        child: Text('Millilitre'),
                      ),
                      DropdownMenuItem(
                        value: 'l',
                        child: Text('Litre'),
                      ),
                      DropdownMenuItem(
                        value: 'g',
                        child: Text('Gramme'),
                      ),
                      DropdownMenuItem(
                        value: 'kg',
                        child: Text('Kilogramme'),
                      ),
                      DropdownMenuItem(
                        value: 'box',
                        child: Text('Boîte'),
                      ),
                    ],
                    onChanged: (String? value) {
                      if (value == null) {
                        return;
                      }

                      setState(() {
                        selectedUnit = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // MINIMUM STOCK
                  // ==================================================

                  TextFormField(
                    controller:
                        minimumStockController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Stock minimum',
                      hintText: 'Ex : 100',
                      prefixIcon: Icon(
                        Icons.warning_amber_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateNumber,
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // MAXIMUM STOCK
                  // ==================================================

                  TextFormField(
                    controller:
                        maximumStockController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Stock maximum',
                      hintText: 'Ex : 1000',
                      prefixIcon: Icon(
                        Icons.inventory_2_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateNumber,
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // PURCHASE PRICE
                  // ==================================================

                  TextFormField(
                    controller:
                        purchasePriceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Prix d’achat',
                      hintText: 'Ex : 2500.00',
                      prefixIcon: Icon(
                        Icons.payments_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validateNumber,
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // EXPIRATION DATE
                  // ==================================================

                  TextFormField(
                    controller:
                        expirationDateController,
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: 'Date d’expiration',
                      prefixIcon: Icon(
                        Icons.calendar_today_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                    onTap: _selectExpirationDate,
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // STORAGE TEMPERATURE
                  // ==================================================

                  TextFormField(
                    controller:
                        temperatureController,
                    decoration: const InputDecoration(
                      labelText:
                          'Température de stockage',
                      hintText: 'Ex : 2-8°C',
                      prefixIcon: Icon(
                        Icons.thermostat_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ==================================================
                  // DESCRIPTION
                  // ==================================================

                  TextFormField(
                    controller:
                        descriptionController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(
                        Icons.description_outlined,
                      ),
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // ==================================================
                  // SAVE
                  // ==================================================

                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed:
                          isLoading
                              ? null
                              : _saveProduct,
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child:
                                  CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Ajouter le produit',
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  // IMAGE PICKER UI
  // ============================================================

  Widget _buildImagePicker() {
    return Center(
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Colors.grey.shade300,
            ),
          ),
          child: selectedImage == null
              ? const Column(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo_outlined,
                      size: 42,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Ajouter une photo',
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius:
                      BorderRadius.circular(20),
                  child: Image.file(
                    selectedImage!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  // ============================================================
  // DATE PICKER
  // ============================================================

  Future<void> _selectExpirationDate() async {
    final DateTime? date =
        await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (date == null) {
      return;
    }

    final String month =
        date.month.toString().padLeft(2, '0');

    final String day =
        date.day.toString().padLeft(2, '0');

    expirationDateController.text =
        '${date.year}-$month-$day';
  }

  // ============================================================
  // NUMBER VALIDATION
  // ============================================================

  String? _validateNumber(String? value) {
    if (value == null ||
        value.trim().isEmpty) {
      return 'Ce champ est obligatoire.';
    }

    final double? number = double.tryParse(
      value.replaceAll(',', '.'),
    );

    if (number == null) {
      return 'Veuillez entrer un nombre valide.';
    }

    if (number < 0) {
      return 'La valeur ne peut pas être négative.';
    }

    return null;
  }
}