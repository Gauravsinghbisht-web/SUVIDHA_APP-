
import 'package:flutter/foundation.dart';
import '../models/service_model.dart';
import '../services/service_service.dart';

class ServiceProvider extends ChangeNotifier {
  // =====================================================
  // SERVICE
  // =====================================================

  final ServiceService _serviceService =
      ServiceService();

  // =====================================================
  // VARIABLES
  // =====================================================

  List<ServiceModel> _services = [];

  // Worker profiles
  final Map<String, Map<String, dynamic>>
      _workerProfiles = {};

  bool _isLoading = false;

  String? _errorMessage;

  // =====================================================
  // GETTERS
  // =====================================================

  List<ServiceModel> get services =>
      _services;

  bool get isLoading =>
      _isLoading;

  String? get errorMessage =>
      _errorMessage;

  Map<String, dynamic>? getWorkerProfile(
    String workerId,
  ) {
    return _workerProfiles[workerId];
  }

  // =====================================================
  // GET ALL SERVICES
  // =====================================================

  Future<void> getAllServices() async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _services =
          await _serviceService
              .getAllServices();

      // Get worker profiles
      await _loadWorkerProfiles();
    } catch (e) {
      _services = [];

      _errorMessage =
          'Unable to load services.';

      debugPrint(
        'ServiceProvider Error: $e',
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  // =====================================================
  // SEARCH SERVICES
  // =====================================================

  Future<void> searchServices(
    String serviceType,
  ) async {
    final String query =
        serviceType.trim();

    // ---------------------------------------------------
    // Empty search
    // ---------------------------------------------------

    if (query.isEmpty) {
      _services = [];
      _workerProfiles.clear();
      _errorMessage = null;

      notifyListeners();

      return;
    }

    // ---------------------------------------------------
    // Loading
    // ---------------------------------------------------

    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // -------------------------------------------------
      // Search services
      // -------------------------------------------------

      _services =
          await _serviceService
              .searchServices(query);

      // -------------------------------------------------
      // Clear old worker profiles
      // -------------------------------------------------

      _workerProfiles.clear();

      // -------------------------------------------------
      // Get worker profiles
      // -------------------------------------------------

      await _loadWorkerProfiles();
    } catch (e) {
      _services = [];
      _workerProfiles.clear();

      _errorMessage =
          'Unable to search services.';

      debugPrint(
        'Search Service Error: $e',
      );
    }

    // ---------------------------------------------------
    // Stop loading
    // ---------------------------------------------------

    _isLoading = false;

    notifyListeners();
  }

  // =====================================================
  // LOAD WORKER PROFILES
  // =====================================================

  Future<void> _loadWorkerProfiles() async {
    for (final service in _services) {
      final String workerId =
          service.workerId;

      // Skip empty worker ID
      if (workerId.isEmpty) {
        continue;
      }

      // Don't load the same worker twice
      if (_workerProfiles
          .containsKey(workerId)) {
        continue;
      }

      try {
        final profile =
            await _serviceService
                .getWorkerProfile(
          workerId,
        );

        if (profile != null) {
          _workerProfiles[workerId] =
              profile;
        }
      } catch (e) {
        debugPrint(
          'Worker Profile Error: $e',
        );
      }
    }
  }

  // =====================================================
  // GET WORKER SERVICES
  // =====================================================

  Future<List<ServiceModel>>
      getWorkerServices(
    String workerId,
  ) async {
    try {
      return await _serviceService
          .getWorkerServices(
        workerId,
      );
    } catch (e) {
      debugPrint(
        'Worker Services Error: $e',
      );

      return [];
    }
  }

  // =====================================================
  // CLEAR SEARCH RESULTS
  // =====================================================

  void clearServices() {
    _services = [];

    _workerProfiles.clear();

    _errorMessage = null;

    notifyListeners();
  }
}
