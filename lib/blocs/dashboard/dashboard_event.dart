part of 'dashboard_bloc.dart';

abstract class DashboardEvent extends Equatable {
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
