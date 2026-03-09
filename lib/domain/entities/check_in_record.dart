import 'package:equatable/equatable.dart';

class CheckInRecord extends Equatable {
  final String id;
  final String userId;
  final DateTime timestamp;

  const CheckInRecord({
    required this.id,
    required this.userId,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, userId, timestamp];
}
