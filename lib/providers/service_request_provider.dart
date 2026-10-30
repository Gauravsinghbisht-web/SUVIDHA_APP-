

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/service_request_model.dart';
import '../services/service_request_service.dart';

class ServiceRequestProvider extends ChangeNotifier {
  final ServiceRequestService _requestService =
      ServiceRequestService();

  List<ServiceRequestModel> _requests = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ServiceRequestModel> get requests => _requests;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  get error => null;

  // =====================================================
  // CREATE SERVICE REQUEST
  // =====================================================

  Future<bool> createRequest({
    required String userId,
    required String workerId,
    required String serviceId,
    required String serviceType,
    required DateTime bookingDate,
    required String bookingTime,
    required String address,
    required String problemDescription,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final String requestId = FirebaseFirestore.instance
          .collection('service_requests')
          .doc()
          .id;

      final ServiceRequestModel request =
          ServiceRequestModel(
        id: requestId,
        userId: userId,
        workerId: workerId,
        serviceId: serviceId,
        serviceType: serviceType,
        status: 'pending',
        createdAt: DateTime.now(),
        bookingDate: bookingDate,
        bookingTime: bookingTime,
        address: address,
        problemDescription: problemDescription,
      );

      
await _requestService.createRequest(request);

debugPrint('Service request created successfully.');

// Create an in-app notification for the worker.
// Notification failure must not cancel a successful booking.
try {
  await FirebaseFirestore.instance
      .collection('users')
      .doc(workerId)
      .collection('notifications')
      .add({
    'recipientId': workerId,
    'senderId': userId,
    'requestId': requestId,
    'title': 'New service request',
    'body': 'You received a new $serviceType request.',
    'type': 'new_request',
    'isRead': false,
    'createdAt': FieldValue.serverTimestamp(),
  });

  debugPrint('Worker notification created successfully.');
} catch (notificationError) {
  debugPrint(
    'Notification creation failed: $notificationError',
  );
}


      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Create Service Request Error: $e');

      _errorMessage = 'Unable to send service request.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // =====================================================
  // GET PENDING REQUESTS
  // =====================================================

  Future<void> getPendingRequests() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _requests = await _requestService.getPendingRequests();

      debugPrint(
        'Pending requests loaded: ${_requests.length}',
      );
    } catch (e) {
      _requests = [];
      _errorMessage = 'Unable to load available requests.';

      debugPrint('Get Pending Requests Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // =====================================================
  // GET REQUESTS FOR WORKER
  // =====================================================

  Future<void> getWorkerRequests(String workerId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _requests =
          await _requestService.getWorkerRequests(workerId);

      debugPrint(
        'Worker requests loaded: ${_requests.length}',
      );
    } catch (e) {
      _requests = [];
      _errorMessage = 'Unable to load worker requests.';

      debugPrint('Get Worker Requests Error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  // =====================================================
  // GET REQUESTS FOR USER
  // =====================================================

  Future<void> getUserRequests(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _requests =
          await _requestService.getUserRequests(userId);

      debugPrint(
        'User requests loaded: ${_requests.length}',
      );
    } catch (e) {
      _requests = [];
      _errorMessage = 'Unable to load your service requests.';

      debugPrint('Get User Requests Error: $e');
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
      await _requestService.acceptRequest(
        requestId: requestId,
        workerId: workerId,
      );

      final int index = _requests.indexWhere(
        (request) => request.id == requestId,
      );

      if (index != -1) {
        _requests[index] = _requests[index].copyWith(
          workerId: workerId,
          status: 'accepted',
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Accept Request Error: $e');

      _errorMessage = 'Unable to accept request.';
      notifyListeners();
      return false;
    }
  }

  // =====================================================
  // REJECT REQUEST
  // =====================================================

  Future<bool> rejectRequest(String requestId) async {
    try {
      await _requestService.rejectRequest(requestId);

      final int index = _requests.indexWhere(
        (request) => request.id == requestId,
      );

      if (index != -1) {
        _requests[index] = _requests[index].copyWith(
          status: 'rejected',
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Reject Request Error: $e');

      _errorMessage = 'Unable to reject request.';
      notifyListeners();
      return false;
    }
  }

  // it is a request for completion the job. 
  Future<bool> requestCompletion({
  required String requestId,
  required String workerId,
}) async {
  try {
    await _requestService.requestCompletion(
      requestId: requestId,
      workerId: workerId,
    );

    await getWorkerRequests(workerId);

    return true;
  } catch (e) {
    _errorMessage = e.toString();
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
        _requests[index] = _requests[index].copyWith(
          status: status,
        );
      }

      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Update Request Status Error: $e');

      _errorMessage = 'Unable to update request.';
      notifyListeners();
      return false;
    }
  }

  // =====================================================
  // WORKER REQUESTS TO START A JOB
  // =====================================================

  Future<bool> requestStart({
    required String requestId,
    required String workerId,
  }) async {
    try {
      await _requestService.requestStart(
        requestId: requestId,
        workerId: workerId,
      );

      final int index = _requests.indexWhere(
        (request) => request.id == requestId,
      );

      if (index != -1) {
        _requests[index] = _requests[index].copyWith(
          startRequestStatus: 'requested',
          startRequestedAt: DateTime.now(),
        );
      }

      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Request Start Error: $e');

      _errorMessage = 'Unable to request job start.';
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
