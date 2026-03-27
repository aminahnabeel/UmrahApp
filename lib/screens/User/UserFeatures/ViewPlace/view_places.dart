import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
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

  LatLng _currentCenter = const LatLng(21.4225, 39.8262); 
  List<Marker> _markers = [];
  List<Polyline> _polylines = [];
  bool _showplaceList = false;
  List<String> _filteredplaces = [];

  @override
  void initState() {
    super.initState();
    _filteredplaces = places;
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

  // 1. Fixed Location Detection
  Future<void> _getCurrentLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    try {
      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> p = await placemarkFromCoordinates(position.latitude, position.longitude);
      setState(() {
        // Sirf locality set karein taake search engine confuse na ho
        _disfromController.text = p[0].locality ?? "Makkah";
        _currentCenter = LatLng(position.latitude, position.longitude);
      });
      _mapController.move(_currentCenter, 15);
    } catch (e) {
      setState(() => _disfromController.text = "Makkah");
    }
  }

  // 2. Powerful Search Logic
  Future<void> _searchAndDraw() async {
    if (_searchController.text.isEmpty || _disfromController.text.isEmpty) return;

    // Loading indicator
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Searching..."), duration: Duration(seconds: 1)));

    try {
      // Trick: Adding "Saudi Arabia" to make search accurate
      String fromQuery = "${_disfromController.text}, Saudi Arabia";
      String toQuery = "${_searchController.text}, Saudi Arabia";

      List<Location> startLocs = await locationFromAddress(fromQuery);
      List<Location> endLocs = await locationFromAddress(toQuery);

      if (startLocs.isNotEmpty && endLocs.isNotEmpty) {
        LatLng start = LatLng(startLocs[0].latitude, startLocs[0].longitude);
        LatLng end = LatLng(endLocs[0].latitude, endLocs[0].longitude);

        setState(() {
          _markers = [
            Marker(point: start, width: 50, height: 50, child: const Icon(Icons.location_on, color: Colors.blue, size: 40)),
            Marker(point: end, width: 50, height: 50, child: const Icon(Icons.location_on, color: Colors.red, size: 40)),
          ];
          _polylines = [
            Polyline(points: [start, end], color: Colors.blueAccent, strokeWidth: 5),
          ];
          _showplaceList = false;
        });
        _mapController.move(start, 13);
        _searchFocusNode.unfocus();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Location not found. Try 'Makkah' or 'Jeddah'")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: "View Places", showBackButton: true),
      body: Stack(
        children: [
          // ENGLISH PRIORITY MAP
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _currentCenter, initialZoom: 14),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
              ),
              PolylineLayer(polylines: _polylines),
              MarkerLayer(markers: _markers),
            ],
          ),

          // SEARCH BOXES
          Positioned(
            top: 15, left: 15, right: 15,
            child: Column(
              children: [
                _buildField(_disfromController, "From", Icons.my_location, _getCurrentLocation),
                const SizedBox(height: 10),
                _buildField(_searchController, "Destination", Icons.search, _searchAndDraw, node: _searchFocusNode),
                
                // SUGGESTIONS LIST (Selection Fix)
                if (_showplaceList)
                  Container(
                    margin: const EdgeInsets.only(top: 5),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _filteredplaces.length,
                      itemBuilder: (context, i) => ListTile(
                        leading: const Icon(Icons.place_outlined),
                        title: Text(_filteredplaces[i]),
                        onTap: () {
                          // Is part ko ghor se dekhein, yehi selection fix hai
                          String selectedValue = _filteredplaces[i];
                          setState(() {
                            _searchController.text = selectedValue;
                            _showplaceList = false;
                          });
                          _searchFocusNode.unfocus();
                          _searchAndDraw(); // Selection ke foran baad search
                        },
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

  Widget _buildField(TextEditingController ctrl, String hint, IconData icon, VoidCallback tap, {FocusNode? node}) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)]),
      child: TextField(
        controller: ctrl, focusNode: node,
        onSubmitted: (_) => _searchAndDraw(),
        decoration: InputDecoration(
          hintText: hint,
          prefixIcon: IconButton(icon: Icon(icon, color: const Color(0xFF1E3A8A)), onPressed: tap),
          suffixIcon: hint == "Destination" ? IconButton(icon: const Icon(Icons.directions, color: Color(0xFF1E3A8A)), onPressed: _searchAndDraw) : null,
          border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }
}