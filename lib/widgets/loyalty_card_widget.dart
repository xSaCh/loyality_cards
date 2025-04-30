import 'package:flutter/material.dart';
import 'package:ext/models/loyalty_card.dart'; // Adjust import path

class LoyaltyCardWidget extends StatelessWidget {
  final LoyaltyCard card;

  const LoyaltyCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final bool isExpired = card.remainingDuration.isNegative;

    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Card(
        clipBehavior:
            Clip.antiAlias, // Ensures content respects card boundaries
        child: Stack(
          children: [
            // Background Image/Illustration
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: isExpired
                    ? const ColorFilter.mode(Colors.grey, BlendMode.saturation)
                    : const ColorFilter.mode(Colors.transparent, BlendMode.dst),
                child: Image.asset(
                  card.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: const Center(child: Icon(Icons.broken_image)),
                    );
                  },
                ),
              ),
            ),
            // Dark overlay for expired cards
            if (isExpired)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.5),
                ),
              ),
            // Gradient overlay for better text visibility (only if not expired)
            if (!isExpired)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.black.withOpacity(0.6),
                        Colors.transparent
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            // Content
            Positioned(
              bottom: 8.0,
              left: 8.0,
              right: 8.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Text(
                      card.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    card.remainingDurationFormatted,
                    style: TextStyle(
                      color: isExpired ? Colors.red[300] : Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
