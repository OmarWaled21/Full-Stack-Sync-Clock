part of 'messages_cubit.dart';

sealed class MessagesState extends Equatable {
  const MessagesState();

  @override
  List<Object> get props => [];
}

final class MessagesInitial extends MessagesState {}

final class MessagesLoading extends MessagesState {}

final class MessagesSuccess extends MessagesState {}

final class MessagesFailure extends MessagesState {
  final String message;
  const MessagesFailure(this.message);

  @override
  List<Object> get props => [message];
}
