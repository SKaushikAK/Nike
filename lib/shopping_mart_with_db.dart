import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final database = openDatabase(
    join(await getDatabasesPath(), 'shopping_mart.db'),
    onCreate: (db, version) {
      return db.execute(
        'CREATE TABLE items(id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT, quantity INTEGER)',
      );
    },
    version: 1,
  );

  runApp(ShoppingMartApp(database: database));
}

class ShoppingMartApp extends StatelessWidget {
  final Future<Database> database;

  ShoppingMartApp({required this.database});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Shopping Mart',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ShoppingListScreen(database: database),
    );
  }
}

class ShoppingItem {
  final int? id;
  final String name;
  final int quantity;

  ShoppingItem({this.id, required this.name, required this.quantity});

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'quantity': quantity};
  }

  @override
  String toString() {
    return 'ShoppingItem{id: $id, name: $name, quantity: $quantity}';
  }
}

class ShoppingListScreen extends StatefulWidget {
  final Future<Database> database;

  ShoppingListScreen({required this.database});

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> {
  late Future<List<ShoppingItem>> items;

  @override
  void initState() {
    super.initState();
    refreshItems();
  }

  void refreshItems() {
    setState(() {
      items = getItems();
    });
  }

  Future<List<ShoppingItem>> getItems() async {
    final db = await widget.database;
    final List<Map<String, dynamic>> maps = await db.query('items');
    return List.generate(maps.length, (i) {
      return ShoppingItem(
        id: maps[i]['id'],
        name: maps[i]['name'],
        quantity: maps[i]['quantity'],
      );
    });
  }

  Future<void> insertItem(ShoppingItem item) async {
    final db = await widget.database;
    await db.insert(
      'items',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    refreshItems();
  }

  Future<void> updateItem(ShoppingItem item) async {
    final db = await widget.database;
    await db.update(
      'items',
      item.toMap(),
      where: 'id = ?',
      whereArgs: [item.id],
    );
    refreshItems();
  }

  Future<void> deleteItem(int id) async {
    final db = await widget.database;
    await db.delete(
      'items',
      where: 'id = ?',
      whereArgs: [id],
    );
    refreshItems();
  }

  void showItemDialog(BuildContext context, {ShoppingItem? item}) {
    final _nameController = TextEditingController(text: item?.name ?? '');
    final _quantityController =
        TextEditingController(text: item?.quantity.toString() ?? '');

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(item == null ? 'Add Item' : 'Edit Item'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Item Name'),
              ),
              TextField(
                controller: _quantityController,
                decoration: InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = _nameController.text.trim();
                final quantity =
                    int.tryParse(_quantityController.text.trim()) ?? 1;
                if (name.isNotEmpty) {
                  if (item == null) {
                    insertItem(ShoppingItem(name: name, quantity: quantity));
                  } else {
                    updateItem(ShoppingItem(
                        id: item.id, name: name, quantity: quantity));
                  }
                  Navigator.of(dialogContext).pop();
                }
              },
              child: Text(item == null ? 'Add' : 'Update'),
            ),
          ],
        );
      },
    );
  }

  void showDeleteConfirmationDialog(BuildContext context, int id) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this item?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                deleteItem(id);
                Navigator.of(dialogContext).pop();
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Shopping Mart'),
      ),
      body: FutureBuilder<List<ShoppingItem>>(
        future: items,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No items added.'));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final item = snapshot.data![index];
              return ListTile(
                title: Text(item.name),
                subtitle: Text('Quantity: ${item.quantity}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.orange),
                      onPressed: () => showItemDialog(context, item: item),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () =>
                          showDeleteConfirmationDialog(context, item.id!),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showItemDialog(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
