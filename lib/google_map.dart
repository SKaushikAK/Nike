import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Google Maps App',
      home: GoogleMapScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GoogleMapScreen extends StatefulWidget {
  const GoogleMapScreen({super.key});

  @override
  State<GoogleMapScreen> createState() => _GoogleMapScreenState();
}

class _GoogleMapScreenState extends State<GoogleMapScreen> {
  final Completer<GoogleMapController> _controller = Completer();
  final Set<Marker> _markers = {};
  LatLng? _currentLocation;
  MapType _currentMapType = MapType.normal;

  // Search-related variables
  String _searchText = '';
  final List<String> _suggestions = [
    'New Delhi',
    'Mumbai',
    'Chennai',
    'Bangalore'
  ];
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(_currentLocation!, 15));
  }

  void _addMarker(LatLng pos) {
    final marker = Marker(
      markerId: MarkerId(pos.toString()),
      position: pos,
      infoWindow: const InfoWindow(title: "Pinned Location"),
    );
    setState(() => _markers.add(marker));
  }

  void _onMapTypeToggle() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
              ? MapType.hybrid
              : _currentMapType == MapType.hybrid
                  ? MapType.terrain
                  : MapType.normal;
    });
  }

  void _handleSearchSelection(String suggestion) async {
    Map<String, LatLng> places = {
      'New Delhi': LatLng(28.6139, 77.2090),
      'Mumbai': LatLng(19.0760, 72.8777),
      'Chennai': LatLng(13.0827, 80.2707),
      'Bangalore': LatLng(12.9716, 77.5946),
    };

    if (!places.containsKey(suggestion)) return;

    LatLng loc = places[suggestion]!;
    _addMarker(loc);

    final controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newLatLngZoom(loc, 14));

    setState(() {
      _searchText = '';
      _filteredSuggestions.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Google Maps App"),
        actions: [
          IconButton(
            icon: const Icon(Icons.layers),
            onPressed: _onMapTypeToggle,
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            mapType: _currentMapType,
            initialCameraPosition: const CameraPosition(
              target: LatLng(20.5937, 78.9629), // Default to India
              zoom: 5,
            ),
            onMapCreated: (controller) => _controller.complete(controller),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            markers: _markers,
            onLongPress: _addMarker,
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search location',
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchText = value;
                      _filteredSuggestions = _suggestions
                          .where((item) => item
                              .toLowerCase()
                              .contains(_searchText.toLowerCase()))
                          .toList();
                    });
                  },
                  onSubmitted: (value) {
                    _handleSearchSelection(value);
                  },
                ),
                if (_filteredSuggestions.isNotEmpty)
                  Container(
                    color: Colors.white,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredSuggestions.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_filteredSuggestions[index]),
                          onTap: () {
                            _handleSearchSelection(_filteredSuggestions[index]);
                          },
                        );
                      },
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
