import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_shopping_app/data/category_data.dart';
import 'package:flutter_shopping_app/models/grocery_models.dart';
import 'package:flutter_shopping_app/widget/new_item_widget.dart';

import 'package:http/http.dart' as http;

class GroceryListWidget extends StatefulWidget {
  const GroceryListWidget({super.key});

  @override
  State<GroceryListWidget> createState() => _GroceryListWidgetState();
}

class _GroceryListWidgetState extends State<GroceryListWidget> {
  List<GroceryItem> _groceryItem = [];
  var _isLoading = true;
  String? _error; // check the error for the database

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final url = Uri.https(
        'flutter-shop-66044-default-rtdb.firebaseio.com', 'shopping-list.json');
    final response = await http.get(url);

    if (response.statusCode >= 400) {
      setState(() {
        _error = 'Failed to fetch Data, Please try again later.';
      });
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];
    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
            (catItem) => catItem.value.title == item.value['category'],
          )
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    setState(() {
      _groceryItem = loadedItems;
      _isLoading = false;
    });
  }

  void _addItem() async {
    // final newItem = await Navigator.of(context).push<GroceryItem>(
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
    //_loadData();
    // if (newItem == null) {
    //   return;
    // }

    // setState(() {
    //   _groceryItem.add(newItem);
    // }); // this was to be used when we were not using the firebase and getting the data form the user and displaying that
  }

  void _removeItem(GroceryItem item) {
    setState(() {
      _groceryItem.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'NO Item',
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItem.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItem.length,
        itemBuilder: (context, index) => Dismissible(
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.symmetric(
              vertical: 4,
              horizontal: 15,
            ),
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(
                Icons.delete_forever,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
          onDismissed: (direction) {
            _removeItem(
              _groceryItem[index],
            );
          },
          key: ValueKey(_groceryItem[index].id),
          child: ListTile(
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

    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
        ),
      );
    }

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
      body: content,
    );
  }
}
