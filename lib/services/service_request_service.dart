
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
  // GET REQUESTS FOR WORKER
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