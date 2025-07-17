class LatLngModel{
  final double latitude;
  final double longitude;

  LatLngModel({
    required this.latitude,
    required this.longitude
  });

  factory LatLngModel.fromMap(Map<String, dynamic> data){
    return LatLngModel(
      latitude: (data['latitude'] ?? 0.0)?.toDouble(),
      longitude: (data['longitude'] ?? 0.0)?.toDouble()
    );
  }

  Map<String, dynamic> toMap()=> {
    'latitude' : latitude,
    'longitude':longitude
  };

}