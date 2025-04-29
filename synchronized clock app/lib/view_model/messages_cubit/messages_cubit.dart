import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:synchronized_clock/repositories/send_messages_repo.dart';

part 'messages_state.dart';

class MessagesCubit extends Cubit<MessagesState> {
  final SendMessagesRepo _repo;

  MessagesCubit({SendMessagesRepo? repo})
    : _repo = repo ?? SendMessagesRepo(),
      super(MessagesInitial());

  Future<void> switchActiveSettings({
    required bool whatsappIsActive,
    required bool gmailIsActive,
    required bool smsIsActive,
    required String groupUrl,
    required String email,
    required String phone,
  }) async {
    await _execute(
      () => _repo.switchActive(
        whatsappIsActive: whatsappIsActive,
        gmailIsActive: gmailIsActive,
        smsIsActive: smsIsActive,
        groupUrl: groupUrl,
        email: email,
        phoneNumber: phone,
      ),
    );
  }

  Future<void> _execute(Future<void> Function() operation) async {
    try {
      emit(MessagesLoading());
      await operation();
      emit(MessagesSuccess());
    } catch (e) {
      emit(MessagesFailure(e.toString()));
    }
  }
}
