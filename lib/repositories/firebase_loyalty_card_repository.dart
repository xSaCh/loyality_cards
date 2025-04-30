import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ext/models/loyalty_card.dart';
import 'package:ext/repositories/loyality_card_repository.dart';
import 'package:flutter/material.dart';

class FirebaseLoyaltyCardRepository implements LoyalityCardRepository {
  final CollectionReference _cardsCollection =
      FirebaseFirestore.instance.collection('loyalty_cards');

  @override
  Future<void> addCard(LoyaltyCard card) async {
    try {
      await _cardsCollection.doc(card.id).set(card.toJson());
    } catch (e) {
      print('Error adding card to Firestore: $e');
    }
  }

  @override
  Future<void> clearAllCards() async {
    try {
      final querySnapshot = await _cardsCollection.get();

      final batch = FirebaseFirestore.instance.batch();

      for (var doc in querySnapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
    } catch (e) {
      print('Error clearing all cards from Firestore: $e');
    }
  }

  @override
  Future<void> deleteCard(String id) async {
    try {
      await _cardsCollection.doc(id).delete();
    } catch (e) {
      print('Error deleting card from Firestore: $e');
    }
  }

  @override
  Future<List<LoyaltyCard>> getCards() async {
    try {
      final querySnapshot =
          await _cardsCollection.get(const GetOptions(source: Source.cache));

      if (querySnapshot.docs.isEmpty) {
        final serverSnapshot =
            await _cardsCollection.get(const GetOptions(source: Source.server));
        if (serverSnapshot.size == 0) return [];
        return serverSnapshot.docs
            .map((doc) =>
                LoyaltyCard.fromJson(doc.data() as Map<String, dynamic>))
            .toList();
      }
      debugPrint("FROM CACHE: ${querySnapshot.size}");
      return querySnapshot.docs
          .map(
              (doc) => LoyaltyCard.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting cards from Firestore: $e');
    }
    return [];
  }
}
