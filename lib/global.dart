import 'package:ext/repositories/loyality_card_repository.dart';
import 'package:ext/repositories/shared_pref_loyalty_card_repository.dart';

class Global {
  Global(this.loyaltyCardRepository);

  final LoyalityCardRepository loyaltyCardRepository;

  static Global? _ins;
  static Global get instance {
    return _ins!;
  }

  static void init(LoyalityCardRepository cardrepo) {
    _ins = Global(cardrepo);
  }
}
