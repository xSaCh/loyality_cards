import 'package:ext/models/loyalty_card.dart';

class CodeHandler {
  LoyaltyCard? fromCode(String code) {
    if (code == "GETFROMENTRY") {
      return LoyaltyCard(
        id: "entry_card",
        cardName: "Entry Card",
        expiryDate: DateTime.now().add(Duration(days: 30)),
        couponCode: "ENTRY2023",
      );
    } else if (code == "GETFROMEXIT") {
      return null;
    } else {
      return null;
    }
  }
}
