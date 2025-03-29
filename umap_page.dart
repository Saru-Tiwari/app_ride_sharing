import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import flutter_map package
import 'package:latlong2/latlong.dart'; // Import LatLng class from latlong2 package
import 'package:geocoding/geocoding.dart'; // Import geocoding package
import 'package:geolocator/geolocator.dart'; // Import geolocator package for live location tracking
import 'package:http/http.dart' as http; // Import http package for API requests
import 'dart:async';
import 'dart:convert';

class uMapPage extends StatefulWidget {
  const uMapPage({super.key});

  @override
  State<uMapPage> createState() => _MapPageState();
}

class _MapPageState extends State<uMapPage> {
  final LatLng _initialPosition = LatLng(28.21107, 83.98359);
  late LatLng _currentPosition;
  LatLng? _destinationPosition;
  LatLng? _selectedPosition;
  List<LatLng> _routePoints = [];

  String? _destinationPlaceName; // New variable to store the place name
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();
  final MapController _mapController = MapController();
  bool _isLoading = false;
  bool _isTracking = false;
  bool _isSelectingOnMap = false;
  late StreamSubscription<Position> _positionStream;

  @override
  void initState() {
    super.initState();
    _currentPosition = _initialPosition;
    _startLiveLocationUpdates();
    // Automatically center the map on the current location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mapController.move(_currentPosition, _mapController.zoom);
    });
  }

  @override
  void dispose() {
    _positionStream.cancel(); // Cancel the stream on dispose
    super.dispose();
  }

  // Function to track live location
  Future<void> _startLiveLocationUpdates() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled')),
      );
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    print("Geo Location Enabled in track");
    _positionStream =
        Geolocator.getPositionStream().listen((Position position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);

        if (_isTracking) {
          _mapController.move(_currentPosition, _mapController.zoom);
        }
      });
    });
  }

  // Function to fetch road-based route using OSRM
  Future<List<LatLng>> fetchRoute(LatLng start, LatLng end) async {
    final String url =
        'http://router.project-osrm.org/route/v1/driving/${start.longitude},${start.latitude};${end.longitude},${end.latitude}?overview=full&geometries=geojson';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> coordinates =
          data['routes'][0]['geometry']['coordinates'];
      return coordinates.map((coord) => LatLng(coord[1], coord[0])).toList();
    } else {
      throw Exception('Failed to load route');
    }
  }

  // Function to show distance and route
  void _showDistance() async {
    if (_destinationPosition != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Fetch the road-based route
        List<LatLng> route =
            await fetchRoute(_currentPosition, _destinationPosition!);

        // Update the route points
        setState(() {
          _routePoints = route;
          _selectedPosition = null; // Remove the selection marker
        });

        // Calculate the distance
        double distanceInMeters = Geolocator.distanceBetween(
          _currentPosition.latitude,
          _currentPosition.longitude,
          _destinationPosition!.latitude,
          _destinationPosition!.longitude,
        );

        // Show distance in a SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Distance: ${distanceInMeters.toStringAsFixed(2)} meters'),
          ),
        );

        // Update the 'To' field with the destination place name
        if (_destinationPlaceName != null) {
          _toController.text = _destinationPlaceName!;
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Failed to fetch route. Please try again.')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No destination set.')),
      );
    }
  }

  // Function to search a location and update the destination marker
  Future<void> _searchLocation() async {
    String searchQuery = _toController.text.trim();
    if (searchQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a destination')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(searchQuery);
      if (locations.isNotEmpty) {
        setState(() {
          _destinationPosition = LatLng(
            locations.first.latitude,
            locations.first.longitude,
          );
          _destinationPlaceName = searchQuery; // Store the place name
          _mapController.move(_destinationPosition!,
              _mapController.zoom); // Move map to destination
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not found. Try again.')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Function to set current location in 'From' field
  void _setCurrentLocation() {
    setState(() {
      _fromController.text =
          'Current Location: ${_currentPosition.latitude}, ${_currentPosition.longitude}';
    });
  }

  // Function to handle map selection for destination
  void _selectDestinationOnMap() {
    setState(() {
      _isSelectingOnMap = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tap on the map to select destination')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Live Location Tracker'),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
        ),
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40.0,
                        child: TextField(
                          controller: _fromController,
                          readOnly: true,
                          decoration: InputDecoration(
                            hintText: 'From',
                            border: const OutlineInputBorder(),
                            suffixIcon: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'Current Location') {
                                  _setCurrentLocation();
                                } else if (value == 'Select on Map') {
                                  // Logic to select a location on the map
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return {'Current Location', 'Select on Map'}
                                    .map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 40.0,
                        child: TextField(
                          controller: _toController,
                          decoration: InputDecoration(
                            hintText: 'To',
                            border: const OutlineInputBorder(),
                            suffixIcon: PopupMenuButton<String>(
                              onSelected: (value) {
                                if (value == 'Search Location') {
                                  _searchLocation();
                                } else if (value == 'Select on Map') {
                                  _selectDestinationOnMap();
                                }
                              },
                              itemBuilder: (BuildContext context) {
                                return {'Search Location', 'Select on Map'}
                                    .map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                              icon: _isLoading
                                  ? const CircularProgressIndicator()
                                  : const Icon(Icons.more_vert),
                            ),
                          ),
                          onSubmitted: (value) {
                            _searchLocation();
                            FocusScope.of(context)
                                .unfocus(); // Dismiss the keyboard
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    center: _initialPosition,
                    zoom: 12.0,
                    onTap: _isSelectingOnMap
                        ? (tapPosition, latLng) {
                            setState(() {
                              _selectedPosition = latLng;
                              _destinationPosition = latLng;
                              _isSelectingOnMap = false;
                            });
                          }
                        : null,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                    ),
                    MarkerLayer(
                      markers: [
                        // Live location marker
                        Marker(
                          width: 80.0,
                          height: 80.0,
                          point: _currentPosition,
                          builder: (ctx) => const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 30.0,
                          ),
                        ),
                        // Destination marker (if available)
                        if (_destinationPosition != null)
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: _destinationPosition!,
                            builder: (ctx) => const Icon(
                              Icons.location_on,
                              color: Colors.red,
                              size: 40.0,
                            ),
                          ),
                        // Selection marker (if available)
                        if (_selectedPosition != null)
                          Marker(
                            width: 50.0,
                            height: 50.0,
                            point: _selectedPosition!,
                            builder: (ctx) => const Icon(
                              Icons.location_pin,
                              color: Colors.green,
                              size: 40.0,
                            ),
                          ),
                      ],
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: _routePoints,
                          strokeWidth: 4.0,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 16.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    heroTag: "currentLocation",
                    backgroundColor: Colors.deepPurple,
                    onPressed: () {
                      _mapController.move(
                          _currentPosition, _mapController.zoom);
                    },
                    child: const Icon(Icons.my_location, color: Colors.white),
                  ),
                ),
                Positioned(
                  bottom: 80.0,
                  right: 16.0,
                  child: FloatingActionButton(
                    heroTag: "trackingToggle",
                    backgroundColor: Colors.deepPurple,
                    onPressed: () {
                      setState(() {
                        _isTracking = !_isTracking;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            _isTracking
                                ? 'Tracking Enabled'
                                : 'Tracking Disabled',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                // Positioned IconButton for distance
                Positioned(
                  bottom: 80.0,
                  right: 16.0,
                  child: Container(
                    padding: const EdgeInsets.all(2.0),
                    decoration: const BoxDecoration(
                      color: Colors.deepPurple,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.straighten,
                          color: Colors.white, size: 30),
                      onPressed: _showDistance,
                    ),
                  ),
                ),
                // Positioned Book Icon
                Positioned(
                  bottom: 16.0, // Adjust the position as needed
                  left: 16.0, // Add left positioning to align it properly
                  child: GestureDetector(
                    onTap: () {
                      if (_toController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Please enter a destination to book the ride.')),
                        );
                      } else {
                        print('The ride is booked');
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('The ride is booked')),
                        );
                      }
                    },
                    child: Container(
                      width: 100.0, // Set a fixed width
                      height: 40.0, // Set a fixed height
                      padding: const EdgeInsets.all(2.0),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(
                            20.0), // Set the radius for rounded edges
                        shape: BoxShape.rectangle,
                      ),
                      child: const Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment
                            .center, // Center the content vertically
                        children: [
                          Text(
                            'Book',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16), // Increase font size
                            textAlign: TextAlign.center, // Center the text
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
