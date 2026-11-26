import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: CartScreen()));

class CartItem {
  final String name;
  final double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [];
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  String? _nameError;
  String? _priceError;

  @override
  void initState() {
    super.initState();
    _items.addAll([
      CartItem(name: 'Rice', price: 60.00, quantity: 2),
      CartItem(name: 'Eggs', price: 8.00, quantity: 12),
      CartItem(name: 'Milk', price: 95.00, quantity: 1),
    ]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  void _increase(int i) {
    setState(() {
      if (_items[i].quantity < 99) _items[i].quantity++;
    });
  }

  void _decrease(int i) {
    setState(() {
      if (_items[i].quantity > 1) _items[i].quantity--;
    });
  }

  void _toggle(int i) {
    setState(() {
      _items[i].gotIt = !_items[i].gotIt;
    });
  }

  void _addItem() {
    final name = _nameController.text.trim();
    final price = double.tryParse(_priceController.text.trim());
    setState(() {
      _nameError = name.isEmpty ? 'Enter item name' : null;
      _priceError = (price == null || price <= 0)
          ? 'Enter a price greater than 0'
          : null;
      if (_nameError == null && _priceError == null) {
        _items.add(CartItem(name: name, price: price!));
        _nameController.clear();
        _priceController.clear();
      }
    });
  }

  void _clearChecked() {
    setState(() {
      _items.removeWhere((item) => item.gotIt);
    });
  }

  double get _total {
    double sum = 0;
    for (final item in _items) {
      sum += item.price * item.quantity;
    }
    return sum;
  }

  @override
  Widget build(BuildContext context) {
    final gotCount = _items.where((i) => i.gotIt).length;

    return Scaffold(
      appBar: AppBar(title: const Text('Mini Shopping Cart')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                itemBuilder: (context, i) => CartItemTile(
                  item: _items[i],
                  onIncrease: () => _increase(i),
                  onDecrease: () => _decrease(i),
                  onToggle: () => _toggle(i),
                ),
              ),
            ),
            Container(
              width: double.infinity,
              color: Colors.teal.shade50,
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Items: ${_items.length} • Got it: $gotCount'),
                  Text(
                    'Total: PHP ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Item name',
                            errorText: _nameError,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _priceController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(
                            labelText: 'Price',
                            errorText: _priceError,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _addItem,
                          child: const Text('Add'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _clearChecked,
                          child: const Text('Clear checked'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onToggle;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Checkbox(value: item.gotIt, onChanged: (_) => onToggle()),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: item.gotIt
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  Text('PHP ${item.price.toStringAsFixed(2)} each'),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: onDecrease,
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: onIncrease,
            ),
          ],
        ),
      ),
    );
  }
}
