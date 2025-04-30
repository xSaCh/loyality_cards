import 'package:equatable/equatable.dart';

class LoyaltyCard extends Equatable {
  final String id;
  final String name;
  final String imageUrl; // Or path to SVG asset
  final DateTime expiryDate;

  const LoyaltyCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.expiryDate,
  });

  // Calculate remaining duration (example implementation)
  Duration get remainingDuration => expiryDate.difference(DateTime.now());

  // Format duration for display (example)
  String get remainingDurationFormatted {
    final duration = remainingDuration;
    if (duration.isNegative) {
      return 'Expired';
    }
    if (duration.inDays > 0) {
      return '${duration.inDays} days left';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} hours left';
    } else {
      return '${duration.inMinutes} minutes left';
    }
  }

  @override
  List<Object?> get props => [id, name, imageUrl, expiryDate];
}
