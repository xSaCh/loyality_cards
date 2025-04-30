class LoyaltyCard {
  final String id; 
  final String cardName;
  final DateTime expiryDate;
  final String? couponCode;
  final String? imagePath; 
  final bool isUsed; // Add isUsed field

  LoyaltyCard({
    required this.id,
    required this.cardName,
    required this.expiryDate,
    this.couponCode,
    this.imagePath,
    this.isUsed = false, // Default to false
  });

  
  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      id: json['id'] as String,
      cardName: json['cardName'] as String,
      expiryDate: DateTime.parse(json['expiryDate'] as String),
      couponCode: json['couponCode'] as String?,
      imagePath: json['imagePath'] as String?,
      isUsed: json['isUsed'] as bool? ?? false, // Handle potential null
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'cardName': cardName,
      'expiryDate': expiryDate.toIso8601String(),
      'couponCode': couponCode,
      'imagePath': imagePath,
      'isUsed': isUsed, // Add to JSON
    };
  }

  // Add copyWith method for easier state updates
  LoyaltyCard copyWith({
    String? id,
    String? cardName,
    DateTime? expiryDate,
    String? couponCode,
    String? imagePath,
    bool? isUsed,
  }) {
    return LoyaltyCard(
      id: id ?? this.id,
      cardName: cardName ?? this.cardName,
      expiryDate: expiryDate ?? this.expiryDate,
      couponCode: couponCode ?? this.couponCode,
      imagePath: imagePath ?? this.imagePath,
      isUsed: isUsed ?? this.isUsed,
    );
  }
}

final List<LoyaltyCard> mockLoyaltyCards = [
  LoyaltyCard(
    id: '1',
    cardName: 'Starbucks Rewards',
    expiryDate: DateTime(2025, 12, 31),
    couponCode: 'STAR2024',
    imagePath: 'lib/assets/images/coffee_card.png',
    isUsed: false,
  ),
  LoyaltyCard(
    id: '2',
    cardName: 'Amazon Prime Rewards',
    expiryDate: DateTime(2025, 6, 30),
    couponCode: 'PRIME25',
    // imagePath: '/images/amazon_card.png',
    isUsed: false,
  ),
  LoyaltyCard(
    id: '3',
    cardName: 'Costco Membership',
    expiryDate: DateTime(2025, 11, 15),
    couponCode: null,
    // imagePath: '/images/costco_card.png',
    isUsed: false,
  ),
  LoyaltyCard(
    id: '4',
    cardName: 'Gym Membership',
    expiryDate: DateTime(2024, 3, 1),
    couponCode: 'GYM2024',
    // imagePath: '/images/gym_card.png',
    isUsed: false,
  ),
];
