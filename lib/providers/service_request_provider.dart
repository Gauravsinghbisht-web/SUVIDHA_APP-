
import 'package:flutter/foundation.dart';
import '../models/service_request_model.dart';
import '../services/service_request_service.dart';

class ServiceRequestProvider extends ChangeNotifier {
  // =====================================================
  // SERVICE
  // =====================================================

  final ServiceRequestService _requestService =
      ServiceRequestService();

  // =====================================================
  // VARIABLES
  // =====================================================

  List<ServiceRequestModel> _requests = [];

  bool _isLoading = false;

  String? _errorMessage;

  // =====================================================
  // GETTERS
  // =====================================================

  List<ServiceRequestModel> get requests => _requests;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  // =====================================================
  // CREATE SERVICE REQUEST
  // =====================================================

  Future<bool> createRequest({
    required String userId,
    required String workerId,
    required String serviceId,
    required String serviceType,
  }) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      // Create request object
      final ServiceRequestModel request =
          ServiceRequestModel(
        id: '',
        userId: userId,
        workerId: workerId,
        serviceId: serviceId,
        serviceType: serviceType,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // Save request to Firestore
      await _requestService.createRequest(
        request,
      );

      debugPrint(
        'Service request created successfully.',
      );

      _isLoading = false;

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'Create Service Request Error: $e',
      );

      _errorMessage =
          'Unable to send service request.';

      _isLoading = false;

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // GET REQUESTS FOR WORKER
  // =====================================================

  Future<void> getWorkerRequests(
    String workerId,
  ) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _requests =
          await _requestService.getWorkerRequests(
        workerId,
      );

      debugPrint(
        'Worker requests loaded: '
        '${_requests.length}',
      );
    } catch (e) {
      _requests = [];

      _errorMessage =
          'Unable to load service requests.';

      debugPrint(
        'Get Worker Requests Error: $e',
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  // =====================================================
  // GET REQUESTS FOR USER
  // =====================================================

  Future<void> getUserRequests(
    String userId,
  ) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    try {
      _requests =
          await _requestService.getUserRequests(
        userId,
      );

      debugPrint(
        'User requests loaded: '
        '${_requests.length}',
      );
    } catch (e) {
      _requests = [];

      _errorMessage =
          'Unable to load your service requests.';

      debugPrint(
        'Get User Requests Error: $e',
      );
    }

    _isLoading = false;

    notifyListeners();
  }

  // =====================================================
  // ACCEPT REQUEST
  // =====================================================

  Future<bool> acceptRequest(
    String requestId,
  ) async {
    try {
      await _requestService.updateRequestStatus(
        requestId,
        'accepted',
      );

      // Update local list
      final int index = _requests.indexWhere(
        (request) => request.id == requestId,
      );

      if (index != -1) {
        final oldRequest = _requests[index];

        _requests[index] =
            ServiceRequestModel(
          id: oldRequest.id,
          userId: oldRequest.userId,
          workerId: oldRequest.workerId,
          serviceId: oldRequest.serviceId,
          serviceType: oldRequest.serviceType,
          status: 'accepted',
          createdAt: oldRequest.createdAt,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'Accept Request Error: $e',
      );

      _errorMessage =
          'Unable to accept request.';

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // REJECT REQUEST
  // =====================================================

  Future<bool> rejectRequest(
    String requestId,
  ) async {
    try {
      await _requestService.updateRequestStatus(
        requestId,
        'rejected',
      );

      // Update local list
      final int index = _requests.indexWhere(
        (request) => request.id == requestId,
      );

      if (index != -1) {
        final oldRequest = _requests[index];

        _requests[index] =
            ServiceRequestModel(
          id: oldRequest.id,
          userId: oldRequest.userId,
          workerId: oldRequest.workerId,
          serviceId: oldRequest.serviceId,
          serviceType: oldRequest.serviceType,
          status: 'rejected',
          createdAt: oldRequest.createdAt,
        );
      }

      notifyListeners();

      return true;
    } catch (e) {
      debugPrint(
        'Reject Request Error: $e',
      );

      _errorMessage =
          'Unable to reject request.';

      notifyListeners();

      return false;
    }
  }

  // =====================================================
  // CLEAR REQUESTS
  // =====================================================

  void clearRequests() {
    _requests = [];

    _errorMessage = null;

    notifyListeners();
  }
}

