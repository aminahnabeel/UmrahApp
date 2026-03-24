import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_umrah_app/DataLayer/User/ViewPlaces/places.dart';

class ViewPlaceScreen extends StatefulWidget {
  const ViewPlaceScreen({super.key});

  @override
  State<ViewPlaceScreen> createState() => _ViewPlaceScreenState();
}

class _ViewPlaceScreenState extends State<ViewPlaceScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _disfromController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  LatLng locfrom = const LatLng(0.0, 0.0);
  LatLng locto = const LatLng(0.0, 0.0);
  Set<Polyline> polylines = {};
  List<Marker> markers = [];
  bool _showplaceList = false; // controls visibility of place list

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(34.1981687, 73.2325311),
    zoom: 13,
  );
  String? _selectedplace;
  List<String> _filteredplaces = [];

  @override
  void initState() {
    super.initState();

    markers = [
      const Marker(
        markerId: MarkerId('1'),
        position: LatLng(21.4225, 39.8262),
        infoWindow: InfoWindow(title: 'Initial Location'),
      ),
    ];

    _filteredplaces = places;

    _searchController.addListener(() {
      setState(() {
        _filteredplaces = places
            .where(
              (place) => place.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
            )
            .toList();
      });
    });

    _searchFocusNode.addListener(() {
      setState(() {
        _showplaceList = _searchFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _disfromController.dispose();
    super.dispose();
  }

  Future<void> getLatLong() async {
    if (_selectedplace == null) return;
    try {
      List<Location> locationFrom = await locationFromAddress(
        _disfromController.text,
      );
      List<Location> locationTo = await locationFromAddress(_selectedplace!);

      setState(() {
        locfrom = LatLng(locationFrom[0].latitude, locationFrom[0].longitude);
        locto = LatLng(locationTo[0].latitude, locationTo[0].longitude);

        markers = [
          Marker(
            markerId: const MarkerId('locationFrom'),
            position: locfrom,
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
          Marker(
            markerId: const MarkerId('locationTo'),
            position: locto,
            infoWindow: const InfoWindow(title: 'Place Location'),
          ),
        ];

        polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.blue,
            width: 4,
            points: [locfrom, locto],
          ),
        };

        _showplaceList = false; // hide place list when search is pressed
        _searchFocusNode.unfocus(); // hide keyboard
      });
    } catch (e) {
      print("Error: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Location not found")));
    }
  }

  Future<Position> _getCurrentLoc() async {
    await Geolocator.requestPermission().then((value) {}).onError((
      error,
      stackTrace,
    ) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("View Places"),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            onPressed: () {
              if (_disfromController.text.isNotEmpty &&
                  _selectedplace != null) {
                getLatLong();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter both locations")),
                );
              }
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController.complete(controller),
            initialCameraPosition: _kGooglePlex,
            polylines: polylines,
            markers: Set<Marker>.from(markers),
            myLocationEnabled: true,
          ),
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: TextField(
              controller: _disfromController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                hintText: "From",
                label: const Text("From"),
                prefixIcon: IconButton(
                  onPressed: () async {
                    _getCurrentLoc().then((currentloc) async {
                      List<Placemark> placemarks =
                          await placemarkFromCoordinates(
                            currentloc.latitude,
                            currentloc.longitude,
                          );
                      if (placemarks.isNotEmpty) {
                        Placemark place = placemarks[0];
                        setState(() {
                          _disfromController.text =
                              "${place.street}, ${place.locality}, ${place.country}";
                        });
                      }

                      markers.add(
                        Marker(
                          markerId: const MarkerId('currentLoc'),
                          position: LatLng(
                            currentloc.latitude,
                            currentloc.longitude,
                          ),
                          infoWindow: const InfoWindow(
                            title: "My current Location",
                          ),
                        ),
                      );

                      final GoogleMapController controller =
                          await _mapController.future;
                      controller.animateCamera(
                        CameraUpdate.newLatLngZoom(
                          LatLng(currentloc.latitude, currentloc.longitude),
                          13,
                        ),
                      );
                    });
                  },
                  icon: const Icon(Icons.location_on),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
              ),
            ),
          ),
          Positioned(
            top: 70,
            left: 10,
            right: 10,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Select a Place",
                    hintText: "Search place",
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                if (_showplaceList)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _filteredplaces.length,
                      itemBuilder: (context, index) {
                        return ListTile(
                          title: Text(_filteredplaces[index]),
                          onTap: () {
                            setState(() {
                              _selectedplace = _filteredplaces[index];
                              _searchController.text = _selectedplace!;
                              _filteredplaces = places;
                              _showplaceList = false; // hide after selection
                              _searchFocusNode.unfocus(); // hide keyboard
                            });
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
