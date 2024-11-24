import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_order/src/utils/toast_utils.dart';

/// Retrieves the current geographical position of the device.
///
/// This function first requests permission to access the device's location.
/// If the permission is denied or permanently denied, a toast message is
/// shown and the function returns `null`. If permission is granted, it then
/// checks whether the location service is enabled. If not enabled, a toast
/// message is shown and the function returns `null`.
///
/// In the case where permission is granted and the location service is enabled,
/// it attempts to get the current position using the `Geolocator` package. If
/// successful, it returns the `Position` object representing the current
/// location. If an error occurs during this process, it catches the error,
/// displays a toast message with the error, and returns `null`.
///
/// - Returns: A `Future` that resolves to a `Position` object representing the
///   current location, or `null` if the operation fails.
Future<Position?> getCurrentLocation() async {
  PermissionStatus permission = await Permission.location.request();
  if (permission.isDenied || permission.isPermanentlyDenied) {
    await openAppSettings();
    showToast('Users refuse to access positions');
    return null;
  }

  if (permission.isGranted) {
    bool isServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isServiceEnabled) {
      showToast('Navigation service has not been enabled');
      return null;
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      return position;
    } catch (e) {
      showToast('Error when taking position: $e');
      return null;
    }
  }
  return null;
}

/// Retrieves the geographical coordinates of the current device location.
/// 
/// This function first calls the `getCurrentLocation` function to obtain the
/// current location of the device. If the location is successfully obtained,
/// it returns a `GeoPoint` object containing the latitude and longitude of
/// the location. If the location is null, it returns a `GeoPoint` object with
/// default coordinates (0, 0).
/// 
/// - Returns: A `Future` that resolves to a `GeoPoint` object representing the
///  current location coordinates, or (0, 0) if the operation fails.
/// 
Future<GeoPoint> getGeopointFromCurrentLocation() async {
  Position? position = await getCurrentLocation();
  if (position != null) {
    return GeoPoint(position.latitude, position.longitude);
  }
  return GeoPoint(0, 0);
}

/// Converts a given address into geographical coordinates (latitude and longitude).
///
/// This function utilizes geocoding to transform an address into a
/// `GeoPoint`, which contains the latitude and longitude of the first
/// location result. If the address cannot be geocoded, or an error
/// occurs, it returns a `GeoPoint` with default coordinates (0, 0).
///
/// - Parameter address: The address to be converted into coordinates.
/// - Returns: A `Future` that resolves to a `GeoPoint` representing the
///   coordinates of the address, or (0, 0) if the operation fails.
Future<GeoPoint> getGeopointFromAddress(String address) async {
  try {
    // Convert address to coordinates using geocoding
    List<Location> locations = await locationFromAddress(address);
    if (locations.isNotEmpty) {
      return GeoPoint(locations.first.latitude, locations.first.longitude);
    }
  } catch (e) {
    if (kDebugMode) {
      print("Geocoding error: $e");
    }
  }
  return GeoPoint(0, 0);
}

/// Converts geographical coordinates into a human-readable address.
///
/// This function performs reverse geocoding to transform a `GeoPoint`,
/// which contains latitude and longitude, into a string representing
/// the address. If the coordinates can be successfully geocoded, it
/// returns a formatted address string including street, administrative
/// area, and country. If an error occurs or no result is found, it
/// returns "Unknown Address".
///
/// - Parameter geopoint: The geographical point with latitude and longitude.
/// - Returns: A `Future` that resolves to a `String` representing the
///   address of the coordinates, or "Unknown Address" if the operation fails.
Future<String> getAddressFromGeopoint(GeoPoint geopoint) async {
  try {
    // Convert coordinates to address using reverse geocoding
    List<Placemark> placemarks =
        await placemarkFromCoordinates(geopoint.latitude, geopoint.longitude);
    if (placemarks.isNotEmpty) {
      return "${placemarks.first.street}, ${placemarks.first.administrativeArea}, ${placemarks.first.country}";
    }
  } catch (e) {
    if (kDebugMode) {
      print("Reverse geocoding error: $e");
    }
  }
  return "Unknown Address";
}

/// Retrieves the human-readable address of the current authenticated user's
/// location from Firestore.
///
/// This function first checks whether a user is currently authenticated.
/// If the user is authenticated, it retrieves the user's location from
/// Firestore, and then converts the location coordinates into a human-readable
/// address using reverse geocoding.
///
/// - Returns: A `Future` that resolves to a `String` representing the
///   address of the user's location, or an empty string if the user is not
///   authenticated.
Future<String> getUserLocationFromFirestore() {
  // get current authenticated user's location
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user = auth.currentUser;
  if (user != null) {
    FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get()
        .then((value) {
      return getAddressFromGeopoint(value['location']);
    });
  }
  return Future.value('');
}
