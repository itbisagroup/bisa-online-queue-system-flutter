// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:pickup_queue_system/controller/product_controller.dart';
// import 'package:pickup_queue_system/data/model/product_model.dart';


// class AddEditProductScreen extends StatefulWidget {
//   final Product? product;

//   const AddEditProductScreen({super.key, this.product});

//   @override
//   State<AddEditProductScreen> createState() => _AddEditProductScreenState();
// }

// class _AddEditProductScreenState extends State<AddEditProductScreen> {
//   final _formKey = GlobalKey<FormState>();
//   late final TextEditingController _titleController;
//   late final TextEditingController _descriptionController;
//   late final TextEditingController _priceController;

//   @override
//   void initState() {
//     super.initState();
//     _titleController = TextEditingController(text: widget.product?.title ?? '');
//     _descriptionController = TextEditingController(text: widget.product?.description ?? '');
//     _priceController = TextEditingController(
//       text: widget.product?.price?.toString() ?? '',
//     );
//   }

//   @override
//   void dispose() {
//     _titleController.dispose();
//     _descriptionController.dispose();
//     _priceController.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final ProductController productController = Get.find();

//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _titleController,
//                 decoration: const InputDecoration(labelText: 'Title'),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter a title';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(labelText: 'Description'),
//                 maxLines: 3,
//               ),
//               TextFormField(
//                 controller: _priceController,
//                 decoration: const InputDecoration(labelText: 'Price'),
//                 keyboardType: TextInputType.number,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return null; // Price is optional
//                   }
//                   if (double.tryParse(value) == null) {
//                     return 'Please enter a valid number';
//                   }
//                   return null;
//                 },
//               ),
//               const SizedBox(height: 20),
//               ElevatedButton(
//                 onPressed: () async {
//                   if (_formKey.currentState!.validate()) {
//                     final product = Product(
//                       id: widget.product?.id,
//                       title: _titleController.text,
//                       description: _descriptionController.text.isEmpty 
//                           ? null 
//                           : _descriptionController.text,
//                       price: _priceController.text.isEmpty 
//                           ? null 
//                           : double.parse(_priceController.text),
//                     );

//                     if (widget.product == null) {
//                       await productController.addProduct(product);
//                     } else {
//                       await productController.updateProduct(product);
//                     }

//                     Get.back();
//                   }
//                 },
//                 child: Text(widget.product == null ? 'Add Product' : 'Update Product'),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }