
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
  // ====================================================
  Future<bool> createRequest({
    required String userId,
    required String serviceId,
    required String serviceType, required String workerId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      // =================================================
      // CREATE REQUEST
      // =================================================
      //
      // workerId is empty because the request has not
      // been accepted by any worker yet.
      //
      // =================================================
      final ServiceRequestModel request =
          ServiceRequestModel(
        id: '',
        userId: userId,
        workerId: '',
        serviceId: serviceId,
        serviceType: serviceType,
        status: 'pending',
        createdAt: DateTime.now(),
      );

      // =================================================
      // SAVE TO FIRESTORE
      // =================================================
      await _requestService.createRequest(
        request,
      );
      debugPrint(
        'Service request created successfully.',
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } 
    catch (e) {
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
  // GET PENDING REQUESTS
  // =====================================================
  //
  // Used by workers to see available service requests.
  //
  // =====================================================
  Future<void> getPendingRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _requests =
          await _requestService.getPendingRequests();
      debugPrint(
        'Pending requests loaded: '
        '${_requests.length}',
      );
    } catch (e) {
      _requests = [];

      _errorMessage =
          'Unable to load available requests.';

      debugPrint(
        'Get Pending Requests Error: $e',
      );
    }

    _isLoading = false;
    notifyListeners();
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
          'Unable to load worker requests.';

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
  Future<bool> acceptRequest({
    required String requestId,
    required String workerId,
  }) async {
    try {
      // =================================================
      // UPDATE FIRESTORE
      // =================================================
      await _requestService.acceptRequest(
        requestId: requestId,
        workerId: workerId,
      );

      // =================================================
      // UPDATE LOCAL LIST
      // =================================================
      final int index = _requests.indexWhere(
        (request) => request.id == requestId,
      );

      if (index != -1) {
        final oldRequest = _requests[index];
        _requests[index] =
            oldRequest.copyWith(
          workerId: workerId,
          status: 'accepted',
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
      // =================================================
      // UPDATE FIRESTORE
      // =================================================
      await _requestService.rejectRequest(
        requestId,
      );

      // =================================================
      // UPDATE LOCAL LIST
      // ================================================
      final int index = _requests.indexWhere(
        (request) => request.id == requestId,
      );

      if (index != -1) {
        final oldRequest = _requests[index];
        _requests[index] =
            oldRequest.copyWith(
          status: 'rejected',
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
  // UPDATE REQUEST STATUS
  // =====================================================
  Future<bool> updateRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      await _requestService.updateRequestStatus(
        requestId,
        status,
      );
      final int index = _requests.indexWhere(
        (request) => request.id == requestId,
      );
      if (index != -1) {
        _requests[index] =
            _requests[index].copyWith(
          status: status,
        );
      }
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint(
        'Update Request Status Error: $e',
      );
      _errorMessage =
          'Unable to update request.';
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

