
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
          .doc(request.id)
          .set(request.toMap());

      print(
        'Service request created successfully.',
      );
    } catch (e) {
      print(
        'Create Service Request Error: $e',
      );

      rethrow;
    }
  }
  
  // WORKER REQUESTS TO START THE JOB
  Future<void> requestStart({
    required String requestId,
    required String workerId,
  }) async {
    final ref = _firestore
        .collection('service_requests')
        .doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        throw Exception('Service request not found.');
      }

      final data = snapshot.data()!;

      if (data['workerId'] != workerId) {
        throw Exception('You are not assigned to this job.');
      }

      if (data['status'] != 'accepted') {
        throw Exception('Only accepted jobs can be started.');
      }

      if ((data['startRequestStatus'] ?? 'none') != 'none') {
        throw Exception('A start request already exists.');
      }

      transaction.update(ref, {
        'startRequestStatus': 'requested',
        'startRequestedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // USER CONFIRMS THE JOB START
  Future<void> confirmStart({
    required String requestId,
    required String userId,
  }) async {
    final ref = _firestore
        .collection('service_requests')
        .doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        throw Exception('Service request not found.');
      }

      final data = snapshot.data()!;

      if (data['userId'] != userId) {
        throw Exception('You cannot confirm this request.');
      }

      if (data['status'] != 'accepted') {
        throw Exception('This job is not ready to start.');
      }

      if (data['startRequestStatus'] != 'requested') {
        throw Exception('There is no pending start request.');
      }

      transaction.update(ref, {
        'startRequestStatus': 'confirmed',
        'status': 'started',
        'workStartedAt': FieldValue.serverTimestamp(),
      });
    });
  }


  // =====================================================
  // GET PENDING REQUESTS
  // =====================================================

  Future<List<ServiceRequestModel>>
      getPendingRequests() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('service_requests')
              .where(
                'status',
                isEqualTo: 'pending',
              )
              .get();

      print(
        'Pending requests found: '
        '${snapshot.docs.length}',
      );

      return snapshot.docs.map((doc) {
        return ServiceRequestModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print(
        'Get Pending Requests Error: $e',
      );

      rethrow;
    }
  }

  // =====================================================
  // GET REQUESTS FOR WORKER
  // =====================================================

  Future<List<ServiceRequestModel>>
      getWorkerRequests(
    String workerId,
  ) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('service_requests')
              .where(
                'workerId',
                isEqualTo: workerId,
              )
              .get();

      print(
        'Worker requests found: '
        '${snapshot.docs.length}',
      );

      return snapshot.docs.map((doc) {
        return ServiceRequestModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print(
        'Get Worker Requests Error: $e',
      );

      rethrow;
    }
  }

  // =====================================================
  // GET REQUESTS FOR USER
  // =====================================================

  Future<List<ServiceRequestModel>>
      getUserRequests(
    String userId,
  ) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('service_requests')
              .where(
                'userId',
                isEqualTo: userId,
              )
              .get();

      print(
        'User requests found: '
        '${snapshot.docs.length}',
      );

      return snapshot.docs.map((doc) {
        return ServiceRequestModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print(
        'Get User Requests Error: $e',
      );

      rethrow;
    }
  }

  // =====================================================
  // ACCEPT REQUEST
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
      print(
        'Accept Request Error: $e',
      );

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

      print(
        'Request rejected.',
      );
    } catch (e) {
      print(
        'Reject Request Error: $e',
      );

      rethrow;
    }
  }

    // WORKER REQUESTS JOB COMPLETION
Future<void> requestCompletion({
  required String requestId,
  required String workerId,
}) async {
  final ref = _firestore
      .collection('service_requests')
      .doc(requestId);

  await _firestore.runTransaction((transaction) async {
    final snapshot = await transaction.get(ref);

    if (!snapshot.exists) {
      throw Exception('Service request not found.');
    }

    final data = snapshot.data()!;

    if (data['workerId'] != workerId) {
      throw Exception('You are not assigned to this job.');
    }

    if (data['status'] != 'started') {
      throw Exception('Only started jobs can be completed.');
    }

    transaction.update(ref, {
      'status': 'completion_requested',
      'completionRequestedAt':
          FieldValue.serverTimestamp(),
    });
  });
}

 
  // USER CONFIRMS THAT THE JOB IS COMPLETED
  Future<void> confirmCompletion({
    required String requestId,
    required String userId,
  }) async {
    final ref = _firestore
        .collection('service_requests')
        .doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        throw Exception('Service request not found.');
      }

      final data = snapshot.data()!;

      if (data['userId'] != userId) {
        throw Exception('You cannot confirm this request.');
      }

      if (data['status'] != 'completion_requested') {
        throw Exception(
          'The worker has not requested job completion yet.',
        );
      }

      transaction.update(ref, {
        'status': 'completed',
        'completedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // SAVE A USER'S RATING AND REVIEW
  Future<void> submitWorkerReview({
    required String requestId,
    required String userId,
    required int rating,
    required String review,
  }) async {
    if (rating < 1 || rating > 5) {
      throw Exception('Rating must be between 1 and 5.');
    }

    final ref = _firestore
        .collection('service_requests')
        .doc(requestId);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);

      if (!snapshot.exists) {
        throw Exception('Service request not found.');
      }

      final data = snapshot.data()!;

      if (data['userId'] != userId) {
        throw Exception('You cannot review this request.');
      }

      if (data['status'] != 'completed') {
        throw Exception('Only completed jobs can be reviewed.');
      }

      if (data['rating'] != null) {
        throw Exception('You have already rated this job.');
      }

      transaction.update(ref, {
        'rating': rating,
        'review': review.trim(),
        'reviewedBy': userId,
        'reviewedAt': FieldValue.serverTimestamp(),
      });
    });
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
