part of 'dashboard_bloc.dart';

enum CardFilterType { all, used, expired, active }

sealed class DashboardEvent extends Equatable {
  const DashboardEvent();

  @override
  List<Object> get props => [];
}

class LoadDashboard extends DashboardEvent {}

class AddCard extends DashboardEvent {
  final LoyaltyCard card;

  const AddCard(this.card);

  @override
  List<Object> get props => [card];
}

class DeleteCard extends DashboardEvent {
  final String cardId;

  const DeleteCard(this.cardId);

  @override
  List<Object> get props => [cardId];
}

class UpdateCardUsage extends DashboardEvent {
  final String cardId;
  final bool isUsed;

  const UpdateCardUsage({required this.cardId, required this.isUsed});

  @override
  List<Object> get props => [cardId, isUsed];
}

class FilterCards extends DashboardEvent {
  final CardFilterType filter;

  const FilterCards(this.filter);

  @override
  List<Object> get props => [filter];
}
