// ignore_for_file: use_build_context_synchronously

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
  //var _isLoading = true;
  String? _error; // check the error for the database
  late Future<List<GroceryItem>> _loadedItem;

  @override
  void initState() {
    super.initState();
    _loadedItem = _loadData();
  }

  Future<List<GroceryItem>> _loadData() async {
    final url = Uri.https(
        'flutter-shop-66044-default-rtdb.firebaseio.com', 'shopping-list.json');

    final response = await http.get(url);

    if (response.statusCode >= 400) {
      throw Exception("Failed to fetch, Please try again later.");
    }

    if (response.body == "null") {
      // setState(() {
      //   _isLoading = false;
      // });
      return [];
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
    return loadedItems;
    // setState(() {
    //   _groceryItem = loadedItems;
    //   _isLoading = false;
    // });
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

  void _removeItem(GroceryItem item) async {
    final index = _groceryItem.indexOf(item);
    setState(() {
      _groceryItem.remove(item);
    });
    final url = Uri.https('flutter-shop-66044-default-rtdb.firebaseio.com',
        'shopping-list/${item.id}.json');

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text(
            "Can't be deleted, PleaseTry again Later",
            style: TextStyle(
              //color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          duration: const Duration(seconds: 2),
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
      );
      setState(() {
        _groceryItem.insert(index, item);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // if (_isLoading) {
    //   content = const Center(
    //     child: CircularProgressIndicator(),
    //   );
    // }

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
      // body: content,
      body: FutureBuilder(
        future: _loadedItem,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          if (snapshot.data!.isEmpty) {
            const Center(
              child: Text(
                'NO Item',
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
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
                  snapshot.data![index],
                );
              },
              key: ValueKey(snapshot.data![index].id),
              child: ListTile(
                title: Text(snapshot.data![index].name),
                leading: Container(
                  height: 24,
                  width: 24,
                  color: snapshot.data![index].category.color,
                ),
                trailing: Text(
                  snapshot.data![index].quantity.toString(),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
