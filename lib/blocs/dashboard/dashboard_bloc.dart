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
    try {
      await _loyaltyCardRepository.addCard(event.card);
      add(LoadDashboard());
    } catch (e) {
      emit(DashboardError(message: 'Failed to add card: ${e.toString()}'));
      if (state is DashboardLoaded) {
        emit(DashboardLoaded(cards: (state as DashboardLoaded).cards));
      }
    }
  }

  Future<void> _onDeleteCard(
      DeleteCard event, Emitter<DashboardState> emit) async {
    try {
      await _loyaltyCardRepository.deleteCard(event.cardId);
      add(LoadDashboard());
    } catch (e) {
      emit(DashboardError(message: 'Failed to delete card: ${e.toString()}'));
      if (state is DashboardLoaded) {
        emit(DashboardLoaded(cards: (state as DashboardLoaded).cards));
      }
    }
  }
}
