import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';

/// Tracks device connectivity app-wide so the UI can show a blocking
/// "no internet" screen whenever the device has no network path, and
/// automatically restore the app the moment connectivity returns.
class ConnectivityController extends GetxController {
  final isOnline = true.obs;
  final isChecking = false.obs;

  StreamSubscription<List<ConnectivityResult>>? _subscription;

  @override
  void onInit() {
    super.onInit();
    _subscription = Connectivity().onConnectivityChanged.listen(_applyResult);
    // ignore: discarded_futures
    _checkNow();
  }

  Future<void> _checkNow() async {
    try {
      final result = await Connectivity().checkConnectivity();
      _applyResult(result);
    } catch (_) {
      // If the platform check itself fails, don't block the whole app on it.
      isOnline.value = true;
    }
  }

  void _applyResult(List<ConnectivityResult> results) {
    isOnline.value = results.any((r) => r != ConnectivityResult.none);
  }

  /// Manual re-check for the "Try Again" button on the no-internet screen.
  Future<void> retry() async {
    isChecking.value = true;
    await _checkNow();
    isChecking.value = false;
  }

  @override
  void onClose() {
    _subscription?.cancel();
    super.onClose();
  }
}
