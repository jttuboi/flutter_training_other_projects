import '../entities/typing_event.dart';
import '../entities/user.dart';

abstract class ITypingNotificationService {
  const ITypingNotificationService();

  ///
  ///
  Future<bool> send({required TypingEvent event, required User to});

  ///
  ///
  Stream<TypingEvent> subscribe(User user, List<String> usersIds);

  ///
  ///
  Future<void> dispose();
}
