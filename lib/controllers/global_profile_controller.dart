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

  /// Public URL of the patient's profile photo, or null if not set.
  /// Computed from profileData so it stays in sync without manual wiring.
  String? get profilePhotoUrl {
    final data = profileData['data'];
    final patient = (data is Map) ? (data['patient'] ?? data) : null;
    if (patient is! Map) return null;
    final url = patient['profileImageUrl'] ?? patient['profile_image_url'];
    if (url is String && url.isNotEmpty) return url;
    return null;
  }

  /// Patch the cached profile with a new photo URL after a successful upload.
  /// Mutates both the patient sub-object and the legacy top-level field so
  /// any code path reading either will see the new value.
  void setProfilePhotoUrl(String url) {
    final current = Map<String, dynamic>.from(profileData);
    final data = current['data'];
    if (data is Map) {
      final dataCopy = Map<String, dynamic>.from(data);
      final patient = dataCopy['patient'];
      if (patient is Map) {
        final patientCopy = Map<String, dynamic>.from(patient);
        patientCopy['profileImageUrl'] = url;
        dataCopy['patient'] = patientCopy;
      } else {
        dataCopy['profileImageUrl'] = url;
      }
      current['data'] = dataCopy;
    }
    setProfileData(current);
  }

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

      final data = profile['data'];
      final patient = data?['patient'] ?? data;
      final patientId = patient?['id'];
      final bloodBankId = patient?['bloodbank_id'] ?? patient?['bloodBankId'] ?? patient?['bloodBank']?['id'];

      if (bloodBankId != null) {
        var bloodBank = await BloodBankService.fetchBloodBank(bloodBankId, token);
        // Fallback: use embedded bloodBank from profile
        if (bloodBank == null && patient?['bloodBank'] != null) {
          bloodBank = {'success': true, 'data': patient['bloodBank']};
        }
        if (bloodBank != null) {
          setBloodBankData(bloodBank);
        }
      }

      if (patientId != null && bloodBankId != null) {
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
}
