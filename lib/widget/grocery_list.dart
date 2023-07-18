import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_application/data/dummy_items.dart';
import 'package:form_application/models/grocery_item.dart';
import 'package:form_application/widget/new_item.dart';

class GroceryList extends StatefulWidget{
  GroceryList({super.key});
  
  @override
  State<GroceryList> createState() {
    // TODO: implement createState
    return _GroceryList();
  }
}

class _GroceryList extends State<GroceryList>{
  final List<GroceryItem> _groceryItems = [];

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => NewItemScreen())
    );
    if(newItem == null){
      return ;
    }
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  _removeItem(GroceryItem item){
    setState(() {
      _groceryItems.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Groceries'),
        actions: [
          IconButton(
              onPressed: _addItem,
              icon: Icon(Icons.add)
          )
        ],
      ),
      body:_groceryItems.isEmpty ? Center(child : Text('No items added yet!')) : ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx , index) => Dismissible(
            key: ValueKey(_groceryItems[index].id),
            onDismissed: (direction){
              _removeItem(_groceryItems[index]);
            },
            child: ListTile(
              title: Text(_groceryItems[index].name),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(_groceryItems[index].quantity.toString()),
            ),
        )
      ),
    );
  }
}