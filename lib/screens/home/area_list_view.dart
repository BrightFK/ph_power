// lib/screens/home/area_list_view.dart

import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:ph_power/main.dart';
import 'package:ph_power/models/map_navigation.dart';
import 'package:ph_power/models/power_area.dart';
import 'package:ph_power/widgets/area_list_tile.dart';

class AreaListView extends StatefulWidget {
  final ValueChanged<MapNavigation> onAreaSelected;
  const AreaListView({super.key, required this.onAreaSelected});

  @override
  State<AreaListView> createState() => _AreaListViewState();
}

class _AreaListViewState extends State<AreaListView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      if (mounted) {
        setState(() => _searchQuery = _searchController.text.toLowerCase());
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Area Power Status')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for an area...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _searchController.clear())
                    : null,
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: supabase.from('areas').stream(
                  primaryKey: ['id']).order('updated_at', ascending: false),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allAreas = snapshot.data!
                    .map((map) => PowerArea.fromMap(map))
                    .toList();
                final filteredAreas = _searchQuery.isEmpty
                    ? allAreas
                    : allAreas
                        .where((area) =>
                            area.name.toLowerCase().contains(_searchQuery))
                        .toList();

                if (filteredAreas.isEmpty) {
                  return Center(
                    child: Text(_searchQuery.isEmpty
                        ? 'No areas found in database.'
                        : 'No results found for "$_searchQuery".'),
                  );
                }

                return ListView.builder(
                  itemCount: filteredAreas.length,
                  itemBuilder: (context, index) {
                    final area = filteredAreas[index];
                    return AreaListTile(
                      area: area,
                      onTap: () {
                        widget.onAreaSelected(MapNavigation(
                            target: LatLng(area.latitude, area.longitude)));
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
