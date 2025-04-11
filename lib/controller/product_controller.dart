// import 'package:get/get.dart';
// import 'package:pickup_queue_system/data/database/database_helper.dart';
// import 'package:pickup_queue_system/data/model/product_model.dart';


// class ProductController extends GetxController {
//   final DatabaseHelper _databaseHelper = DatabaseHelper();
//   var products = <Product>[].obs;
//   var isLoading = true.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     fetchProducts();
//   }

//   Future<void> fetchProducts() async {
//     try {
//       isLoading(true);
//       final productList = await _databaseHelper.getProducts();
//       products.assignAll(productList.map((data) => Product.fromMap(data)));
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<void> addProduct(Product product) async {
//     await _databaseHelper.insertProduct(product.toMap());
//     await fetchProducts();
//   }

//   Future<void> updateProduct(Product product) async {
//     await _databaseHelper.updateProduct(product.toMap());
//     await fetchProducts();
//   }

//   Future<void> deleteProduct(int id) async {
//     await _databaseHelper.deleteProduct(id);
//     await fetchProducts();
//   }
// }