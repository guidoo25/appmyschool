part of 'notifications_loaded_cubit.dart';


abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoaded extends NotificationsState {
  final String loginUrl;

  NotificationsLoaded({required this.loginUrl});
}

class NotificationsError extends NotificationsState {
  final String message;

  NotificationsError({required this.message});
}

  