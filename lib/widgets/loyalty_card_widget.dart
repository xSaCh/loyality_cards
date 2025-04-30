import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:ext/models/loyalty_card.dart';

class LoyaltyCardWidget extends StatelessWidget {
  final LoyaltyCard card;

  const LoyaltyCardWidget({super.key, required this.card});

  @override
  Widget build(BuildContext context) {
    final bool isExpired = card.expiryDate.isBefore(DateTime.now());
    final Color cardColor =
        isExpired ? Colors.grey.shade300 : Colors.blue.shade100;
    final Color textColor = isExpired ? Colors.grey.shade600 : Colors.black87;

    return Card(
      color: cardColor,
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween, 
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  
                  child: Text(
                    card.cardName, 
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                    overflow: TextOverflow.ellipsis, 
                  ),
                ),
                
                if (card.imagePath != null)
                  SizedBox(
                    width: 50, 
                    height: 50,
                    child: ClipRRect(
                      
                      borderRadius: BorderRadius.circular(4.0),
                      child: kIsWeb
                          ? Image.network(card.imagePath!,
                              fit: BoxFit.cover) 
                          : Image.file(File(card.imagePath!),
                              fit: BoxFit.cover), 
                    ),
                  )
                
                else 
                  Icon(Icons.credit_card,
                      size: 40, color: textColor.withOpacity(0.5)),
              ],
            ),
            const Spacer(), 
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (card.couponCode != null && card.couponCode!.isNotEmpty)
                  Text(
                    'Code: ${card.couponCode}',
                    style: TextStyle(fontSize: 12.0, color: textColor),
                  ),
                Text(
                  'Expires: ${card.expiryDate.toLocal().toString().split(' ')[0]}',
                  style: TextStyle(
                    fontSize: 12.0,
                    color: isExpired
                        ? Colors.red.shade700
                        : textColor.withOpacity(0.8),
                    fontWeight: isExpired ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
