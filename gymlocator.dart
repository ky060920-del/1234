import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';


class GymLocatorPage extends StatefulWidget {
  const GymLocatorPage({super.key});

  @override
  State<GymLocatorPage> createState() => _GymLocatorPageState();
}

class _GymLocatorPageState extends State<GymLocatorPage> {
  GoogleMapController? _mapController;
  Position? _currentPosition;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  int _gymCount = 0; // Track gym count separately
  
  // Fixed current location (NTU area, Singapore)
  static const LatLng _fixedCurrentLocation = LatLng(1.3099152886322614, 103.77758465550208);
  
  // Default location (Singapore) - fallback
  static const LatLng _defaultLocation = LatLng(1.3521, 103.8198);

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    await _loadNearbyGyms(); // Load gyms first
    await _setFixedLocation(); // Set fixed location instead of getting actual GPS
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _setFixedLocation() async {
    // Create a mock Position object with the fixed coordinates
    setState(() {
      // We'll store the coordinates but won't create a full Position object
      // Instead, we'll just add the marker directly
    });

    // Add current location marker at the fixed position
    _markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: _fixedCurrentLocation,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ),
    );
  }

  // Keep the original method but don't call it automatically
  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
      });

      // Add current location marker
      _markers.add(
        Marker(
          markerId: const MarkerId('current_location'),
          position: LatLng(position.latitude, position.longitude),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: const InfoWindow(title: 'Your Location'),
        ),
      );
    } catch (e) {
      print('Error getting location: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadNearbyGyms() async {
    // ActiveSG gyms in Singapore
    final List<Map<String, dynamic>> gyms = [
      {
        'name': 'ActiveSG Gym @ Bishan',
        'lat': 1.3554,
        'lng': 103.8514,
        'address': 'Bishan Sports Hall, 5 Bishan Street 14',
      },
      {
        'name': 'ActiveSG Gym @ Bedok',
        'lat': 1.3269,
        'lng': 103.931,
        'address': 'Bedok Sports Hall, 3 Bedok North Street 1',
      },

      {
        'name': 'ActiveSG Gym @ Choa Chu Kang',
        'lat': 1.3907,
        'lng': 103.7471,
        'address': 'Choa Chu Kang Sports Hall, 1 Choa Chu Kang Street 53',
      },
      {
        'name': 'ActiveSG Gym @ Clementi',
        'lat': 1.311,
        'lng': 103.765,
        'address': 'Clementi Sports Hall, 10 Portsdown Road',
      },

      {
        'name': 'ActiveSG Gym @ Hougang',
        'lat': 1.3707,
        'lng': 103.8884,
        'address': 'Hougang Sports Hall, 93 Hougang Avenue 4',
      },
      {
        'name': 'ActiveSG Gym @ Jurong East',
        'lat': 1.3470,
        'lng': 103.7291,
        'address': 'Jurong East Sports Hall, 21 Jurong East Street 31',
      },

      {
        'name': 'ActiveSG Gym @ Jurong West',
        'lat': 1.3378,
        'lng': 103.6942,
        'address': 'Jurong West Sports Hall, 20 Jurong West Street 93',
      },


      {
        'name': 'ActiveSG Gym @ Kallang',
        'lat': 1.3226,
        'lng': 103.8725,
        'address': 'Kallang Tennis Centre, 52 Stadium Road',
      },
      {
        'name': 'ActiveSG Gym @ Pasir Ris',
        'lat': 1.3741,
        'lng': 103.9519,
        'address': 'Pasir Ris Sports Hall, 120 Pasir Ris Central',
      },

      {
        'name': 'ActiveSG Gym @ Serangoon',
        'lat': 1.3524,
        'lng': 103.8721,
        'address': 'Serangoon Sports Hall, 33 Serangoon North Avenue 3',
      },
      {
        'name': 'ActiveSG Gym @ Tampines',
        'lat': 1.3537,
        'lng': 103.9408,
        'address': 'Tampines Sports Hall, 1 Tampines Street 82',
      },
      {
        'name': 'ActiveSG Gym @ Toa Payoh',
        'lat': 1.3377,
        'lng': 103.8449,
        'address': 'Toa Payoh Sports Hall, 297 Lorong 6 Toa Payoh',
      },
      {
        'name': 'ActiveSG Gym @ Woodlands',
        'lat': 1.4346,
        'lng': 103.7796,
        'address': 'Woodlands Sports Hall, 4 Woodlands Street 13',
      },
      {
        'name': 'ActiveSG Gym @ Yio Chu Kang',
        'lat': 1.3815,
        'lng': 103.8444,
        'address': 'Yio Chu Kang Sports Hall, 100 Yio Chu Kang Road',
      },

      {
        'name': 'ActiveSG Gym @ Yishun',
        'lat': 1.4122,
        'lng': 103.8313,
        'address': 'Yishun Sports Hall, 1 Yishun Street 22',
      },

      {
        'name': 'ActiveSG Gym @ Bukit Merah',
        'lat': 1.2892,
        'lng': 103.8200,
        'address': 'Bukit Merah Sports Hall, 12 Jalan Bukit Merah',
      },
    ];

    setState(() {
      _gymCount = gyms.length; // Set gym count
    });

    for (var gym in gyms) {
      _markers.add(
        Marker(
          markerId: MarkerId(gym['name']),
          position: LatLng(gym['lat'], gym['lng']),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueViolet),
          infoWindow: InfoWindow(
            title: gym['name'],
            snippet: gym['address'],
          ),
          onTap: () => _showGymDetails(gym),
        ),
      );
    }
  }

  void _showGymDetails(Map<String, dynamic> gym) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 61, 44, 141),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color.fromARGB(255, 255, 140, 66).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.fitness_center,
                    color: Color.fromARGB(255, 255, 140, 66),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        gym['name'],
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        gym['address'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToGym(gym);
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Get Directions'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 255, 140, 66),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Calling ${gym['name']}...'),
                          backgroundColor: const Color.fromARGB(255, 255, 140, 66),
                        ),
                      );
                    },
                    icon: const Icon(Icons.phone),
                    label: const Text('Call'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToGym(Map<String, dynamic> gym) {
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(gym['lat'], gym['lng']),
          15,
        ),
      );
    }
  }

  void _goToCurrentLocation() {
    // Always go to the fixed location
    if (_mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          _fixedCurrentLocation,
          14,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          _isLoading
              ? Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color.fromARGB(255, 61, 44, 141),
                        Color.fromARGB(255, 88, 66, 184),
                        Color.fromARGB(255, 107, 79, 194),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
                )
              : GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _fixedCurrentLocation, // Use fixed location
                    zoom: 13,
                  ),
                  markers: _markers,
                  myLocationEnabled: false, // Disable default location marker
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  mapType: MapType.normal,
                  onMapCreated: (controller) {
                    _mapController = controller;
                  },
                ),

          // Header
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 15,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.fitness_center,
                                color: Color.fromARGB(255, 255, 140, 66),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                'ActiveSG Gyms ($_gymCount)',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Current Location Button
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(
                Icons.my_location,
                color: Color.fromARGB(255, 255, 140, 66),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}
