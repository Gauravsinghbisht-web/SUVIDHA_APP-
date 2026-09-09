
import 'package:geolocator/geolocator.dart';

class LocationService {
  // Get current device location
  Future<Position?> getCurrentLocation() async {
    // Check whether location service is enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    // Check permission
    LocationPermission permission = await Geolocator.checkPermission();

    // Ask for permission if not granted
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Permission still denied
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    // Get current position
    return await Geolocator.getCurrentPosition();
  }
}