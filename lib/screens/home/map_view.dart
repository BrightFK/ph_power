import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:ph_power/main.dart';
import 'package:ph_power/models/map_navigation.dart';
import 'package:ph_power/models/power_area.dart';
import 'package:ph_power/utils/helpers.dart';

class MapView extends StatefulWidget {
  final ValueNotifier<MapNavigation?> navigationNotifier;
  const MapView({super.key, required this.navigationNotifier});
  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  // --- STATE VARIABLES ---
  late final MapController _mapController;
  final _searchController = TextEditingController();

  List<PowerArea> _allAreas = [];
  List<PowerArea> _searchResults = [];

  LatLng? _currentUserLocation;
  StreamSubscription<Position>? _locationSubscription;
  bool _isFollowingUser = false;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
    _searchController.addListener(_onSearchChanged);
    widget.navigationNotifier.addListener(_onNavigate);
    _initializeMapAndLocation();
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _locationSubscription?.cancel();
    widget.navigationNotifier.removeListener(_onNavigate);
    super.dispose();
  }

  // --- LOGIC FUNCTIONS ---

  void _onNavigate() {
    final navigationData = widget.navigationNotifier.value;
    if (navigationData != null) {
      _mapController.move(navigationData.target, 15.0);
      widget.navigationNotifier.value = null; // Reset notifier
    }
  }

  Future<void> _initializeMapAndLocation() async {
    try {
      final initialPosition = await _determinePosition();
      if (mounted) {
        setState(() => _currentUserLocation =
            LatLng(initialPosition.latitude, initialPosition.longitude));
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, e.toString(), isError: true);
        setState(() => _currentUserLocation =
            const LatLng(4.8156, 7.0498)); // Fallback location
      }
    }
  }

  void _toggleFollowUser() {
    if (_isFollowingUser) {
      // Stop Following
      _locationSubscription?.cancel();
      if (mounted) {
        setState(() {
          _isFollowingUser = false;
          _locationSubscription = null;
        });
        showSnackBar(context, "Live location tracking stopped.");
      }
    } else {
      // Start Following
      _goToCurrentUserLocation(andStartFollowing: true);
    }
  }

  Future<void> _goToCurrentUserLocation(
      {bool andStartFollowing = false}) async {
    try {
      final position = await _determinePosition();
      final userLocation = LatLng(position.latitude, position.longitude);

      if (mounted) setState(() => _currentUserLocation = userLocation);
      _mapController.move(userLocation, 15.0);

      if (andStartFollowing && mounted) {
        const locationSettings = LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 10);
        _locationSubscription =
            Geolocator.getPositionStream(locationSettings: locationSettings)
                .listen((Position pos) {
          final newPos = LatLng(pos.latitude, pos.longitude);
          if (mounted) setState(() => _currentUserLocation = newPos);
          if (_isFollowingUser && mounted) {
            _mapController.move(newPos, _mapController.zoom);
          }
        });
        setState(() => _isFollowingUser = true);
        showSnackBar(context, "Live location tracking started.");
      }
    } catch (e) {
      if (mounted) showSnackBar(context, e.toString(), isError: true);
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return Future.error('Location services are disabled.');

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }

    return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(minutes: 1));
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _searchResults = query.isEmpty
          ? []
          : _allAreas
              .where((area) => area.name.toLowerCase().contains(query))
              .toList();
    });
  }

  Future<void> _reportStatus(String status) async {
    Position? position;
    try {
      position = await _determinePosition();
    } catch (e) {
      if (mounted) showSnackBar(context, e.toString(), isError: true);
      return;
    }

    if (position == null) {
      if (mounted) {
        showSnackBar(context, "Could not get your location.", isError: true);
      }
      return;
    }

    try {
      final userLocation = LatLng(position.latitude, position.longitude);

      if (_allAreas.isEmpty) {
        if (mounted) {
          showSnackBar(context, "Area data not ready. Please wait.",
              isError: true);
        }
        return;
      }

      PowerArea closestArea = _allAreas.first;
      double minDistance = double.maxFinite;
      const distance = Distance();
      for (var area in _allAreas) {
        final d = distance(userLocation, LatLng(area.latitude, area.longitude));
        if (d < minDistance) {
          minDistance = d;
          closestArea = area;
        }
      }

      await supabase.from('areas').update({
        'current_status': status,
        'updated_at': DateTime.now().toIso8601String(),
        'last_updated_by': supabase.auth.currentUser!.id,
      }).eq('id', closestArea.id);

      if (mounted) {
        showSnackBar(context, "Report for ${closestArea.name} submitted!");
      }
    } catch (e) {
      if (mounted) {
        showSnackBar(context, "Could not submit report to server.",
            isError: true);
      }
    }
  }

  // --- UI BUILDER ---

  @override
  Widget build(BuildContext context) {
    if (_currentUserLocation == null) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Getting your location..."),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: supabase.from('areas').stream(primaryKey: ['id']),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            _allAreas =
                snapshot.data!.map((map) => PowerArea.fromMap(map)).toList();
          }
          final areaMarkers = _allAreas
              .map((area) => Marker(
                  point: LatLng(area.latitude, area.longitude),
                  width: 80,
                  height: 100,
                  child:
                      _buildMapPin(area.name, _getColorForStatus(area.status))))
              .toList();

          return SafeArea(
            top: false,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentUserLocation!,
                    initialZoom: 14.0,
                    onPositionChanged: (position, hasGesture) {
                      if (hasGesture && _isFollowingUser) {
                        setState(() => _isFollowingUser = false);
                        _locationSubscription?.cancel();
                        _locationSubscription = null;
                        showSnackBar(
                            context, "Live location tracking stopped.");
                      }
                    },
                    onTap: (_, __) => FocusScope.of(context).unfocus(),
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      tileBuilder: (context, tileWidget, tile) => tile.loadError
                          ? Container(color: Colors.grey[300])
                          : tileWidget,
                    ),
                    MarkerLayer(markers: areaMarkers),
                    if (_currentUserLocation != null)
                      MarkerLayer(markers: [
                        Marker(
                            point: _currentUserLocation!,
                            width: 24,
                            height: 24,
                            child: _buildUserLocationMarker())
                      ]),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 15,
                  left: 15,
                  right: 15,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    _buildSearchBar(),
                    if (_searchController.text.isNotEmpty &&
                        _searchResults.isNotEmpty)
                      _buildSearchResultsList()
                  ]),
                ),
                Positioned(
                  bottom: 100,
                  right: 15,
                  child: Column(
                    children: [
                      _buildControlButton(
                          icon: Icons.add,
                          onPressed: () => _mapController.move(
                              _mapController.center, _mapController.zoom + 1)),
                      const SizedBox(height: 8),
                      _buildControlButton(
                          icon: Icons.remove,
                          onPressed: () => _mapController.move(
                              _mapController.center, _mapController.zoom - 1)),
                      const SizedBox(height: 16),
                      _buildControlButton(
                          icon: Icons.navigation_outlined,
                          onPressed: () => _mapController.rotate(0.0)),
                      const SizedBox(height: 8),
                      _buildControlButton(
                        icon: _isFollowingUser
                            ? Icons.gps_fixed
                            : Icons.my_location,
                        color: _isFollowingUser ? Colors.blueAccent : null,
                        onPressed: _toggleFollowUser,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
          onPressed: () => _showReportDialog(context),
          label: const Text('Report Status'),
          icon: const Icon(Icons.add_alert)),
    );
  }

  // --- UI HELPER WIDGETS ---

  Widget _buildSearchBar() {
    return Material(
      elevation: 4.0,
      borderRadius: BorderRadius.circular(30.0),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Search for an area...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(30.0),
              borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () => _searchController.clear())
              : null,
        ),
      ),
    );
  }

  Widget _buildSearchResultsList() {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      constraints: const BoxConstraints(maxHeight: 220),
      decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)]),
      child: ListView.builder(
        itemCount: _searchResults.length,
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final area = _searchResults[index];
          return ListTile(
            title: Text(area.name),
            onTap: () {
              _mapController.move(LatLng(area.latitude, area.longitude), 14.5);
              _searchController.clear();
              FocusScope.of(context).unfocus();
            },
          );
        },
      ),
    );
  }

  Widget _buildUserLocationMarker() => Container(
      decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 5)]));

  Widget _buildControlButton(
          {required IconData icon,
          required VoidCallback onPressed,
          Color? color}) =>
      Container(
        decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor.withOpacity(0.9),
            borderRadius: BorderRadius.circular(30),
            boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)]),
        child: IconButton(
            icon: Icon(icon, color: color ?? Theme.of(context).iconTheme.color),
            onPressed: onPressed),
      );

  Widget _buildMapPin(String title, Color color) => Column(children: [
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 75),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.black26,
                      blurRadius: 4,
                      offset: Offset(0, 2))
                ]),
            child: Text(title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    color: Colors.black87)),
          ),
        ),
        Icon(Icons.location_pin, color: color, size: 35),
      ]);

  Color _getColorForStatus(String status) {
    switch (status) {
      case 'ON':
        return Colors.green[600]!;
      case 'OFF':
        return Colors.red[700]!;
      default:
        return Colors.orange[600]!;
    }
  }

  void _showReportDialog(BuildContext context) => showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Report Power Status'),
          content: const Text('Is there power in your current location?'),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _getColorForStatus('OFF'),
                  foregroundColor: Colors.white),
              child: const Text('No Light'),
              onPressed: () {
                Navigator.of(context).pop();
                _reportStatus('OFF');
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: _getColorForStatus('ON')),
              child: const Text('I Have Light'),
              onPressed: () {
                Navigator.of(context).pop();
                _reportStatus('ON');
              },
            ),
          ],
        ),
      );
}
