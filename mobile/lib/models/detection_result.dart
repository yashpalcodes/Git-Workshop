class DetectionResult {
  final String vehicleType; // LMV or HMV
  final String numberPlate;
  final double confidence;
  final String location; // simple string for MVP
  final DateTime timestamp;
  final String? imageUrl;

  DetectionResult({
    required this.vehicleType,
    required this.numberPlate,
    required this.confidence,
    required this.location,
    required this.timestamp,
    this.imageUrl,
  });

  factory DetectionResult.fromJson(Map<String, dynamic> json) {
    return DetectionResult(
      vehicleType: json['vehicle_type'] ?? json['vehicleType'] ?? 'Unknown',
      numberPlate: json['number_plate'] ?? json['numberPlate'] ?? 'N/A',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      location: json['location'] ?? 'Unknown',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      imageUrl: json['image_url'] ?? json['imageUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
        'vehicle_type': vehicleType,
        'number_plate': numberPlate,
        'confidence': confidence,
        'location': location,
        'timestamp': timestamp.toIso8601String(),
        if (imageUrl != null) 'image_url': imageUrl,
      };
}
