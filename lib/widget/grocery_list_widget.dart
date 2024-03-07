import 'package:flutter/material.dart';
import 'package:flutter_shopping_app/models/grocery_models.dart';
import 'package:flutter_shopping_app/widget/new_item_widget.dart';

class GroceryListWidget extends StatefulWidget {
  const GroceryListWidget({super.key});

  @override
  State<GroceryListWidget> createState() => _GroceryListWidgetState();
}

class _GroceryListWidgetState extends State<GroceryListWidget> {
  final List<GroceryItem> _groceryItem = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItemWidget(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItem.add(newItem);
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Groceries',
        ),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(_groceryItem[index].name),
          leading: Container(
            height: 24,
            width: 24,
            color: _groceryItem[index].category.color,
          ),
          trailing: Text(
            _groceryItem[index].quantity.toString(),
          ),
        ),
      ),
    );
  }
}
