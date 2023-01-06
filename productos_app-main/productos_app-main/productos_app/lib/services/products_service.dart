import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import '../models/models.dart';

class ProductsService extends ChangeNotifier {
  final String _baseUrl = 'flutter-varios-150cb-default-rtdb.firebaseio.com';

  final List<Product> products = [];
  Product? selectedProduct;
  final storage = FlutterSecureStorage();

  File? newPictureFile;

  bool isLoading = true;
  bool isSaving = false;

  ProductsService() {
    loadProducts();
  }

  Future<List<Product>> loadProducts() async {
    isLoading = true;
    notifyListeners();
    final url = Uri.https(_baseUrl, 'products.json',
        {'auth': await storage.read(key: 'token') ?? ''});
    final resp = await http.get(url);

    final Map<String, dynamic> productsMap = json.decode(resp.body);
    // print(productsMap);
    productsMap.forEach((key, value) {
      final tempProduct = Product.fromMap(value);
      tempProduct.id = key;
      products.add(tempProduct);
    });
    isLoading = false;
    notifyListeners();

    // print(products[0].name);

    return products;
  }

  Future seveOrCreateProduct(Product product) async {
    isSaving = true;
    notifyListeners();
    if (product.id == null) {
      //es necesario crear
      await createProduct(product);
    } else {
      //actualizar información del producto
      await updateProduct(product);
    }

    isSaving = false;
    notifyListeners();
  }

  Future<String> updateProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products/${product.id}.json',
        {'auth': await storage.read(key: 'token') ?? ''});
    final resp = await http.put(url, body: product.toJson());
    final decodedData = resp.body;

    // print(decodedData);

    //Actualizar el listado de productos
    final index = products.indexWhere((element) => element.id == product.id);
    products[index] = product;
    return product.id!;
  }

  Future<String> createProduct(Product product) async {
    final url = Uri.https(_baseUrl, 'products.json',
        {'auth': await storage.read(key: 'token') ?? ''});
    final resp = await http.post(url, body: product.toJson());
    final decodedData = json.decode(resp.body);
    //decodedData contendrá el ID del producto
    // print(decodedData);
    product.id = decodedData['name'];
    products.add(product);
    return product.id!;
  }

  void updateSelectedProductImage(String path) {
    selectedProduct!.picture = path;
    newPictureFile = File.fromUri(Uri(path: path));
    notifyListeners();
  }

  Future<String?> uploadImage() async {
    if (newPictureFile == null) return null;
    isSaving = true;
    notifyListeners();

    final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/lostininternet/image/upload?upload_preset=lzq1kogw');

    final imageUploadRequest = http.MultipartRequest('POST', url);
    final file =
        await http.MultipartFile.fromPath('file', newPictureFile!.path);

    imageUploadRequest.files.add(file);
    final streamResponse = await imageUploadRequest.send();
    final resp = await http.Response.fromStream(streamResponse);
    if (resp.statusCode != 200 && resp.statusCode != 201) {
      print('Algo salió mal');
      print(resp.body);
      return null;
    }
    newPictureFile = null;
    // print(resp.body);
    final decodedData = json.decode(resp.body);
    return decodedData['secure_url'];
  }
}
