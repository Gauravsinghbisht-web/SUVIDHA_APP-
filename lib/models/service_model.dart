
class ServiceModel {
  final String id;
  final String workerId;
  final String serviceType;
  final String experience;
  final String price;
  final String location;
  final String description;

  ServiceModel({
    required this.id,
    required this.workerId,
    required this.serviceType,
    required this.experience,
    required this.price,
    required this.location,
    required this.description,
  });

  // =====================================================
  // FROM FIRESTORE
  // =====================================================
  factory ServiceModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return ServiceModel(
      id: id,

      workerId: map['workerId']?.toString() ?? '',

      serviceType:
          map['serviceType']?.toString() ?? '',

      experience:
          map['experience']?.toString() ?? '',

      price:
          map['price']?.toString() ?? '',

      location:
          map['location']?.toString() ?? '',

      description:
          map['description']?.toString() ?? '',
    );
  }

  // =====================================================
  // TO FIRESTORE
  // =====================================================
  Map<String, dynamic> toMap() {
    return {
      'workerId': workerId,
      'serviceType': serviceType,
      'experience': experience,
      'price': price,
      'location': location,
      'description': description,
    };
  }
}

