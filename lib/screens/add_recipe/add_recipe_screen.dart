import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_recipe/components/error.dart';
import 'package:share_recipe/models/recipe.dart';
import 'package:share_recipe/providers/auth_provider.dart';
import 'package:share_recipe/providers/my_recipe_provider.dart';
import 'package:share_recipe/services/recipe_service.dart';
import 'package:share_recipe/utils/function.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key, this.recipe});
  final Recipe? recipe;

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  String? _selectedImg;
  final _imagePicker = ImagePicker();
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _instructionsController = TextEditingController();
  final _countryController = TextEditingController();
  final _tagsController = TextEditingController();
  final List<Map<String, TextEditingController>> _ingredients = [];

  Future<void> _pickImg() async {
    final XFile? pickedFile = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _selectedImg = pickedFile.path;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _addNewIngredient();
    if (widget.recipe != null) {
      _titleController.text = widget.recipe!.title;
      _descriptionController.text = widget.recipe!.description;
      _countryController.text = widget.recipe!.country ?? '';
      _tagsController.text = widget.recipe!.tags?.join(', ') ?? '';
      if (widget.recipe!.imageUrl.isNotEmpty) {
        _selectedImg = widget.recipe!.imageUrl;
      }
    }
  }

  void _addNewIngredient() {
    setState(() {
      if (widget.recipe != null) {
        _ingredients.addAll(
          widget.recipe!.ingredients.map(
            (e) => {
              'ingredient': TextEditingController(text: e),
              'quantity': TextEditingController(),
            },
          ),
        );
      } else {
        _ingredients.add({
          'ingredient': TextEditingController(),
          'quantity': TextEditingController(),
        });
      }
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

  Future<void> _saveRecipe(User? user) async {
    if (_formKey.currentState!.validate()) {
      if (_selectedImg == null) {
        showErrorSnackBar(context, "画像を選択してください");
        return;
      }
      final compressedImg = await compressImg(File(_selectedImg!));
      final imgUrl = await recipeService.uploadImage(XFile(compressedImg.path));
      if (imgUrl.isEmpty) {
        if (!mounted) return;
        showErrorSnackBar(context, "画像のアップロードに失敗しました");
        return;
      }
      final newRecipe = Recipe(
        title: _titleController.text,
        description: _descriptionController.text,
        ingredients: _ingredients.map((e) => e["ingredient"]!.text).toList(),
        imageUrl: imgUrl,
        userId: user?.uid ?? '',
        createdAt: widget.recipe?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
        country: _countryController.text,
        tags: _tagsController.text.split(',').map((e) => e.trim()).toList(),
      );
      if (widget.recipe != null) {
        ref.read(myRecipesProvider.notifier).updateRecipe(newRecipe);
      } else {
        ref.read(myRecipesProvider.notifier).addRecipe(newRecipe);
      }
      if (!mounted) return;
      Navigator.pop(context);
    }
  }

  Future<void> _deleteRecipe() async {
    if (widget.recipe != null) {
      await recipeService.deleteImage(widget.recipe!.imageUrl);
      await recipeService.deleteRecipe(widget.recipe!.id!);
    }
    if (!mounted) return;
    Navigator.pop(context);
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
    final user = ref.watch(authProvider);
    bool isMyRecipe = widget.recipe?.userId == user?.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text("レシピ登録"),
        actions: [
          widget.recipe != null
              ? IconButton(
                onPressed: _deleteRecipe,
                icon: Icon(Icons.delete, color: Colors.red),
              )
              : const SizedBox.shrink(),
          if (isMyRecipe)
            IconButton(
              onPressed: () => {_saveRecipe(user)},
              icon: Icon(Icons.save),
            ),
        ],
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
                child: InkWell(
                  onTap: isMyRecipe ? _pickImg : null,
                  child:
                      _selectedImg == null
                          ? Column(
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
                          )
                          : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child:
                                _selectedImg!.startsWith('http')
                                    ? Image.network(
                                      _selectedImg!,
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200,
                                    )
                                    : Image.file(
                                      File(_selectedImg!),
                                      fit: BoxFit.cover,
                                      width: double.infinity,
                                      height: 200,
                                    ),
                          ),
                ),
              ),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      enabled: isMyRecipe,
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
                      enabled: isMyRecipe,
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
                                          enabled: isMyRecipe,
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
                                          enabled: isMyRecipe,
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
                      enabled: isMyRecipe,
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
                    TextFormField(
                      enabled: isMyRecipe,
                      controller: _countryController,
                      decoration: InputDecoration(labelText: '国'),
                    ),
                    TextFormField(
                      enabled: isMyRecipe,
                      controller: _tagsController,
                      decoration: InputDecoration(labelText: 'タグ'),
                    ),
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
