import 'dart:async';

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

  final Map<String, Map<String, dynamic>>
      _workerProfiles = {};

  bool _isLoading = false;

  String? _errorMessage;

  StreamSubscription<List<ServiceModel>>?
      _servicesSubscription;

  StreamSubscription<Set<String>>?
      _workersSubscription;

  Set<String> _activeWorkerIds = {};


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

      await _loadWorkerProfiles();

      // Remove services whose workers
      // no longer exist.
      _filterDeletedWorkers();
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
  // SEARCH SERVICES - REAL TIME
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
      _stopRealtimeListeners();

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

    // ---------------------------------------------------
    // Stop old listeners
    // ---------------------------------------------------

    await _stopRealtimeListeners();

    _services = [];

    _workerProfiles.clear();

    // ---------------------------------------------------
    // Listen to SERVICES
    // ---------------------------------------------------

    _servicesSubscription =
        _serviceService
            .searchServicesStream(query)
            .listen(
      (services) async {
        _services = services;

        await _loadWorkerProfiles();

        _filterDeletedWorkers();

        _isLoading = false;

        notifyListeners();
      },
      onError: (error) {
        _services = [];

        _workerProfiles.clear();

        _isLoading = false;

        _errorMessage =
            'Unable to search services.';

        debugPrint(
          'Search Service Stream Error: $error',
        );

        notifyListeners();
      },
    );

    // ---------------------------------------------------
    // Listen to WORKERS
    // ---------------------------------------------------

    _workersSubscription =
        _serviceService
            .workerIdsStream()
            .listen(
      (workerIds) async {
        _activeWorkerIds = workerIds;

        // Worker was deleted from Firestore.
        _filterDeletedWorkers();

        // Reload worker profiles.
        await _loadWorkerProfiles();

        notifyListeners();
      },
      onError: (error) {
        debugPrint(
          'Worker Stream Error: $error',
        );
      },
    );
  }

  // =====================================================
  // REMOVE DELETED WORKERS
  // =====================================================

  void _filterDeletedWorkers() {
    if (_activeWorkerIds.isEmpty) {
      _services = [];
      _workerProfiles.clear();

      return;
    }

    _services = _services.where((service) {
      return _activeWorkerIds
          .contains(service.workerId);
    }).toList();

    _workerProfiles.removeWhere(
      (workerId, profile) {
        return !_activeWorkerIds
            .contains(workerId);
      },
    );
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

      // Skip if worker does not exist
      if (!_activeWorkerIds
          .contains(workerId)) {
        continue;
      }

      // Don't load same worker twice
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
    _stopRealtimeListeners();

    _services = [];

    _workerProfiles.clear();

    _errorMessage = null;

    _activeWorkerIds = {};


    notifyListeners();
  }

  // =====================================================
  // STOP REAL-TIME LISTENERS
  // =====================================================

  Future<void> _stopRealtimeListeners() async {
    await _servicesSubscription?.cancel();

    await _workersSubscription?.cancel();

    _servicesSubscription = null;

    _workersSubscription = null;
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    _servicesSubscription?.cancel();

    _workersSubscription?.cancel();

    super.dispose();
  }
}