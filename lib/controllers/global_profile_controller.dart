import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:rudhirakshapp/data/services/profile_service.dart';
import 'package:rudhirakshapp/data/services/bloodbank_service.dart';
import 'package:rudhirakshapp/data/services/transfusion_list_service.dart';
import 'package:rudhirakshapp/data/models/transfusion_list_model.dart';

class GlobalProfileController extends GetxController {
  // Rx variables
  var profileData = <String, dynamic>{}.obs;
  var bloodBankData = <String, dynamic>{}.obs;
  var transfusionList = Rx<TransfusionResponse?>(null);

  final box = GetStorage();

  // Setters profile with local storage
  void setProfileData(Map<String, dynamic> data) {
    profileData.value = data;
    box.write('profileData', data); // Save locally
  }

  // Setters blood bank with local storage
  void setBloodBankData(Map<String, dynamic> data) {
    bloodBankData.value = data;
    box.write('bloodBankData', data); // Save locally
  }

  // Setters transfusion list with local storage
  void setTransfusionList(TransfusionResponse data) {
    transfusionList.value = data;
    box.write('transfusionListData', data); // Save locally
  }

  // Init
  @override
  void onInit() {
    super.onInit();

    // Restore from local storage
    var savedProfile = box.read('profileData');
    var savedBloodBank = box.read('bloodBankData');
    var savedTransfusions = box.read('transfusionListData');
    // Load if available
    if (savedProfile != null) {
      profileData.value = Map<String, dynamic>.from(savedProfile);
    }
    if (savedBloodBank != null) {
      bloodBankData.value = Map<String, dynamic>.from(savedBloodBank);
    }
    if (savedTransfusions != null) {
      transfusionList.value = TransfusionResponse.fromJson(
        Map<String, dynamic>.from(savedTransfusions),
      );
    }
  }

  /// Optional: fresh fetch if token available
  Future<void> refreshProfile() async {
    final token = box.read('token');
    if (token == null) return;

    final profile = await ProfileService.fetchProfile(token);
    if (profile != null) {
      setProfileData(profile);

      final patientId = profile['data']['patient']['id'];
      final bloodBankId = profile['data']['patient']['bloodbank_id'];

      final bloodBank = await BloodBankService.fetchBloodBank(
        bloodBankId,
        token,
      );
      if (bloodBank != null) {
        setBloodBankData(bloodBank);
      }

      final transfusions = await TransfusionListService().fetchTransfusions(
        patientId: patientId,
        bloodbankId: bloodBankId,
      );
      if (transfusions != null) {
        setTransfusionList(transfusions);
      }
    }
  }
}
