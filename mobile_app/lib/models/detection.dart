import 'dart:convert';

enum VehicleType { lmv, hmv, unknown }

VehicleType vehicleTypeFromString(String? value) {
  switch ((value ?? '').toLowerCase()) {
    case 'lmv':
      return VehicleType.lmv;
    case 'hmv':
      return VehicleType.hmv;
    default:
      return VehicleType.unknown;
  }
}

String vehicleTypeToString(VehicleType type) {
  switch (type) {
    case VehicleType.lmv:
      return 'LMV';
    case VehicleType.hmv:
      return 'HMV';
    case VehicleType.unknown:
      return 'UNKNOWN';
  }
}

class LocationInfo {
  final double? latitude;
  final double? longitude;
  final String? address;

  const LocationInfo({this.latitude, this.longitude, this.address});

  factory LocationInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const LocationInfo();
    return LocationInfo(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      address: json['address'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
      };
}

class DetectionResult {
  final String id;
  final VehicleType vehicleType;
  final String plateNumber;
  final double confidence;
  final LocationInfo location;
  final DateTime timestamp;
  final String? imageUrl;

  DetectionResult({
    required this.id,
    required this.vehicleType,
    required this.plateNumber,
    required this.confidence,
    required this.location,
    required this.timestamp,
    this.imageUrl,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    final String? id = json['id']?.toString();
    final String? vehicleTypeRaw = json['vehicle_type'] as String? ?? json['vehicleType'] as String?;
    final String? plateRaw = json['plate_number'] as String? ?? json['number_plate'] as String? ?? json['plateNumber'] as String?;
    final dynamic confRaw = json['confidence'];
    final double confidence = confRaw is num ? confRaw.toDouble() : double.tryParse('${confRaw ?? 0}') ?? 0.0;
    final location = LocationInfo.fromJson(json['location'] as Map<String, dynamic>?);
    final String? tsRaw = json['timestamp'] as String?;
    final DateTime timestamp = tsRaw != null ? DateTime.tryParse(tsRaw) ?? DateTime.now() : DateTime.now();
    final String? imageUrl = json['image_url'] as String? ?? json['imageUrl'] as String?;

    return DetectionResult(
      id: id ?? '${DateTime.now().millisecondsSinceEpoch}',
      vehicleType: vehicleTypeFromString(vehicleTypeRaw),
      plateNumber: plateRaw ?? 'UNKNOWN',
      confidence: confidence,
      location: location,
      timestamp: timestamp,
      imageUrl: imageUrl,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'vehicle_type': vehicleTypeToString(vehicleType),
        'plate_number': plateNumber,
        'confidence': confidence,
        'location': location.toJson(),
        'timestamp': timestamp.toIso8601String(),
        'image_url': imageUrl,
      };

  static String encodeList(List<DetectionResult> items) =>
      jsonEncode(items.map((e) => e.toJson()).toList());

  static List<DetectionResult> decodeList(String data) {
    final List<dynamic> raw = jsonDecode(data) as List<dynamic>;
    return raw.map((e) => DetectionResult.fromJson(e as Map<String, dynamic>)).toList();
  }
}
