import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ext/models/loyalty_card.dart'; // Adjust import path if needed

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  DashboardBloc() : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());
    try {
      // Simulate fetching data
      await Future.delayed(const Duration(seconds: 1));
      final cards = _getMockLoyaltyCards();
      emit(DashboardLoaded(cards: cards, totalCards: cards.length));
    } catch (e) {
      emit(
          DashboardError(message: 'Failed to load dashboard: ${e.toString()}'));
    }
  }

  // Replace with actual data fetching logic
  List<LoyaltyCard> _getMockLoyaltyCards() {
    return [
      LoyaltyCard(
        id: '1',
        name: 'Coffee Stamp Card',
        imageUrl: 'lib/assets/images/coffee_card.png', // Example asset path
        expiryDate: DateTime.now().add(const Duration(days: 30)),
      ),
      LoyaltyCard(
        id: '2',
        name: 'Grocery Points',
        imageUrl: 'lib/assets/images/grocery_card.png', // Example asset path
        expiryDate: DateTime.now().add(const Duration(days: 90)),
      ),
      LoyaltyCard(
        id: '3',
        name: 'Bookstore Discount',
        imageUrl: 'lib/assets/images/book_card.png', // Example asset path
        expiryDate: DateTime.now().add(const Duration(days: 15)),
      ),
      LoyaltyCard(
        id: '4',
        name: 'Expired Card',
        imageUrl: 'lib/assets/images/book_card.png', // Example asset path
        expiryDate: DateTime.now().subtract(const Duration(days: 5)),
      ),
      // Add more mock cards as needed
    ];
  }
}
