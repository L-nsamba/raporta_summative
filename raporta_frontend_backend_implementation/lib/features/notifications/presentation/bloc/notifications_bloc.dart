import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/watch_notifications.dart';
import '../../domain/usecases/mark_notification_read.dart';

import 'notifications_event.dart';
import 'notifications_state.dart';

class NotificationsBloc extends Bloc<NotificationsEvent, NotificationsState> {
  final WatchNotifications watchNotifications;
  final MarkNotificationRead markNotificationRead;

  StreamSubscription? _subscription;
  String? _currentUserId;
  int _subscriptionGeneration = 0;

  NotificationsBloc({
    required this.watchNotifications,
    required this.markNotificationRead,
  }) : super(const NotificationsState()) {
    on<NotificationsStarted>(_onStarted);
    on<NotificationsUpdated>(_onUpdated);
    on<NotificationMarkedRead>(_onMarkedRead);
    on<NotificationsStopped>(_onStopped);
    on<_NotificationsFailed>(_onFailed);
  }

  Future<void> _onStarted(
    NotificationsStarted event,
    Emitter<NotificationsState> emit,
  ) async {
    // Invalidate events from any previous subscription.
    final generation = ++_subscriptionGeneration;
    _currentUserId = event.userId;

    await _subscription?.cancel();
    _subscription = null;

    if (generation != _subscriptionGeneration) return;

    emit(const NotificationsState(status: NotificationsStatus.loading));

    try {
      _subscription = watchNotifications(event.userId).listen(
        (notifications) {
          if (!isClosed && generation == _subscriptionGeneration) {
            add(NotificationsUpdated(notifications));
          }
        },
        onError: (Object error) {
          if (!isClosed && generation == _subscriptionGeneration) {
            add(_NotificationsFailed(error.toString()));
          }
        },
      );
    } catch (error) {
      if (generation == _subscriptionGeneration) {
        emit(
          NotificationsState(
            status: NotificationsStatus.failure,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  void _onUpdated(
    NotificationsUpdated event,
    Emitter<NotificationsState> emit,
  ) {
    if (_currentUserId == null) return;

    emit(
      NotificationsState(
        status: NotificationsStatus.loaded,
        notifications: event.notifications,
      ),
    );
  }

  Future<void> _onMarkedRead(
    NotificationMarkedRead event,
    Emitter<NotificationsState> emit,
  ) async {
    final userId = _currentUserId;
    if (userId == null) return;

    final matching = state.notifications.where(
      (notification) =>
          notification.notificationId == event.notificationId &&
          notification.userId == userId,
    );

    if (matching.isEmpty || matching.first.read) return;

    try {
      await markNotificationRead(event.notificationId);

      // No manual refresh needed.
      // Firestore will emit the updated notification.
    } catch (error) {
      if (_currentUserId == userId) {
        emit(
          NotificationsState(
            status: NotificationsStatus.failure,
            notifications: state.notifications,
            errorMessage: error.toString(),
          ),
        );
      }
    }
  }

  Future<void> _onStopped(
    NotificationsStopped event,
    Emitter<NotificationsState> emit,
  ) async {
    ++_subscriptionGeneration;
    _currentUserId = null;

    await _subscription?.cancel();
    _subscription = null;

    emit(const NotificationsState());
  }

  void _onFailed(_NotificationsFailed event, Emitter<NotificationsState> emit) {
    if (_currentUserId == null) return;

    emit(
      NotificationsState(
        status: NotificationsStatus.failure,
        notifications: state.notifications,
        errorMessage: event.message,
      ),
    );
  }

  @override
  Future<void> close() async {
    ++_subscriptionGeneration;
    _currentUserId = null;
    await _subscription?.cancel();
    await super.close();
  }
}

// Internal event for Firestore stream errors.
class _NotificationsFailed extends NotificationsEvent {
  final String message;

  const _NotificationsFailed(this.message);
}
