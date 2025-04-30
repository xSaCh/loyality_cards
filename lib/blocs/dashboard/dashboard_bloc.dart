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
    on<UpdateCardUsage>(_onUpdateCardUsage);
    on<FilterCards>(_onFilterCards); // Register the filter event handler
  }

  List<LoyaltyCard> _filterCards(
      List<LoyaltyCard> cards, CardFilterType filter) {
    final now = DateTime.now();
    switch (filter) {
      case CardFilterType.used:
        return cards.where((card) => card.isUsed).toList();
      case CardFilterType.expired:
        return cards.where((card) => card.expiryDate.isBefore(now)).toList();
      case CardFilterType.active:
        return cards
            .where((card) => !card.isUsed && card.expiryDate.isAfter(now))
            .toList();
      case CardFilterType.all:
      default:
        return cards;
    }
  }

  Future<void> _onLoadDashboard(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(DashboardLoading());
    try {
      final allCards = await _loyaltyCardRepository.getCards();
      final filteredCards = _filterCards(allCards, CardFilterType.active);
      emit(DashboardLoaded(
          allCards: allCards,
          filteredCards: filteredCards,
          filter: CardFilterType.active));
    } catch (e) {
      emit(
          DashboardError(message: 'Failed to load dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onAddCard(AddCard event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      try {
        await _loyaltyCardRepository.addCard(event.card);
        final updatedAllCards = List<LoyaltyCard>.from(currentState.allCards)
          ..add(event.card);
        final updatedFilteredCards =
            _filterCards(updatedAllCards, currentState.currentFilter);
        emit(currentState.copyWith(
          allCards: updatedAllCards,
          filteredCards: updatedFilteredCards,
        ));
      } catch (e) {
        emit(DashboardError(
            message: 'Failed to add card: ${e.toString()}',
            filter: currentState.currentFilter));
        // Optionally revert, though BLoC usually handles state rollback implicitly if needed
      }
    } else {
      // If state is not loaded, adding a card might imply reloading
      add(LoadDashboard());
    }
  }

  Future<void> _onDeleteCard(
      DeleteCard event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      // Optimistically update UI
      final updatedAllCards = currentState.allCards
          .where((card) => card.id != event.cardId)
          .toList();
      final updatedFilteredCards =
          _filterCards(updatedAllCards, currentState.currentFilter);
      emit(currentState.copyWith(
        allCards: updatedAllCards,
        filteredCards: updatedFilteredCards,
      ));

      try {
        await _loyaltyCardRepository.deleteCard(event.cardId);
        // State is already updated optimistically
      } catch (e) {
        emit(DashboardError(
            message: 'Failed to delete card: ${e.toString()}',
            filter: currentState.currentFilter));
        // Revert optimistic update on error
        emit(currentState); // Re-emit previous loaded state
      }
    }
  }

  Future<void> _onUpdateCardUsage(
      UpdateCardUsage event, Emitter<DashboardState> emit) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      final cardIndex =
          currentState.allCards.indexWhere((card) => card.id == event.cardId);
      if (cardIndex != -1) {
        final cardToUpdate = currentState.allCards[cardIndex];
        final updatedCard = cardToUpdate.copyWith(isUsed: event.isUsed);

        // Optimistically update the state
        final updatedAllCards = List<LoyaltyCard>.from(currentState.allCards);
        updatedAllCards[cardIndex] = updatedCard;
        final updatedFilteredCards =
            _filterCards(updatedAllCards, currentState.currentFilter);
        emit(currentState.copyWith(
          allCards: updatedAllCards,
          filteredCards: updatedFilteredCards,
        ));

        try {
          // Persist the change
          await _loyaltyCardRepository.updateCard(updatedCard);
        } catch (e) {
          emit(DashboardError(
              message: 'Failed to update card usage: ${e.toString()}',
              filter: currentState.currentFilter));
          // Revert optimistic update on error
          emit(currentState); // Re-emit previous loaded state
        }
      } else {
        emit(DashboardError(
            message: 'Card not found for update.',
            filter: currentState.currentFilter));
      }
    }
  }

  void _onFilterCards(FilterCards event, Emitter<DashboardState> emit) {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      final filteredCards = _filterCards(currentState.allCards, event.filter);
      emit(currentState.copyWith(
          filteredCards: filteredCards, filter: event.filter));
    }
    // If state is not DashboardLoaded, filtering doesn't apply yet.
    // Could potentially store the filter request and apply it upon loading.
  }
}
