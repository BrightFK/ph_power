class PowerArea {
  final int id;
  final String name;
  final double latitude;
  final double longitude;
  final String status; // 'ON', 'OFF', or 'UNCERTAIN'
  final DateTime updatedAt;

  PowerArea({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.updatedAt,
  });

  // This factory constructor is key for converting Supabase data
  factory PowerArea.fromMap(Map<String, dynamic> map) {
    return PowerArea(
      id: map['id'],
      name: map['name'] ?? 'Unknown Area',
      latitude: map['latitude']?.toDouble() ?? 0.0,
      longitude: map['longitude']?.toDouble() ?? 0.0,
      status: map['current_status'] ?? 'UNCERTAIN',
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }
}
