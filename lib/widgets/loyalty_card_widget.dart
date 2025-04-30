import 'dart:io';
import 'package:barcode_widget/barcode_widget.dart'; // Import barcode widget
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ext/models/loyalty_card.dart';

class LoyaltyCardWidget extends StatelessWidget {
  final LoyaltyCard card;
  final Function(LoyaltyCard, bool) onMarkUsed;

  const LoyaltyCardWidget({
    super.key,
    required this.card,
    required this.onMarkUsed,
  });

  @override
  Widget build(BuildContext context) {
    final bool isExpired = card.expiryDate.isBefore(DateTime.now());
    final Color cardColor = card.isUsed
        ? Colors.grey.shade500
        : isExpired
            ? Colors.grey.shade300
            : Colors.blue.shade100;
    final Color textColor = card.isUsed
        ? Colors.white70
        : isExpired
            ? Colors.grey.shade600
            : Colors.black87;
    final TextDecoration textDecoration =
        card.isUsed ? TextDecoration.lineThrough : TextDecoration.none;

    return InkWell(
      onTap: () => _showCardDetails(context),
      child: Card(
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
                        decoration: textDecoration, 
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (card.imagePath != null && !card.isUsed)
                    SizedBox(
                      width: 50,
                      height: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4.0),
                        child: kIsWeb
                            ? Image.network(card.imagePath!, fit: BoxFit.cover)
                            : Image.file(File(card.imagePath!),
                                fit: BoxFit.cover),
                      ),
                    )
                  else if (!card.isUsed)
                    Icon(Icons.credit_card,
                        size: 40, color: textColor.withOpacity(0.5)),
                  if (card.isUsed)
                    Icon(Icons.check_circle,
                        color: Colors.green.shade300, size: 40),
                ],
              ),
              const Spacer(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (card.couponCode != null && card.couponCode!.isNotEmpty)
                    Text(
                      'Code: ${card.couponCode}',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: textColor,
                        decoration: textDecoration,
                      ),
                    ),
                  Text(
                    'Expires: ${card.expiryDate.toLocal().toString().split(' ')[0]}',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: isExpired && !card.isUsed
                          ? Colors.red.shade700
                          : textColor.withOpacity(0.8),
                      fontWeight: isExpired && !card.isUsed
                          ? FontWeight.bold
                          : FontWeight.normal,
                      decoration: textDecoration,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCardDetails(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var isMarked = card.isUsed;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(card.cardName),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (card.couponCode != null && card.couponCode!.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: BarcodeWidget(
                          barcode: Barcode.code128(),
                          data: card.couponCode!,
                          width: 200,
                          height: 80,
                          drawText: true,
                        ),
                      )
                    else if (card.imagePath != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: kIsWeb
                            ? Image.network(card.imagePath!)
                            : Image.file(File(card.imagePath!)),
                      )
                    else
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Icon(Icons.image_not_supported,
                            size: 60, color: Colors.grey),
                      ),
                    CheckboxListTile(
                      title: const Text("Mark as Used"),
                      value: isMarked,
                      onChanged: (bool? newValue) {
                        if (newValue != null) {
                          debugPrint("ISMARKED: ${isMarked}");
                          setDialogState(() => isMarked = newValue);
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Close'),
                  onPressed: () {
                    onMarkUsed(card, isMarked);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
