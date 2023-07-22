import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:form_application/models/grocery_item.dart';
import 'package:form_application/widget/new_item.dart';
import 'package:http/http.dart' as http;
import '../data/categories.dart';

class GroceryList extends StatefulWidget{
  GroceryList({super.key});
  
  @override
  State<GroceryList> createState() {
    // TODO: implement createState
    return _GroceryList();
  }
}

class _GroceryList extends State<GroceryList>{
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https('groceryapp-a2439-default-rtdb.firebaseio.com','shopping-list.json');

    try{
      final response = await http.get(url);

      if(response.statusCode >= 400){
        setState(() {
          _error = 'Failed to fetch data. Please try again latter!';
        });
      }

      if(response.body == 'null'){
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String,dynamic>listData = json.decode(response.body);
      final List<GroceryItem> loadedItems = [];
      for(final item in listData.entries){
        final category = categories.entries.firstWhere(
                (catItem) => catItem.value.title == item.value['category']).value;
        loadedItems.add(GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category)
        );
      }
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    }catch (error){
        setState(() {
          _error = 'Failed to fetch data. Please try again latter';
        });
    }

  }

  void _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
        MaterialPageRoute(builder: (ctx) => NewItemScreen())
    );
    if(newItem == null)
      return ;
    setState(() {
      _groceryItems.add(newItem);
    });
  }

  _removeItem(GroceryItem item) async {
    final index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });
    final url = Uri.https('groceryapp-a2439-default-rtdb.firebaseio.com','shopping-list/${item.id}.json');
    final response =await http.delete(url);
    if(response.statusCode >= 400){
      setState(() {
        _groceryItems.insert(index , item);
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    Widget content ;



    if(_isLoading){
      content = Center(child : CircularProgressIndicator());
    }else{
      content = ListView.builder(
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
      );
    }

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
      body:_error == null ? content : Center(child: Text(_error!),) ,
    );
  }
}