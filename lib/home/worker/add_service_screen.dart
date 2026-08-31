
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AddServiceScreen extends StatefulWidget {
  const AddServiceScreen({
    super.key,
  });

  @override
  State<AddServiceScreen> createState() =>
      _AddServiceScreenState();
}

class _AddServiceScreenState
    extends State<AddServiceScreen> {

  // =====================================================
  // CONTROLLERS
  // =====================================================
  final experienceController =
      TextEditingController();

  final priceController =
      TextEditingController();

  final locationController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  // =====================================================
  // VARIABLES
  // =====================================================
  String? selectedService;
  bool isLoading = false;

  // =====================================================
  // SERVICES
  // =====================================================
  final List<String> services = [
    'Plumber',
    'Electrician',
    'Cleaner',
    'Carpenter',
  ];

  // =====================================================
  // DISPOSE
  // =====================================================
  @override
  void dispose() {
    experienceController.dispose();
    priceController.dispose();
    locationController.dispose();
    descriptionController.dispose();

    super.dispose();
  }

  // =====================================================
  // SAVE SERVICE
  // =====================================================
  Future<void> saveService() async {

    // ---------------------------------------------------
    // VALIDATION
    // ---------------------------------------------------
    if (selectedService == null ||
        experienceController.text.trim().isEmpty ||
        priceController.text.trim().isEmpty ||
        locationController.text.trim().isEmpty ||
        descriptionController.text.trim().isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please fill all fields.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // ---------------------------------------------------
    // GET CURRENT WORKER
    // ---------------------------------------------------
    final User? currentUser =
        FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login again.',
          ),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }
    setState(() {
      isLoading = true;
    });

    try {

      // -------------------------------------------------
      // SAVE TO FIRESTORE
      // -------------------------------------------------
      await FirebaseFirestore.instance
          .collection('services')
          .add({

        'workerId': currentUser.uid,
        'serviceType': selectedService,
        'experience': experienceController.text.trim(),
        'price': priceController.text.trim(),
        'location': locationController.text.trim(),
        'description': descriptionController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Service added successfully!',
          ),
          backgroundColor: Colors.green,
        ),
      );

      // -------------------------------------------------
      // CLEAR FORM
      // -------------------------------------------------

      setState(() {
        selectedService = null;
      });
      experienceController.clear();
      priceController.clear();
      locationController.clear();
      descriptionController.clear();

    } on FirebaseException catch (e) {

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Firestore error: ${e.message}',
          ),
          backgroundColor: Colors.red,
        ),
      );

    } catch (e) {

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong: $e',
          ),
          backgroundColor: Colors.red,
        ),
      );

    } finally {

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  // =====================================================
  // UI
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // =================================================
      // APP BAR
      // =================================================
      appBar: AppBar(
        title: const Text(
          'Add Your Service',
        ),
        centerTitle: true,
      ),

      // =================================================
      // BODY
      // =================================================
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [

            // =============================================
            // SERVICE TYPE
            // =============================================
            const Text(
              'Service Type',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: selectedService,
              decoration: InputDecoration(
                hintText:
                    'Select your service',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),

              items: services.map(
                (service) {
                  return DropdownMenuItem<String>(
                    value: service,
                    child: Text(service),
                  );
                },
              ).toList(),

              onChanged: (value) {
                setState(() {
                  selectedService = value;
                });
              },
            ),

            const SizedBox(height: 20),

            // =============================================
            // EXPERIENCE
            // =============================================
            const Text(
              'Experience',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),
            TextField(
              controller:
                  experienceController,
              keyboardType:
                  TextInputType.number,
              decoration: InputDecoration(
                hintText:
                    'Example: 5 years',
                prefixIcon: const Icon(
                  Icons.work_outline,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =============================================
            // PRICE
            // =============================================
            const Text(
              'Price',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),
            TextField(
              controller:
                  priceController,
              keyboardType:
                  TextInputType.number,
              decoration: InputDecoration(
                hintText:
                    'Example: 500',

                prefixIcon: const Icon(
                  Icons.currency_rupee,
                ),

                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =============================================
            // LOCATION
            // =============================================
            const Text(
              'Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),
            TextField(
              controller: locationController,
              decoration: InputDecoration(
                hintText: 'Example: Mohali',
                prefixIcon: const Icon(
                  Icons.location_on_outlined,
                ),

                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =============================================
            // DESCRIPTION
            // =============================================
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 8),
            TextField(
              controller:
                  descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Describe your service',
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =============================================
            // SAVE BUTTON
            // =============================================
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : saveService,
                child: isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )

                    : const Text('Save Service',
                        style: TextStyle(
                        fontSize: 17,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
