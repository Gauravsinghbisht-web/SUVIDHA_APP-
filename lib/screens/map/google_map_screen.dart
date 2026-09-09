
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  GoogleMapController? _mapController;

  // Current user's location
  LatLng? _currentLocation;

  // Worker markers
  Set<Marker> _workerMarkers = {};

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _getCurrentLocation();
  }

  // =====================================================
  // GET CURRENT LOCATION
  // =====================================================

  Future<void> _getCurrentLocation() async {
    // Check whether location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please turn on your location service.'),
          ),
        );
      }

      return;
    }

    // Check location permission
    LocationPermission permission = await Geolocator.checkPermission();

    // Ask for permission if not already granted
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Permission denied
    if (permission == LocationPermission.denied) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location permission denied.'),
          ),
        );
      }

      return;
    }

    // Permission permanently denied
    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Location permission is permanently denied. '
              'Please enable it from Settings.',
            ),
          ),
        );
      }

      return;
    }

    // ===================================================
    // GET CURRENT GPS LOCATION
    // ===================================================
    Position position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    final LatLng location = LatLng(
      position.latitude,
      position.longitude,
    );

    // ===================================================
    // SAVE USER LOCATION
    // ===================================================
    await _saveLocationToFirestore(position);

    // ===================================================
    // GET WORKERS FROM FIRESTORE
    // ===================================================
    await _getWorkers();

    // ===================================================
    // UPDATE CURRENT LOCATION
    // ===================================================
    if (mounted) {
      setState(() {
        _currentLocation = location;
        _isLoading = false;
      });
    }

    // ===================================================
    // MOVE MAP TO CURRENT LOCATION
    // ===================================================
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 14,
          ),
        ),
      );
    }
  }

  // =====================================================
  // SAVE CURRENT USER LOCATION TO FIRESTORE
  // =====================================================
  Future<void> _saveLocationToFirestore(Position position) async {
    final User? user = FirebaseAuth.instance.currentUser;

    // Check if a user is logged in
    if (user == null) {
      print('No logged-in user found.');
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({
        'latitude': position.latitude,
        'longitude': position.longitude,
      });

      print('User location saved successfully!');
      print('Latitude: ${position.latitude}');
      print('Longitude: ${position.longitude}');
    } catch (e) {
      print('Error saving user location: $e');
    }
  }

  // =====================================================
  // GET WORKERS FROM FIRESTORE
  // =====================================================
  Future<void> _getWorkers() async {
    try {
      final QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'worker')
          .get();

      Set<Marker> markers = {};

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        // Get worker latitude
        final latitude = data['latitude'];

        // Get worker longitude
        final longitude = data['longitude'];

        // Get worker name
        final name = data['name'] ?? 'Worker';

        // Make sure latitude and longitude exist
        if (latitude == null || longitude == null) {
          continue;
        }

        final double workerLatitude =
            (latitude as num).toDouble();

        final double workerLongitude =
            (longitude as num).toDouble();

        // Create worker marker
        final Marker workerMarker = Marker(
          markerId: MarkerId(doc.id),
          position: LatLng(
            workerLatitude,
            workerLongitude,
          ),

          infoWindow: InfoWindow(
            title: name.toString(),
            snippet: 'Worker',
          ),
        );

        markers.add(workerMarker);
      }

      if (mounted) {
        setState(() {
          _workerMarkers = markers;
        });
      }

      print('Workers found: ${markers.length}');
    } catch (e) {
      print('Error getting workers: $e');
    }
  }

  // =====================================================
  // BUILD UI
  // =====================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Workers'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : GoogleMap(
              // ==========================================
              // INITIAL CAMERA POSITION
              // ==========================================
              initialCameraPosition: CameraPosition(
                target: _currentLocation ??
                    const LatLng(30.7046, 76.7179),
                zoom: 14,
              ),

              // ==========================================
              // CURRENT USER LOCATION
              // ==========================================
              myLocationEnabled: _currentLocation != null,

              myLocationButtonEnabled: true,

              zoomControlsEnabled: true,

              // ==========================================
              // WORKER MARKERS
              // ==========================================
              markers: _workerMarkers,

              // ==========================================
              // MAP CREATED
              // ==========================================
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller;

                if (_currentLocation != null) {
                  controller.animateCamera(
                    CameraUpdate.newCameraPosition(
                      CameraPosition(
                        target: _currentLocation!,
                        zoom: 14,
                      ),
                    ),
                  );
                }
              },
            ),
    );
  }
}
