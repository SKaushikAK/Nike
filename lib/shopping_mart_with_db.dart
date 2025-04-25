import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// Entry point
void main() {
  runApp(const ShoppingApp());
}

class ShoppingApp extends StatelessWidget {
  const ShoppingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const ShoppingListPage(),
    );
  }
}

// Model class for shopping item (name and price)
class CartItem {
  final String name;
  final double price;

  CartItem({required this.name, required this.price});

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price};
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(name: map['name'], price: map['price']);
  }
}

// UI Page for shopping list and cart
class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  List<CartItem> cartItems = [];

  @override
  void initState() {
    super.initState();
    loadCartItems();
  }

  // Load cart items from shared preferences
  Future<void> loadCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? cartData = prefs.getString('cart');
    if (cartData != null) {
      List<dynamic> cartList = json.decode(cartData);
      setState(() {
        cartItems = cartList.map((item) => CartItem.fromMap(item)).toList();
      });
    }
  }

  // Save cart items to shared preferences
  Future<void> saveCartItems() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> cartList =
        cartItems.map((item) => item.toMap()).toList();
    String cartData = json.encode(cartList);
    await prefs.setString('cart', cartData);
  }

  // Add item to cart
  void addItemToCart() {
    final name = _nameController.text.trim();
    final priceText = _priceController.text.trim();
    if (name.isEmpty || priceText.isEmpty) return;
    final price = double.tryParse(priceText);
    if (price == null) return; // Invalid price input

    setState(() {
      cartItems.add(CartItem(name: name, price: price));
    });

    _nameController.clear();
    _priceController.clear();
    saveCartItems();
  }

  // Remove item from cart
  void removeItemFromCart(int index) {
    setState(() {
      cartItems.removeAt(index);
    });
    saveCartItems();
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice = cartItems.fold(0, (sum, item) => sum + item.price);

    return Scaffold(
      appBar: AppBar(title: const Text('Shopping Cart')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Enter item name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Enter price',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: addItemToCart,
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: cartItems.isEmpty
                ? const Center(child: Text('No items in the cart yet'))
                : ListView.builder(
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return ListTile(
                        title: Text(item.name),
                        subtitle: Text('\$${item.price.toStringAsFixed(2)}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => removeItemFromCart(index),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Text('Total Price: ', style: TextStyle(fontSize: 18)),
                Text('\$${totalPrice.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
