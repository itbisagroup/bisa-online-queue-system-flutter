import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/data/database/database_helper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pickup_queue_system/data/model/outlet_model.dart';
import 'package:pickup_queue_system/routes/app_pages.dart';

class InitialController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();

  final RxString fullName = ''.obs;
  final RxString logoPath = ''.obs;
  final RxBool isLoading = false.obs;

  // Other optional fields
  final RxString codeName = ''.obs;
  final RxString address = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString subdistrict = ''.obs;
  final RxString city = ''.obs;
  final RxString postalCode = ''.obs;
  final RxString province = ''.obs;
  final RxString country = ''.obs;
  final RxString faxNumber = ''.obs;
  final RxString emailAddress = ''.obs;
  final RxString description = ''.obs;

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      logoPath.value = image.path;
    }
  }

  Future<bool> saveOutlet() async {
    if (fullName.value.isEmpty || logoPath.value.isEmpty) {
      Get.snackbar('Error', 'Full Name and Logo are required');
      return false;
    }

    isLoading.value = true;

    try {
      final outlet = Outlet(
        fullName: fullName.value,
        logo: logoPath.value,
        codeName: codeName.value,
        address: address.value,
        phoneNumber: phoneNumber.value,
        subdistrict: subdistrict.value,
        city: city.value,
        postalCode: postalCode.value,
        province: province.value,
        country: country.value,
        faxNumber: faxNumber.value,
        emailAddress: emailAddress.value,
        description: description.value,
        createdAt: DateTime.now().toIso8601String(),
        updatedAt: DateTime.now().toIso8601String(),
      );

      final db = await _databaseHelper.database;
      await db.insert('Outlet', outlet.toMap());
      await const FlutterSecureStorage().write(
        key: 'outlet',
        value: faxNumber.value,
      );
      isLoading.value = false;
      Get.offAllNamed(Routes.home);
      return true;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to save outlet: $e');
      return false;
    }
  }
}
