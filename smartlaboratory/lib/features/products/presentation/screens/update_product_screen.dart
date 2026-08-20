import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/features/products/data/models/product_model.dart';
import 'package:smartlaboratory/features/products/presentation/cubit/product_cubit.dart';

class UpdateProductScreen extends StatefulWidget {
  final ProductModel product;

  const UpdateProductScreen({super.key, required this.product});

  @override
  State<UpdateProductScreen> createState() => _UpdateProductScreenState();
}

class _UpdateProductScreenState extends State<UpdateProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _reference;
  late final TextEditingController _barcode;
  late final TextEditingController _minimum;
  late final TextEditingController _maximum;
  late final TextEditingController _price;
  late final TextEditingController _temperature;
  late final TextEditingController _expiration;
  late final TextEditingController _description;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final product = widget.product;
    _name = TextEditingController(text: product.name);
    _reference = TextEditingController(text: product.reference);
    _barcode = TextEditingController(text: product.barcode ?? '');
    _minimum = TextEditingController(text: product.minimumStock.toString());
    _maximum = TextEditingController(text: product.maximumStock.toString());
    _price = TextEditingController(text: product.purchasePrice.toString());
    _temperature = TextEditingController(text: product.storageTemperature);
    _expiration = TextEditingController(text: product.expirationDate ?? '');
    _description = TextEditingController(text: product.description);
  }

  @override
  void dispose() {
    _name.dispose();
    _reference.dispose();
    _barcode.dispose();
    _minimum.dispose();
    _maximum.dispose();
    _price.dispose();
    _temperature.dispose();
    _expiration.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Modifier le produit')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _field(_name, 'Nom du produit', required: true),
            _field(_reference, 'Référence', required: true),
            _field(_barcode, 'Code-barres'),
            _field(_minimum, 'Stock minimum', number: true),
            _field(_maximum, 'Stock maximum', number: true),
            _field(_price, 'Prix d’achat', number: true),
            _field(_temperature, 'Température de stockage'),
            _field(_expiration, 'Date d’expiration (AAAA-MM-JJ)'),
            _field(_description, 'Description', maxLines: 4),
            const SizedBox(height: 20),
            SizedBox(
              height: 52,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(_saving ? 'Enregistrement...' : 'Enregistrer'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool required = false,
    bool number = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: number
            ? const TextInputType.numberWithOptions(decimal: true)
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                  ? 'Champ obligatoire'
                  : null
            : null,
      ),
    );
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final minimum = double.tryParse(_minimum.text.replaceAll(',', '.'));
    final maximum = double.tryParse(_maximum.text.replaceAll(',', '.'));
    final price = double.tryParse(_price.text.replaceAll(',', '.'));
    if (minimum == null || maximum == null || price == null) {
      _showError('Les valeurs numériques sont invalides.');
      return;
    }

    setState(() => _saving = true);
    final product = widget.product;
    final supplierId = product.supplier is int
        ? product.supplier
        : product.supplier is Map
        ? product.supplier['id']
        : null;
    await context.read<ProductCubit>().updateProduct(
      ProductModel(
        id: product.id,
        name: _name.text.trim(),
        reference: _reference.text.trim(),
        barcode: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
        category: product.category,
        supplier: supplierId,
        unit: product.unit,
        stockQuantity: product.stockQuantity,
        minimumStock: minimum,
        maximumStock: maximum,
        purchasePrice: price,
        expirationDate: _expiration.text.trim().isEmpty
            ? null
            : _expiration.text.trim(),
        storageTemperature: _temperature.text.trim(),
        image: product.image,
        description: _description.text.trim(),
        isLowStock: product.isLowStock,
      ),
    );
    if (!mounted) return;
    final state = context.read<ProductCubit>().state;
    if (state is ProductError) {
      setState(() => _saving = false);
      _showError(state.message);
      return;
    }
    Navigator.pop(context, true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
