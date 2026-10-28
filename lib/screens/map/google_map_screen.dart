
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

  LatLng? _currentLocation;
  Set<Marker> _workerMarkers = {};

  bool _isLoading = true;
  String? _locationError;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // GET THE ACTUAL DEVICE LOCATION
  Future<void> _getCurrentLocation() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _locationError = null;
    });

    try {
      // 1. Check whether device location is enabled.
      final bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception(
          'Location is turned off. Please enable GPS in Settings.',
        );
      }

      // 2. Check and request location permission.
      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        throw Exception(
          'Location permission denied. Please allow location access.',
        );
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception(
          'Location permission is permanently denied. '
          'Enable it in Settings > Apps > Suvidha > Permissions.',
        );
      }

      // 3. Get a fresh GPS position, not a hardcoded location.
      final Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );

      final LatLng location = LatLng(
        position.latitude,
        position.longitude,
      );

      debugPrint('CURRENT GPS LATITUDE: ${position.latitude}');
      debugPrint('CURRENT GPS LONGITUDE: ${position.longitude}');

      if (!mounted) return;

      // 4. Update the map with the actual GPS coordinates.
      setState(() {
        _currentLocation = location;
        _isLoading = false;
      });

      // 5. Move the camera to the current location.
      await _moveCameraToLocation(location);

      // 6. Save the current user's coordinates.
      await _saveLocationToFirestore(position);

      // 7. Load nearby worker markers.
      await _getWorkers();
    } catch (e) {
      debugPrint('LOCATION ERROR: $e');

      if (!mounted) return;

      setState(() {
        _locationError = e.toString().replaceFirst(
          'Exception: ',
          '',
        );
        _isLoading = false;
      });
    }
  }

  // MOVE THE MAP CAMERA
  Future<void> _moveCameraToLocation(
    LatLng location,
  ) async {
    final controller = _mapController;

    if (controller == null) return;

    try {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: location,
            zoom: 16,
          ),
        ),
      );
    } catch (e) {
      debugPrint('CAMERA ERROR: $e');
    }
  }

  // SAVE USER LOCATION TO FIRESTORE
  Future<void> _saveLocationToFirestore(
    Position position,
  ) async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint('No logged-in user. Location not saved.');
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

      debugPrint('User location saved successfully.');
    } catch (e) {
      debugPrint('Could not save user location: $e');
    }
  }

  // LOAD WORKERS FROM FIRESTORE
  Future<void> _getWorkers() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('users')
              .where('role', isEqualTo: 'worker')
              .get();

      final Set<Marker> markers = {};

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final latitude = data['latitude'];
        final longitude = data['longitude'];

        if (latitude is! num || longitude is! num) {
          continue;
        }

        final double workerLatitude = latitude.toDouble();
        final double workerLongitude = longitude.toDouble();

        // Ignore invalid coordinates.
        if (workerLatitude < -90 ||
            workerLatitude > 90 ||
            workerLongitude < -180 ||
            workerLongitude > 180) {
          continue;
        }

        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(
              workerLatitude,
              workerLongitude,
            ),
            infoWindow: InfoWindow(
              title: (data['name'] ?? 'Worker').toString(),
              snippet: 'Worker',
            ),
          ),
        );
      }

      if (!mounted) return;

      setState(() {
        _workerMarkers = markers;
      });

      debugPrint('Workers found: ${markers.length}');
    } catch (e) {
      debugPrint('ERROR LOADING WORKERS: $e');
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Workers'),
        actions: [
          IconButton(
            tooltip: 'Refresh my location',
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Getting your current location...'),
                ],
              ),
            )
          : _locationError != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_off,
                          size: 56,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _locationError!,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: _getCurrentLocation,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Try Again'),
                        ),
                        TextButton(
                          onPressed:
                              Geolocator.openLocationSettings,
                          child: const Text(
                            'Open Location Settings',
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _currentLocation!,
                    zoom: 16,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  markers: _workerMarkers,
                  onMapCreated: (controller) {
                    _mapController = controller;

                    if (_currentLocation != null) {
                      _moveCameraToLocation(
                        _currentLocation!,
                      );
                    }
                  },
                ),
    );
  }
}
