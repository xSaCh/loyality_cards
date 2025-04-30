import 'dart:convert';
import 'package:ext/repositories/loyality_card_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ext/models/loyalty_card.dart';
import 'package:uuid/uuid.dart';

class SharedPrefLoyaltyCardRepo implements LoyalityCardRepository {
  static const _cardsKey = 'loyalty_cards';
  final _uuid = Uuid();

  @override
  Future<List<LoyaltyCard>> getCards() async {
    final prefs = await SharedPreferences.getInstance();
    final cardsJson = prefs.getStringList(_cardsKey) ?? [];
    return cardsJson
        .map((cardJson) => LoyaltyCard.fromJson(jsonDecode(cardJson)))
        .toList();
  }

  @override
  Future<void> addCard(LoyaltyCard card) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await getCards();
    final cardWithId = LoyaltyCard(
        id: card.id.isEmpty ? _uuid.v4() : card.id,
        cardName: card.cardName,
        expiryDate: card.expiryDate,
        couponCode: card.couponCode,
        imagePath: card.imagePath);
    cards.add(cardWithId);
    final cardsJson = cards.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_cardsKey, cardsJson);
  }

  @override
  Future<void> deleteCard(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final cards = await getCards();
    cards.removeWhere((card) => card.id == id);
    final cardsJson = cards.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_cardsKey, cardsJson);
  }

  @override
  Future<void> clearAllCards() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_cardsKey);
  }
}
