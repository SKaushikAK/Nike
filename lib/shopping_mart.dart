import 'package:flutter/material.dart';

void main() => runApp(ShoppingApp());

class ShoppingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Simple Shopping App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ProductListPage(),
    );
  }
}

class Product {
  final String name;
  final String category;
  final double price;
  final String imageUrl;

  Product(
      {required this.name,
      required this.category,
      required this.price,
      required this.imageUrl});
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, this.quantity = 1});
}

class ProductListPage extends StatefulWidget {
  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<Product> allProducts = [
    Product(
        name: 'Shoes',
        category: 'Footwear',
        price: 59.99,
        imageUrl:
            'https://images.unsplash.com/photo-1542291026-7eec264c27ff?fm=jpg&q=60&w=3000&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8c2hvZXN8ZW58MHx8MHx8fDA%3D'),
    Product(
        name: 'T-Shirt',
        category: 'Clothing',
        price: 19.99,
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/12/06/09/31/blank-1886008_640.png'),
    Product(
        name: 'Watch',
        category: 'Accessories',
        price: 120.0,
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/12/06/09/31/blank-1886008_640.png'),
    Product(
        name: 'Backpack',
        category: 'Bags',
        price: 40.0,
        imageUrl:
            'https://cdn.pixabay.com/photo/2016/12/06/09/31/blank-1886008_640.png'),
  ];

  List<CartItem> cart = [];
  String searchQuery = '';

  void addToCart(Product product) {
    setState(() {
      final index =
          cart.indexWhere((item) => item.product.name == product.name);
      if (index != -1) {
        cart[index].quantity++;
      } else {
        cart.add(CartItem(product: product));
      }
    });
  }

  void goToCartPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CartPage(cart: cart, onUpdateCart: updateCart)),
    );
  }

  void updateCart(List<CartItem> updatedCart) {
    setState(() {
      cart = updatedCart;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<Product> filteredProducts = allProducts
        .where((p) => p.name.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Shop'),
        actions: [
          IconButton(icon: Icon(Icons.shopping_cart), onPressed: goToCartPage),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(48),
          child: Padding(
            padding: EdgeInsets.all(8),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search products...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
        ),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        children: filteredProducts.map((product) {
          return Card(
            child: Column(
              children: [
                Image.network(product.imageUrl, height: 80, fit: BoxFit.cover),
                SizedBox(height: 4),
                Text(product.name,
                    style: TextStyle(fontWeight: FontWeight.bold)),
                Text('\$${product.price.toStringAsFixed(2)}'),
                ElevatedButton(
                  onPressed: () => addToCart(product),
                  child: Text('Add to Cart'),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

class CartPage extends StatefulWidget {
  final List<CartItem> cart;
  final Function(List<CartItem>) onUpdateCart;

  CartPage({required this.cart, required this.onUpdateCart});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  late List<CartItem> localCart;

  @override
  void initState() {
    super.initState();
    localCart = List.from(widget.cart);
  }

  double get total => localCart.fold(
      0, (sum, item) => sum + item.product.price * item.quantity);

  void removeItem(int index) {
    setState(() {
      localCart.removeAt(index);
    });
  }

  void updateQuantity(int index, int change) {
    setState(() {
      localCart[index].quantity += change;
      if (localCart[index].quantity <= 0) {
        localCart.removeAt(index);
      }
    });
  }

  void checkout() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutPage(
          cartItems: localCart,
          total: total,
          onComplete: () {
            widget.onUpdateCart([]);
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Cart'),
        actions: [
          TextButton(
            onPressed: checkout,
            child: Text('Checkout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: localCart.isEmpty
          ? Center(child: Text('Cart is empty'))
          : ListView.builder(
              itemCount: localCart.length,
              itemBuilder: (context, index) {
                final item = localCart[index];
                return ListTile(
                  leading: Image.network(item.product.imageUrl, width: 50),
                  title: Text(item.product.name),
                  subtitle: Text('Quantity: ${item.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () => updateQuantity(index, -1)),
                      IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () => updateQuantity(index, 1)),
                      IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => removeItem(index)),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(12),
        child: Text('Total: \$${total.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 20)),
      ),
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final List<CartItem> cartItems;
  final double total;
  final VoidCallback onComplete;

  CheckoutPage(
      {required this.cartItems, required this.total, required this.onComplete});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  final _formKey = GlobalKey<FormState>();
  String name = '', address = '';

  void confirmOrder() {
    if (_formKey.currentState!.validate()) {
      widget.onComplete();
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: Text('Order Confirmed'),
          content: Text('Thank you for your purchase!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('OK'),
            )
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Checkout')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('Total: \$${widget.total.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 18)),
              SizedBox(height: 12),
              TextFormField(
                decoration: InputDecoration(labelText: 'Name'),
                validator: (value) => value!.isEmpty ? 'Enter your name' : null,
                onChanged: (value) => name = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Address'),
                validator: (value) =>
                    value!.isEmpty ? 'Enter your address' : null,
                onChanged: (value) => address = value,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: confirmOrder,
                child: Text('Confirm Order'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
