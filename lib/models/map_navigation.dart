// lib/models/map_navigation.dart

import 'package:latlong2/latlong.dart';

// This is just a data container. It holds the coordinates we want to navigate to.
class MapNavigation {
  final LatLng target;

  MapNavigation({required this.target});
}
