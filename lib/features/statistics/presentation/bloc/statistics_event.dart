part of 'statistics_bloc.dart';

sealed class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

final class LoadStatisticsEvent extends StatisticsEvent {}

final class RefreshStatisticsEvent extends StatisticsEvent {}
