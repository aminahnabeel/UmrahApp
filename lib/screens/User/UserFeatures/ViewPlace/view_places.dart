import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:smart_umrah_app/DataLayer/User/ViewPlaces/places.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart';

class ViewPlaceScreen extends StatefulWidget {
  const ViewPlaceScreen({super.key});

  @override
  State<ViewPlaceScreen> createState() => _ViewPlaceScreenState();
}

class _ViewPlaceScreenState extends State<ViewPlaceScreen> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _disfromController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final String _orsApiKey = "eyJvcmciOiI1YjNjZTM1OTc4NTExMTAwMDFjZjYyNDgiLCJpZCI6IjM4M2U5NTkzZjc0OTQyOTI5ODE5MWY1Mzc2MWNkODRmIiwiaCI6Im11cm11cjY0In0=";

  LatLng _currentCenter = const LatLng(21.4225, 39.8262);
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _showplaceList = false;
  List<String> _filteredplaces = [];
  bool _isLoading = false;
  String? _routeDistance;
  String? _routeDuration;

  @override
  void initState() {
    super.initState();
    _filteredplaces = places;
    _getCurrentLocation();

    _searchController.addListener(() {
      if (_searchFocusNode.hasFocus) {
        setState(() {
          _filteredplaces = places
              .where((p) => p.toLowerCase().contains(_searchController.text.toLowerCase()))
              .toList();
          _showplaceList = _filteredplaces.isNotEmpty;
        });
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        final position = await Geolocator.getCurrentPosition();
        final placemarks = await geo.placemarkFromCoordinates(position.latitude, position.longitude);

        setState(() {
          _currentCenter = LatLng(position.latitude, position.longitude);
          _disfromController.text =
              placemarks.isNotEmpty ? (placemarks.first.locality ?? 'Makkah') : 'Makkah';
        });

        _mapController.move(_currentCenter, 15);
      }
    } catch (e) {
      setState(() => _disfromController.text = 'Makkah');
    }
  }

  Future<LatLng?> _geocodeWithOrs(String query) async {
    final uri = Uri.https('api.openrouteservice.org', '/geocode/search', {
      'api_key': _orsApiKey,
      'text': query,
      'size': '1',
      'boundary.country': 'SAU',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) return null;

      final data = json.decode(response.body) as Map<String, dynamic>;
      final features = (data['features'] as List<dynamic>? ?? []);
      if (features.isEmpty) return null;

      final geometry = (features.first as Map<String, dynamic>)['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List<dynamic>?;
      if (coords == null || coords.length < 2) return null;

      return LatLng((coords[1] as num).toDouble(), (coords[0] as num).toDouble());
    } catch (_) {
      return null;
    }
  }

  Future<LatLng?> _geocodeAddress(String query) async {
    final orsResult = await _geocodeWithOrs(query);
    if (orsResult != null) return orsResult;

    try {
      final locs = await geo.locationFromAddress(query);
      if (locs.isEmpty) return null;
      return LatLng(locs.first.latitude, locs.first.longitude);
    } catch (_) {
      return null;
    }
  }

  Future<bool> _fetchDirections(LatLng start, LatLng end) async {
    final uri = Uri.https('api.openrouteservice.org', '/v2/directions/driving-car', {
      'api_key': _orsApiKey,
      'start': '${start.longitude},${start.latitude}',
      'end': '${end.longitude},${end.latitude}',
    });

    try {
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        return false;
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final features = (data['features'] as List<dynamic>? ?? []);
      if (features.isEmpty) return false;

      final feature = features.first as Map<String, dynamic>;
      final geometry = feature['geometry'] as Map<String, dynamic>?;
      final coords = geometry?['coordinates'] as List<dynamic>?;
      if (coords == null || coords.isEmpty) return false;

      final routePoints = coords
          .map((c) => LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
          .toList();

      final properties = feature['properties'] as Map<String, dynamic>?;
      final summary = properties?['summary'] as Map<String, dynamic>?;
      final distanceKm = ((summary?['distance'] as num?)?.toDouble() ?? 0) / 1000;
      final durationMin = ((summary?['duration'] as num?)?.toDouble() ?? 0) / 60;

      setState(() {
        _polylines = [
          Polyline(
            points: routePoints,
            color: const Color(0xFF1E3A8A),
            strokeWidth: 5,
          ),
        ];
        _routeDistance = '${distanceKm.toStringAsFixed(1)} km';
        _routeDuration = '${durationMin.toStringAsFixed(0)} min';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Route found: ${distanceKm.toStringAsFixed(1)} km, ${durationMin.toStringAsFixed(0)} min',
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _searchAndDraw() async {
    if (_searchController.text.trim().isEmpty || _disfromController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill both 'From' and 'Destination' fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final fromQuery = '${_disfromController.text}, Saudi Arabia';
      final toQuery = '${_searchController.text}, Saudi Arabia';

      final start = await _geocodeAddress(fromQuery);
      final end = await _geocodeAddress(toQuery);

      if (start == null || end == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location not found. Try a full name e.g. Al-Masjid al-Haram, Makkah'),
            ),
          );
        }
        return;
      }

      setState(() {
        _markers = [
          Marker(
            point: start,
            width: 44,
            height: 44,
            child: const Icon(Icons.my_location, color: Color(0xFF2563EB), size: 32),
          ),
          Marker(
            point: end,
            width: 44,
            height: 44,
            child: const Icon(Icons.location_on, color: Colors.red, size: 34),
          ),
        ];
        _polylines = [];
        _routeDistance = null;
        _routeDuration = null;
        _showplaceList = false;
      });

      final hasRoute = await _fetchDirections(start, end);
      final bounds = LatLngBounds.fromPoints([start, end]);
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(60),
        ),
      );

      if (!hasRoute && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pins added, route service unavailable currently.')),
        );
      }

      _searchFocusNode.unfocus();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not search this place. Please try a more specific name.')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'View Places', showBackButton: true),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.smart_umrah.app',
                retinaMode: RetinaMode.isHighDensity(context),
              ),
              PolylineLayer(polylines: _polylines),
              MarkerLayer(markers: _markers),
              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                    onTap: () {},
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Column(
              children: [
                _buildField(_disfromController, 'From', Icons.my_location, _getCurrentLocation),
                const SizedBox(height: 10),
                _buildField(
                  _searchController,
                  'Destination',
                  Icons.search,
                  _searchAndDraw,
                  node: _searchFocusNode,
                ),
                if (_showplaceList)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                    ),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _filteredplaces.length,
                      itemBuilder: (context, i) => ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(_filteredplaces[i]),
                        onTap: () {
                          setState(() {
                            _searchController.text = _filteredplaces[i];
                            _showplaceList = false;
                          });
                          _searchFocusNode.unfocus();
                          _searchAndDraw();
                        },
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (_routeDistance != null && _routeDuration != null)
            Positioned(
              bottom: 30,
              left: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Icon(
                          Icons.directions_car,
                          color: Color(0xFF1E3A8A),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _routeDistance ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const Text(
                          'Distance',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    Container(
                      width: 1,
                      height: 60,
                      color: Colors.grey,
                    ),
                    Column(
                      children: [
                        const Icon(
                          Icons.schedule,
                          color: Color(0xFF1E3A8A),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _routeDuration ?? '',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const Text(
                          'Duration',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String hint,
    IconData icon,
    Future<void> Function() onTap, {
    FocusNode? node,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),
      child: TextField(
        controller: ctrl,
        focusNode: node,
        onSubmitted: (_) => _searchAndDraw(),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: IconButton(
            icon: Icon(icon, color: const Color(0xFF1E3A8A)),
            onPressed: _isLoading ? null : () => onTap(),
          ),
          suffixIcon: hint == 'Destination'
              ? IconButton(
                  icon: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.directions, color: Color(0xFF1E3A8A)),
                  onPressed: _isLoading ? null : _searchAndDraw,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _disfromController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
