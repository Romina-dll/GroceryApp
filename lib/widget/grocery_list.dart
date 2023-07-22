import 'dart:convert';
import 'dart:html';
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
  late Future<List<GroceryItem>> _loadedItems;
  String? _error;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadedItems = _loadItems();
  }

  Future<List<GroceryItem>> _loadItems() async {
    final url = Uri.https('groceryapp-a2439-default-rtdb.firebaseio.com','shopping-list.json');
      final response = await http.get(url);

      if(response.statusCode >= 400){
        throw Exception('Failed to fetch grocery item . please try again');
      }

      if(response.body == 'null'){
        return [];
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
      return loadedItems;


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
      body:FutureBuilder(
        future: _loadedItems,
        builder: (context,snapshot){
          if(snapshot.connectionState == ConnectionState.waiting){
            return  Center(child : CircularProgressIndicator());
          }else{
            if(snapshot.hasError){
              return Center(child: Text(snapshot.error.toString()));
            }else{
              if(snapshot.data!.isEmpty){
                return Text('No items added yet');
              }
              return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (ctx , index) => Dismissible(
                    key: ValueKey(snapshot.data![index].id),
                    onDismissed: (direction){
                      _removeItem(snapshot.data![index]);
                    },
                    child: ListTile(
                      title: Text(snapshot.data![index].name),
                      leading: Container(
                        width: 24,
                        height: 24,
                        color: snapshot.data![index].category.color,
                      ),
                      trailing: Text(snapshot.data![index].quantity.toString()),
                    ),
                  )
              );
            }
          }
        },
      )
    );
  }
}