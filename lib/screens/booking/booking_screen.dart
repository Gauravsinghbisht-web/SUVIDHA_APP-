
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/service_request_provider.dart';

class BookingScreen extends StatefulWidget {
  final String workerId;
  final String serviceId;
  final String serviceType;

  const BookingScreen({
    super.key,
    required this.workerId,
    required this.serviceId,
    required this.serviceType,
  });

  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  // =====================================================
  // CONTROLLERS
  // =====================================================

  final TextEditingController addressController =
      TextEditingController();

  final TextEditingController problemController =
      TextEditingController();

  // =====================================================
  // BOOKING DATA
  // =====================================================

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  bool _isBooking = false;

  // =====================================================
  // SELECT DATE
  // =====================================================

  Future<void> selectDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate =
        await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: now.add(
        const Duration(days: 90),
      ),
    );

    if (pickedDate != null) {
      setState(() {
        selectedDate = pickedDate;
      });
    }
  }

  // =====================================================
  // SELECT TIME
  // =====================================================

  Future<void> selectTime() async {
    final TimeOfDay? pickedTime =
        await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  // =====================================================
  // CONFIRM BOOKING
  // =====================================================

  Future<void> confirmBooking() async {
    // ===================================================
    // VALIDATE DATE
    // ===================================================

    if (selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a booking date',
          ),
        ),
      );

      return;
    }

    // ===================================================
    // VALIDATE TIME
    // ===================================================

    if (selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a booking time',
          ),
        ),
      );

      return;
    }

    // ===================================================
    // VALIDATE ADDRESS
    // ===================================================

    if (addressController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your address',
          ),
        ),
      );

      return;
    }

    // ===================================================
    // VALIDATE PROBLEM
    // ===================================================

    if (problemController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please describe your problem',
          ),
        ),
      );

      return;
    }

    // ===================================================
    // GET CURRENT USER
    // ===================================================

    final User? currentUser =
        FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please login first.',
          ),
        ),
      );

      return;
    }

    // ===================================================
    // CONVERT TIME TO STRING
    // ===================================================

    final String bookingTime =
        selectedTime!.format(context);

    // ===================================================
    // START LOADING
    // ===================================================

    setState(() {
      _isBooking = true;
    });

    try {
      // =================================================
      // GET PROVIDER
      // =================================================

      final ServiceRequestProvider provider =
          context.read<ServiceRequestProvider>();

      // =================================================
      // CREATE BOOKING
      // =================================================

      final bool success =
          await provider.createRequest(
        userId: currentUser.uid,
        workerId: widget.workerId,
        serviceId: widget.serviceId,
        serviceType: widget.serviceType,

        // BOOKING INFORMATION
        bookingDate: selectedDate!,
        bookingTime: bookingTime,
        address: addressController.text.trim(),
        problemDescription:
            problemController.text.trim(),
      );

      // =================================================
      // CHECK SCREEN
      // =================================================

      if (!mounted) {
        return;
      }

      // =================================================
      // SUCCESS
      // =================================================

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Booking created successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to Worker Profile
        Navigator.pop(context);
      }

      // =================================================
      // ERROR
      // =================================================

      else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.errorMessage ??
                  'Unable to create booking.',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      debugPrint(
        'Confirm Booking Error: $e',
      );

      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Something went wrong while creating booking.',
          ),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  // =====================================================
  // DISPOSE
  // =====================================================

  @override
  void dispose() {
    addressController.dispose();
    problemController.dispose();
    super.dispose();
  }

  // =====================================================
  // UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Book Service',
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // =================================================
            // SERVICE
            // =================================================

            Text(
              widget.serviceType,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            // =================================================
            // DATE
            // =================================================

            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: _isBooking
                  ? null
                  : selectDate,

              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Row(
                  children: [

                    const Icon(
                      Icons.calendar_today,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Text(
                      selectedDate == null
                          ? 'Select booking date'
                          : '${selectedDate!.day}/'
                              '${selectedDate!.month}/'
                              '${selectedDate!.year}',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // TIME
            // =================================================

            const Text(
              'Select Time',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            InkWell(
              onTap: _isBooking
                  ? null
                  : selectTime,

              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(16),

                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.grey,
                  ),

                  borderRadius:
                      BorderRadius.circular(10),
                ),

                child: Row(
                  children: [

                    const Icon(
                      Icons.access_time,
                    ),

                    const SizedBox(
                      width: 12,
                    ),

                    Text(
                      selectedTime == null
                          ? 'Select booking time'
                          : selectedTime!.format(
                              context,
                            ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // ADDRESS
            // =================================================

            const Text(
              'Service Address',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: addressController,
              maxLines: 3,
              enabled: !_isBooking,

              decoration: InputDecoration(
                hintText:
                    'Enter your service address',

                prefixIcon: const Icon(
                  Icons.location_on,
                ),

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // =================================================
            // PROBLEM DESCRIPTION
            // =================================================

            const Text(
              'Describe Your Problem',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: problemController,
              maxLines: 5,
              enabled: !_isBooking,

              decoration: InputDecoration(
                hintText:
                    'Example: Water leakage in kitchen',

                border:
                    OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // =================================================
            // CONFIRM BUTTON
            // =================================================

            SizedBox(
              width: double.infinity,
              height: 52,

              child: ElevatedButton(
                onPressed:
                    _isBooking
                        ? null
                        : confirmBooking,

                child: _isBooking
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Confirm Booking',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight:
                              FontWeight.bold,
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
