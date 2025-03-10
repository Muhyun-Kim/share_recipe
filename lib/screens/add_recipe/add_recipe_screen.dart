import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_recipe/components/error.dart';
import 'package:share_recipe/models/recipe.dart';
import 'package:share_recipe/services/recipe_service.dart';
import 'package:share_recipe/utils/function.dart';

class AddRecipeScreen extends StatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  State<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends State<AddRecipeScreen> {
  File? _selectedImg;
  final _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final List<Map<String, TextEditingController>> _ingredients = [];

  Future<void> _pickImg() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImg = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _addNewIngredient();
  }

  void _addNewIngredient() {
    setState(() {
      _ingredients.add({
        'ingredient': TextEditingController(),
        'quantity': TextEditingController(),
      });
    });
  }

  void _removeIngredient(int index) {
    setState(() {
      _ingredients.removeAt(index);
    });
  }

  void _onTextChanged(int index) {
    final isLast = index == _ingredients.length - 1;
    final ingredientFilled = _ingredients[index]["ingredient"]!.text.isNotEmpty;
    final quantityFilled = _ingredients[index]["quantity"]!.text.isNotEmpty;

    if (isLast && ingredientFilled && quantityFilled) {
      _addNewIngredient();
    }
    if (!ingredientFilled && !quantityFilled && _ingredients.length > 1) {
      _removeIngredient(index);
    }
  }

  Future<void> _saveRecipe() async {
    if (_selectedImg == null) {
      showErrorSnackBar(context, "画像を選択してください");
      return;
    }
    final compressedImg = await compressImg(_selectedImg!);
    final imgUrl = await recipeService.uploadImage(XFile(compressedImg.path));
    if (imgUrl.isEmpty) {
      return;
    }
    if (_formKey.currentState!.validate()) {
      final recipe = Recipe(
        title: _titleController.text,
        description: _descriptionController.text,
        ingredients: _ingredients.map((e) => e["ingredient"]!.text).toList(),
        imageUrl: imgUrl,
      );
      await recipeService.addRecipe(recipe);
    }
  }

  @override
  void dispose() {
    for (var controllers in _ingredients) {
      controllers["ingredient"]!.dispose();
      controllers["quantity"]!.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("レシピ登録"),
        actions: [IconButton(onPressed: _saveRecipe, icon: Icon(Icons.save))],
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    _selectedImg == null
                        ? InkWell(
                          onTap: _pickImg,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 48,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8),
                              Text(
                                '画像を追加',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                        : Image.file(_selectedImg!, fit: BoxFit.cover),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(labelText: 'タイトル'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'タイトルを入力してください';
                        }
                        return null;
                      },
                    ),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(labelText: '説明'),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '説明を入力してください';
                        }
                        return null;
                      },
                    ),
                    SizedBox(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _ingredients.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              _ingredients[index]["ingredient"],
                                          decoration: InputDecoration(
                                            labelText: '材料',
                                          ),
                                          onChanged:
                                              (value) => _onTextChanged(index),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Expanded(
                                        child: TextFormField(
                                          controller:
                                              _ingredients[index]["quantity"],
                                          decoration: InputDecoration(
                                            labelText: '分量',
                                          ),
                                          onChanged:
                                              (value) => _onTextChanged(index),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    TextFormField(
                      controller: _instructionsController,
                      decoration: InputDecoration(labelText: '作り方'),
                      maxLines: null,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '作り方を入力してください';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 64),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
