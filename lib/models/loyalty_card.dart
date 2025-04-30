import 'dart:convert';

class LoyaltyCard {
  final String id; 
  final String cardName;
  final DateTime expiryDate;
  final String? couponCode;
  final String? imagePath; 

  LoyaltyCard({
    required this.id,
    required this.cardName,
    required this.expiryDate,
    this.couponCode,
    this.imagePath,
  });

  
  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as String,
      cardName: json['cardName'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      couponCode: json['couponCode'] as String?,
      imagePath: json['imagePath'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardName': cardName,
      'expiryDate': expiryDate.toIso8601String(),
      'couponCode': couponCode,
      'imagePath': imagePath,
    };
  }
}

final List<LoyaltyCard> mockLoyaltyCards = [
  LoyaltyCard(
    id: '1',
    cardName: 'Starbucks Rewards',
    expiryDate: DateTime(2025, 12, 31),
    couponCode: 'STAR2024',
    imagePath: 'lib/assets/images/coffee_card.png',
  ),
  LoyaltyCard(
    id: '2',
    cardName: 'Amazon Prime Rewards',
    expiryDate: DateTime(2025, 6, 30),
    couponCode: 'PRIME25',
    // imagePath: '/images/amazon_card.png',
  ),
  LoyaltyCard(
    id: '3',
    cardName: 'Costco Membership',
    expiryDate: DateTime(2025, 11, 15),
    couponCode: null,
    // imagePath: '/images/costco_card.png',
  ),
  LoyaltyCard(
    id: '4',
    cardName: 'Gym Membership',
    expiryDate: DateTime(2024, 3, 1),
    couponCode: 'GYM2024',
    // imagePath: '/images/gym_card.png',
  ),
];
