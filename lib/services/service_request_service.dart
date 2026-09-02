
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_request_model.dart';

class ServiceRequestService {
  // =====================================================
  // FIRESTORE
  // =====================================================
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =====================================================
  // CREATE SERVICE REQUEST
  // =====================================================
  Future<void> createRequest(
    ServiceRequestModel request,
  ) async {
    try {
      await _firestore
          .collection('service_requests')
          .add(request.toMap());

      print('Service request created successfully.');
    } catch (e) {
      print('Create Service Request Error: $e');
      rethrow;
    }
  }

  // =====================================================
  // GET PENDING REQUESTS
  // =====================================================
  //
  // These requests are visible to workers.
  //
  // Example:
  //
  // status = pending
  // workerId = ''
  //
  // =====================================================
  Future<List<ServiceRequestModel>> getPendingRequests() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('service_requests')
          .where(
            'status',
            isEqualTo: 'pending',
          )
          .get();

      print(
        'Pending requests found: ${snapshot.docs.length}',
      );
      return snapshot.docs.map((doc) {
        return ServiceRequestModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print('Get Pending Requests Error: $e');
      rethrow;
    }
  }

  // =====================================================
  // GET REQUESTS FOR WORKER
  // =====================================================
  //
  // Gets requests already accepted by this worker.
  //
  // =====================================================
  Future<List<ServiceRequestModel>> getWorkerRequests(
    String workerId,
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('service_requests')
          .where(
            'workerId',
            isEqualTo: workerId,
          )
          .get();

      print(
        'Worker requests found: ${snapshot.docs.length}',
      );
      return snapshot.docs.map((doc) {
        return ServiceRequestModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print('Get Worker Requests Error: $e');
      rethrow;
    }
  }

  // =====================================================
  // GET REQUESTS FOR USER
  // =====================================================
  Future<List<ServiceRequestModel>> getUserRequests(
    String userId,
  ) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('service_requests')
          .where(
            'userId',
            isEqualTo: userId,
          )
          .get();

      print(
        'User requests found: ${snapshot.docs.length}',
      );
      return snapshot.docs.map((doc) {
        return ServiceRequestModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print('Get User Requests Error: $e');
      rethrow;
    }
  }

  // =====================================================
  // ACCEPT REQUEST
  // =====================================================
  //
  // When a worker accepts:
  //
  // status   = accepted
  // workerId = current worker UID
  //
  // =====================================================
  Future<void> acceptRequest({
    required String requestId,
    required String workerId,
  }) async {
    try {
      await _firestore
          .collection('service_requests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'workerId': workerId,
      });
      print(
        'Request accepted by worker: $workerId',
      );
    } catch (e) {
      print('Accept Request Error: $e');
      rethrow;
    }
  }

  // =====================================================
  // REJECT REQUEST
  // =====================================================
  Future<void> rejectRequest(
    String requestId,
  ) async {
    try {
      await _firestore
          .collection('service_requests')
          .doc(requestId)
          .update({
        'status': 'rejected',
      });
      print('Request rejected.');
    } catch (e) {
      print('Reject Request Error: $e');
      rethrow;
    }
  }

  // =====================================================
  // UPDATE REQUEST STATUS
  // =====================================================
  Future<void> updateRequestStatus(
    String requestId,
    String status,
  ) async {
    try {
      await _firestore
          .collection('service_requests')
          .doc(requestId)
          .update({
        'status': status,
      });
      print(
        'Request status updated to: $status',
      );
    } catch (e) {
      print(
        'Update Request Status Error: $e',
      );
      rethrow;
    }
  }
}

