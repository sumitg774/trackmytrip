import 'package:trip_tracker_app/Models/LatLongModel.dart';

class TriplogModel{
  final String tripId;
  final String arrive;
  final String depart;
  final String desc;
  final String distance;
  final String travelCost;
  final String vehicle;
  final String from;
  final String to;
  final LatLngModel start;
  final LatLngModel end;
  final List<LatLngModel> route;

  TriplogModel({
    required this.tripId,
    required this.arrive,
    required this.depart,
    required this.desc,
    required this.distance,
    required this.travelCost,
    required this.vehicle,
    required this.from,
    required this.to,
    required this.start,
    required this.end,
    required this.route
  });

  factory TriplogModel.fromMap(Map<String, dynamic> data){
    return TriplogModel(
      tripId: data['tripId'] ?? '',
      arrive: data['arrive'] ?? '~',
      depart: data['depart'] ?? '~',
      desc: data['desc'] ?? "~",
      distance: data['distance'] ?? '~',
      travelCost: data['travel_cost'] ?? '~',
      vehicle: data['vehicle'] ?? '',
      from: data['from'] ?? '',
      to: data['to'] ?? '',
      start: LatLngModel.fromMap(data['start'] ?? {}),
      end: LatLngModel.fromMap(data['end'] ?? {}),
      route: (data['route'] as List<dynamic>)
          .map((e) => LatLngModel.fromMap(e))
          .toList());
  }

  Map<String, dynamic> toMap(){
    return {
      'tripId' : tripId,
      'arrive' : arrive,
      'depart' : depart,
      'desc': desc,
      'distance' : distance,
      'travelCost' : travelCost,
      'vehicle' : vehicle,
      'from' : from,
      'to' : to,
      'start' : start.toMap(),
      'end' : end.toMap(),
      'route' : route.map((e)=>e.toMap()).toList(),
    };
  }
}