import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:pickup_queue_system/data/database/database_helper.dart';
import 'package:pickup_queue_system/data/model/outlet_model.dart';
import 'package:pickup_queue_system/routes/app_pages.dart';

class InitialController extends GetxController {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  // Form fields
  final RxString codeName = ''.obs;
  final RxString fullName = ''.obs;
  final RxString address = ''.obs;
  final RxString subdistrict = ''.obs;
  final RxString district = ''.obs;
  final RxString city = ''.obs;
  final RxString postalCode = ''.obs;
  final RxString province = ''.obs;
  final RxString country = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString faxNumber = ''.obs;
  final RxString emailAddress = ''.obs;
  final RxString description = ''.obs;

  void updateField(String field, String value) {
    switch (field) {
      case 'codeName':
        codeName(value);
        break;
      case 'fullName':
        fullName(value);
        break;
      case 'address':
        address(value);
        break;
      case 'subdistrict':
        subdistrict(value);
        break;
      case 'district':
        district(value);
        break;
      case 'city':
        city(value);
        break;
      case 'postalCode':
        postalCode(value);
        break;
      case 'province':
        province(value);
        break;
      case 'country':
        country(value);
        break;
      case 'phoneNumber':
        phoneNumber(value);
        break;
      case 'faxNumber':
        faxNumber(value);
        break;
      case 'emailAddress':
        emailAddress(value);
        break;
      case 'description':
        description(value);
        break;
    }
  }

  Future<void> createOutlet() async {
    try {
      isLoading(true);
      errorMessage('');

      if (fullName.isEmpty) {
        throw 'Full name is required';
      }

      final outlet = Outlet(
        codeName: codeName.value,
        fullName: fullName.value,
        address: address.value,
        subdistrict: subdistrict.value,
        district: district.value,
        city: city.value,
        postalCode: postalCode.value,
        province: province.value,
        country: country.value,
        phoneNumber: phoneNumber.value,
        faxNumber: faxNumber.value,
        emailAddress: emailAddress.value,
        description: description.value,
      );

      await _databaseHelper.createOutlet(outlet);
      Get.snackbar('Success', 'Outlet created successfully');
      await const FlutterSecureStorage()
          .write(key: 'outlet_id', value: outlet.id.toString());
      Get.offAllNamed(Routes.home);
      clearForm();
    } catch (e) {
      errorMessage(e.toString());
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading(false);
    }
  }

  void clearForm() {
    codeName('');
    fullName('');
    address('');
    subdistrict('');
    district('');
    city('');
    postalCode('');
    province('');
    country('');
    phoneNumber('');
    faxNumber('');
    emailAddress('');
    description('');
  }
}
