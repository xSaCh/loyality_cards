import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:ext/global.dart';
import 'package:ext/models/loyalty_card.dart';
import 'package:ext/repositories/loyality_card_repository.dart';

part 'dashboard_event.dart';
part 'dashboard_state.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final LoyalityCardRepository _loyaltyCardRepository;

  DashboardBloc()
      : _loyaltyCardRepository = Global.instance.loyaltyCardRepository,
        super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<AddCard>(_onAddCard);
    on<DeleteCard>(_onDeleteCard);
    on<UpdateCardUsage>(_onUpdateCardUsage); // Register the new event handler
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final cards = await _loyaltyCardRepository.getCards();
      emit(DashboardLoaded(cards: cards));
    } catch (e) {
      emit(
          DashboardError(message: 'Failed to load dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onAddCard(AddCard event, Emitter<DashboardState> emit) async {
    final currentState = state;
    try {
      await _loyaltyCardRepository.addCard(event.card);
      // Optimistically update UI before reloading
      if (currentState is DashboardLoaded) {
        final updatedCards = List<LoyaltyCard>.from(currentState.cards)
          ..add(event.card);
        emit(DashboardLoaded(cards: updatedCards));
      } else {
        add(LoadDashboard()); // Reload if not already loaded
      }
    } catch (e) {
      emit(DashboardError(message: 'Failed to add card: ${e.toString()}'));
      // Revert to previous state on error if needed
      if (currentState is DashboardLoaded) {
        emit(DashboardLoaded(cards: currentState.cards));
      }
    }
  }

  Future<void> _onDeleteCard(
      DeleteCard event, Emitter<DashboardState> emit) async {
    final currentState = state;
    try {
      // Optimistically update UI
      if (currentState is DashboardLoaded) {
        final updatedCards = currentState.cards
            .where((card) => card.id != event.cardId)
            .toList();
        emit(DashboardLoaded(cards: updatedCards));
      }
      await _loyaltyCardRepository.deleteCard(event.cardId);
    } catch (e) {
      emit(DashboardError(message: 'Failed to delete card: ${e.toString()}'));
      // Revert to previous state on error
      if (currentState is DashboardLoaded) {
        emit(DashboardLoaded(cards: currentState.cards));
      }
    }
  }

  Future<void> _onUpdateCardUsage(
      UpdateCardUsage event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      try {
        // Find the card to update
        final cardIndex =
            currentState.cards.indexWhere((card) => card.id == event.cardId);
        if (cardIndex != -1) {
          final cardToUpdate = currentState.cards[cardIndex];
          final updatedCard = cardToUpdate.copyWith(isUsed: event.isUsed);

          // Optimistically update the state
          final updatedCards = List<LoyaltyCard>.from(currentState.cards);
          updatedCards[cardIndex] = updatedCard;
          emit(DashboardLoaded(cards: updatedCards));

          // Persist the change
          await _loyaltyCardRepository.updateCard(updatedCard);
        } else {
          emit(DashboardError(message: 'Card not found for update.'));
          emit(DashboardLoaded(
              cards: currentState.cards)); // Re-emit current state
        }
      } catch (e) {
        emit(DashboardError(
            message: 'Failed to update card usage: ${e.toString()}'));
        // Revert optimistic update on error
        emit(DashboardLoaded(cards: currentState.cards));
      }
    }
  }
}
