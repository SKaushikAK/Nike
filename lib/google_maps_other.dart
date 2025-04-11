import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Map App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const MapScreen(),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  String _mapType = 'streets';
  final TextEditingController _searchController = TextEditingController();

  Future<void> _searchPlace(String place) async {
    try {
      List<Location> locations = await locationFromAddress(place);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);
        _mapController.move(latLng, 15.0);
        setState(() {
          _markers = [
            Marker(
              point: latLng,
              child: (
                  const Icon(Icons.location_on, color: Colors.red, size: 40)),
            ),
          ];
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Place not found")),
      );
    }
  }

  Future<void> _centerOnUser() async {
    Position position = await _determinePosition();
    LatLng latLng = LatLng(position.latitude, position.longitude);
    _mapController.move(latLng, 15.0);
  }

  void _changeMapType(String type) {
    setState(() {
      _mapType = type;
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse && permission != LocationPermission.always) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    final tileLayer = TileLayer(
      urlTemplate: _mapType == 'satellite'
          ? 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}'
          : 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'com.example.mapapp',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Map App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnUser,
          ),
          PopupMenuButton<String>(
            onSelected: _changeMapType,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'streets', child: Text('Normal')),
              const PopupMenuItem(value: 'satellite', child: Text('Satellite')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search location',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _searchPlace(_searchController.text),
                  child: const Icon(Icons.search),
                ),
              ],
            ),
          ),
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: const LatLng(13.0827, 80.2707), // Default location: Chennai
                initialZoom: 13.0,
              ),
              children: [
                tileLayer,
                MarkerLayer(markers: _markers),
                const CurrentLocationLayer(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
