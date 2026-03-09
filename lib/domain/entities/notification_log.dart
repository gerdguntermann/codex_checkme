import 'package:equatable/equatable.dart';

class NotificationLog extends Equatable {
  final String id;
  final String userId;
  final DateTime sentAt;
  final List<String> recipientEmails;

  const NotificationLog({
    required this.id,
    required this.userId,
    required this.sentAt,
    required this.recipientEmails,
  });

  @override
  List<Object?> get props => [id, userId, sentAt, recipientEmails];
}
