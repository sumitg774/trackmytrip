import 'TriplogModel.dart';

class UserModel{
  final String name;
  final String email;
  final String empId;
  final String empRole;
  final String phone;
  final List<String> teams;
  final String team;
  final bool isDisabled;
  final bool isTripStarted;
  final Map<String, List<TriplogModel>> triplogs;

  UserModel({
    required this.name,
    required this.email,
    required this.empId,
    required this.empRole,
    required this.phone,
    required this.team,
    required this.teams,
    required this.isDisabled,
    required this.isTripStarted,
    required this.triplogs
  });

  factory UserModel.fromMap(Map<String, dynamic> data) {

    final triplogsRaw = data['triplogs'] ?? {};
    final parsedTriplogs = <String, List<TriplogModel>>{};

    triplogsRaw.forEach((date, list) {
      parsedTriplogs[date] = (list as List)
          .map((e) => TriplogModel.fromMap(e))
          .toList();
    });

    return UserModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      empId: data['emp_id'] ?? '',
      empRole: data['emp_role'] ?? '',
      phone: data['phone'] ?? '',
      team: data['team'] ?? '',
      teams: List<String>.from(data['teams'] ?? []),
      isDisabled: data['isDisabled'] ?? false,
      isTripStarted: data['is_trip_started'] ?? false,
      triplogs: parsedTriplogs
    );
  }

  Map<String, dynamic> toMap(){
    final tripLogs = <String, dynamic>{};
    triplogs.forEach((date, list){
      tripLogs[date] = list.map((e) => e.toMap()).toList();
    });

    return {
      'name': name,
      'email' : email,
      'empId' : empId,
      'empRole': empRole,
      'phone' : phone,
      'team' : team,
      'teams' : teams,
      'isDisabled': isDisabled,
      'isTripStarted':isTripStarted,
      'triplogs': tripLogs,
    };
  }

}

