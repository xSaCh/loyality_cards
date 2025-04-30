import 'package:ext/models/loyalty_card.dart';

abstract class LoyalityCardRepository {
  Future<List<LoyaltyCard>> getCards();
  Future<void> addCard(LoyaltyCard card);
  Future<void> deleteCard(String id);
  Future<void> updateCard(LoyaltyCard card);
  Future<void> clearAllCards();
}
