/// Maps to backend Ride entity response.
class Ride {
  final int rideId;
  final String? driverEmail;
  final String pickupLocation;
  final String destination;
  final DateTime? requestedTime;
  final DateTime? startTime;
  final DateTime? endTime;
  final String status; // REQUESTED, POOL_FORMING, ACCEPTED, STARTED, COMPLETED, CANCELLED
  final List<RidePassenger> passengers;

  Ride({
    required this.rideId,
    this.driverEmail,
    required this.pickupLocation,
    required this.destination,
    this.requestedTime,
    this.startTime,
    this.endTime,
    required this.status,
    this.passengers = const [],
  });

  factory Ride.fromJson(Map<String, dynamic> json) {
    return Ride(
      rideId: json['rideId'] ?? json['id'] ?? 0,
      driverEmail: json['driverEmail'],
      pickupLocation: json['pickupLocation'] ?? '',
      destination: json['destination'] ?? '',
      requestedTime: json['requestedTime'] != null
          ? DateTime.tryParse(json['requestedTime'])
          : null,
      startTime: json['startTime'] != null
          ? DateTime.tryParse(json['startTime'])
          : null,
      endTime:
          json['endTime'] != null ? DateTime.tryParse(json['endTime']) : null,
      status: json['status'] ?? 'REQUESTED',
      passengers: (json['passengers'] as List<dynamic>?)
              ?.map((p) => RidePassenger.fromJson(p))
              .toList() ??
          [],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'REQUESTED':
        return 'Requested';
      case 'POOL_FORMING':
        return 'Forming pool';
      case 'ACCEPTED':
        return 'Accepted';
      case 'STARTED':
        return 'In progress';
      case 'COMPLETED':
        return 'Completed';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  bool get isActive =>
      status == 'REQUESTED' ||
      status == 'POOL_FORMING' ||
      status == 'ACCEPTED' ||
      status == 'STARTED';
}

/// A passenger within a ride.
class RidePassenger {
  final int? passengerId;
  final String? name;
  final String? phone;
  final String? pickupLocation;
  final String? dropLocation;
  final String status; // WAITING, PICKED_UP, DROPPED_OFF

  RidePassenger({
    this.passengerId,
    this.name,
    this.phone,
    this.pickupLocation,
    this.dropLocation,
    required this.status,
  });

  factory RidePassenger.fromJson(Map<String, dynamic> json) {
    return RidePassenger(
      passengerId: json['passengerId'] ?? json['id'],
      name: json['name'] ?? json['passengerName'],
      phone: json['phone'] ?? json['passengerPhone'],
      pickupLocation: json['pickupLocation'],
      dropLocation: json['dropLocation'],
      status: json['status'] ?? 'WAITING',
    );
  }
}
