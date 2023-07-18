import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_application/models/category.dart';
import 'package:form_application/models/grocery_item.dart';

import '../data/categories.dart';

class NewItemScreen extends StatefulWidget {
  NewItemScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewItemScreen();
  }
}

class _NewItemScreen extends State<NewItemScreen> {
  final _formKey = GlobalKey<FormState>();
  var _enteredName = '';
  var _enteredQuentity = 1;
  var _selectedCategory = categories[Categories.vegetables]!;

  void _saveItem(){
    if(_formKey.currentState!.validate()){
      _formKey.currentState!.save();
      Navigator.of(context).pop(GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQuentity,
          category: _selectedCategory,
        )
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new item'),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text('Name')),
                validator: (value) {
                  if(value == null ||
                      value.isEmpty  ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50
                  )
                    return 'Must be between 1 and 50 characters';
                  return null;
                },
                onSaved: (value){
                  _enteredName = value!;
                },
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(child: TextFormField(
                    decoration: InputDecoration(label: Text('Quantity')),
                    keyboardType: TextInputType.number,
                    initialValue: _enteredQuentity.toString(),
                    validator: (value) {
                      if(value == null ||
                          value.isEmpty  ||
                          int.tryParse(value) == null ||
                          int.tryParse(value)! <= 0
                      )
                        return 'number is not valid';
                      return null;
                    },
                    onSaved: (value){
                      _enteredQuentity = int.parse(value!);
                    },
                  ),),
                  SizedBox(
                    width: 8,
                  ),
                  Expanded(child: DropdownButtonFormField(
                    value: _selectedCategory,
                      items: [
                    for (final catergory in categories.entries)
                      DropdownMenuItem(
                          value : catergory.value,
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                color: catergory.value.color,
                              ),
                              SizedBox(
                                width: 6,
                              ),
                              Text(catergory.value.title)
                            ],
                          )
                      )
                  ], onChanged: (value){
                      setState(() {
                      _selectedCategory = value!;
                      });
                  })),
                ],
              ),
              SizedBox(height: 12,),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(onPressed: (){
                    _formKey.currentState!.reset();
                  },
                      child: Text('Reset')),
                  ElevatedButton(onPressed: _saveItem, child: Text('Add Item'))
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
