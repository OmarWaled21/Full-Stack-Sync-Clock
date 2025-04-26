part of 'logs_cubit.dart';

@immutable
sealed class LogsState {}

class LogsInitial extends LogsState {}

class LogsLoading extends LogsState {}

class LogsLoaded extends LogsState {
  final List<LogsModel> logs;

  LogsLoaded(this.logs);
}

class LogsError extends LogsState {
  final String message;

  LogsError(this.message);
}

class LogsDownloadSuccess extends LogsState {}

class LogsDownloadError extends LogsState {
  final String message;

  LogsDownloadError(this.message);
}
