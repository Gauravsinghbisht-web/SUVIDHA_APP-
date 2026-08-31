
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/service_model.dart';

class ServiceService {
  // =====================================================
  // FIRESTORE
  // =====================================================

  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  // =====================================================
  // GET ALL SERVICES
  // =====================================================

  Future<List<ServiceModel>> getAllServices() async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('services')
              .get();

      print(
        'Total services found: ${snapshot.docs.length}',
      );

      return snapshot.docs.map((doc) {
        return ServiceModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print('Get Services Error: $e');
      rethrow;
    }
  }

  // =====================================================
  // SEARCH SERVICES
  // =====================================================

  Future<List<ServiceModel>> searchServices(
    String serviceType,
  ) async {
    try {
      final String searchText =
          serviceType.trim();

      print(
        'Searching service: "$searchText"',
      );

      if (searchText.isEmpty) {
        return [];
      }

      // ---------------------------------------------------
      // Search using exact serviceType
      // ---------------------------------------------------

      final QuerySnapshot snapshot =
          await _firestore
              .collection('services')
              .where(
                'serviceType',
                isEqualTo: searchText,
              )
              .get();

      print(
        'Services found: ${snapshot.docs.length}',
      );

      return snapshot.docs.map((doc) {
        final data =
            doc.data() as Map<String, dynamic>;

        print(
          'Found service document: ${doc.id}',
        );

        print(
          'Service type: ${data['serviceType']}',
        );

        print(
          'Worker ID: ${data['workerId']}',
        );

        return ServiceModel.fromMap(
          doc.id,
          data,
        );
      }).toList();
    } catch (e) {
      print(
        'Search Services Error: $e',
      );

      rethrow;
    }
  }

  // =====================================================
  // GET WORKER SERVICES
  // =====================================================

  Future<List<ServiceModel>> getWorkerServices(
    String workerId,
  ) async {
    try {
      final QuerySnapshot snapshot =
          await _firestore
              .collection('services')
              .where(
                'workerId',
                isEqualTo: workerId,
              )
              .get();

      print(
        'Worker services found: '
        '${snapshot.docs.length}',
      );

      return snapshot.docs.map((doc) {
        return ServiceModel.fromMap(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    } catch (e) {
      print(
        'Get Worker Services Error: $e',
      );

      rethrow;
    }
  }

  // =====================================================
  // GET WORKER PROFILE
  // =====================================================

  Future<Map<String, dynamic>?> getWorkerProfile(
    String workerId,
  ) async {
    try {
      print(
        'Getting worker profile: $workerId',
      );

      final DocumentSnapshot document =
          await _firestore
              .collection('users')
              .doc(workerId)
              .get();

      if (!document.exists) {
        print(
          'Worker profile not found: $workerId',
        );

        return null;
      }

      final data =
          document.data() as Map<String, dynamic>;

      print(
        'Worker profile found: ${data['name']}',
      );

      return data;
    } catch (e) {
      print(
        'Get Worker Profile Error: $e',
      );

      rethrow;
    }
  }
}
