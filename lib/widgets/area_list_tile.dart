// lib/widgets/area_list_tile.dart

import 'package:flutter/material.dart';
import 'package:ph_power/models/power_area.dart';
import 'package:timeago/timeago.dart' as timeago;

class AreaListTile extends StatelessWidget {
  final PowerArea area;
  // This function will be provided by the AreaListView when the widget is created.
  final VoidCallback onTap;

  const AreaListTile({
    super.key,
    required this.area,
    required this.onTap, // It's required for the "tap to locate" feature
  });

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusText;

    // Determine color and text based on the status from the database
    switch (area.status) {
      case 'ON':
        statusColor = Colors.green[400]!;
        statusText = 'Power is ON';
        break;
      case 'OFF':
        statusColor = Colors.red[400]!;
        statusText = 'Power is OFF';
        break;
      default: // 'UNCERTAIN'
        statusColor = Colors.orange[400]!;
        statusText = 'Status uncertain';
        break;
    }

    return Card(
      // A slightly transparent card to fit the dark theme
      color: Colors.white.withOpacity(0.05),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          radius: 8,
        ),
        title: Text(
          area.name,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
          // Use the 'timeago' package for user-friendly timestamps
          '$statusText • Updated ${timeago.format(area.updatedAt)}',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 13,
          ),
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          size: 14,
          color: Colors.grey[600],
        ),
        // When the user taps this tile, it calls the onTap function that
        // was passed down from the AreaListView.
        onTap: onTap,
      ),
    );
  }
}
