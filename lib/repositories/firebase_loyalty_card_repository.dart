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
      rethrow; // Rethrow to allow Bloc to handle error
    }
  }

  @override
  Future<List<LoyaltyCard>> getCards() async {
    try {
      // Try cache first
      QuerySnapshot querySnapshot =
          await _cardsCollection.get(const GetOptions(source: Source.cache));

      // If cache is empty or stale (you might add more sophisticated staleness checks),
      // fetch from server.
      if (querySnapshot.docs.isEmpty) {
        debugPrint("Cache empty or stale, fetching from server...");
        querySnapshot =
            await _cardsCollection.get(const GetOptions(source: Source.server));
        if (querySnapshot.docs.isEmpty) return []; // No cards on server either
        debugPrint("Fetched from SERVER: ${querySnapshot.size}");
      } else {
        debugPrint("Fetched from CACHE: ${querySnapshot.size}");
      }

      return querySnapshot.docs
          .map(
              (doc) => LoyaltyCard.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting cards from Firestore: $e');
      rethrow; // Rethrow to allow Bloc to handle error
    }
  }

  @override
  Future<void> updateCard(LoyaltyCard card) async {
    try {
      await _cardsCollection.doc(card.id).update(card.toJson());
    } catch (e) {
      print('Error updating card in Firestore: $e');
      rethrow; // Rethrow to allow Bloc to handle error
    }
  }
}
