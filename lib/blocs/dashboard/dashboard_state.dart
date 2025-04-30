part of 'dashboard_bloc.dart';

sealed class DashboardState extends Equatable {
  final CardFilterType currentFilter; // Add filter to base state

  const DashboardState(
      {this.currentFilter = CardFilterType.active}); // Default filter

  @override
  List<Object> get props => [currentFilter];
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardLoaded extends DashboardState {
  final List<LoyaltyCard> allCards; // Keep all cards
  final List<LoyaltyCard> filteredCards; // Add filtered cards list

  const DashboardLoaded({
    required this.allCards,
    required this.filteredCards,
    CardFilterType filter = CardFilterType.active, // Pass filter down
  }) : super(currentFilter: filter);

  @override
  List<Object> get props => [allCards, filteredCards, currentFilter];

  // Helper method to create a new state with updated filter/cards
  DashboardLoaded copyWith({
    List<LoyaltyCard>? allCards,
    List<LoyaltyCard>? filteredCards,
    CardFilterType? filter,
  }) {
    return DashboardLoaded(
      allCards: allCards ?? this.allCards,
      filteredCards: filteredCards ?? this.filteredCards,
      filter: filter ?? currentFilter,
    );
  }
}

final class DashboardError extends DashboardState {
  final String message;

  const DashboardError(
      {required this.message, CardFilterType filter = CardFilterType.active})
      : super(currentFilter: filter);

  @override
  List<Object> get props => [message, currentFilter];
}
