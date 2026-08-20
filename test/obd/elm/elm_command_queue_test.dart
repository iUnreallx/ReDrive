import 'package:flutter_test/flutter_test.dart';
import 'package:redrive/obd/elm/elm_command.dart';
import 'package:redrive/obd/elm/elm_command_queue.dart';

const Duration _timeout = Duration(seconds: 1);

void main() {
  test('first command becomes current and nothing waits', () {
    final ElmCommandQueue queue = ElmCommandQueue();

    final ElmCommand first = queue.incomingQueue('010C', _timeout);

    expect(queue.currentElmCommand, same(first));
    expect(queue.waitingCommands, isEmpty);
  });

  test('second command waits and does not replace current', () {
    final ElmCommandQueue queue = ElmCommandQueue();

    final ElmCommand first = queue.incomingQueue('010C', _timeout);
    final ElmCommand second = queue.incomingQueue('010D', _timeout);

    expect(queue.currentElmCommand, same(first));
    expect(queue.waitingCommands, [second]);
  });

  test('generation ids are unique and increasing', () {
    final ElmCommandQueue queue = ElmCommandQueue();

    final ElmCommand first = queue.incomingQueue('010C', _timeout);
    final ElmCommand second = queue.incomingQueue('010D', _timeout);
    final ElmCommand third = queue.incomingQueue('0105', _timeout);

    expect(first.generationId, lessThan(second.generationId));
    expect(second.generationId, lessThan(third.generationId));
  });

  test('completeCurrent promotes waiting commands in FIFO order', () {
    final ElmCommandQueue queue = ElmCommandQueue();

    queue.incomingQueue('010C', _timeout);
    final ElmCommand second = queue.incomingQueue('010D', _timeout);
    final ElmCommand third = queue.incomingQueue('0105', _timeout);

    expect(queue.completeCurrent(), same(second));
    expect(queue.currentElmCommand, same(second));
    expect(queue.waitingCommands, [third]);

    expect(queue.completeCurrent(), same(third));
    expect(queue.currentElmCommand, same(third));
    expect(queue.waitingCommands, isEmpty);
  });

  test(
    'completeCurrent returns null and clears current when nothing waits',
    () {
      final ElmCommandQueue queue = ElmCommandQueue();

      queue.incomingQueue('010C', _timeout);

      expect(queue.completeCurrent(), isNull);
      expect(queue.currentElmCommand, isNull);
    },
  );

  test('command added after drained queue becomes current again', () {
    final ElmCommandQueue queue = ElmCommandQueue();

    queue.incomingQueue('010C', _timeout);
    queue.completeCurrent();

    final ElmCommand next = queue.incomingQueue('010D', _timeout);

    expect(queue.currentElmCommand, same(next));
    expect(queue.waitingCommands, isEmpty);
  });

  test('command keeps its own pending completer', () {
    final ElmCommandQueue queue = ElmCommandQueue();

    final ElmCommand first = queue.incomingQueue('010C', _timeout);
    final ElmCommand second = queue.incomingQueue('010D', _timeout);

    expect(first.completer.isCompleted, isFalse);
    expect(second.completer.isCompleted, isFalse);
    expect(first.completer, isNot(same(second.completer)));
  });

  test('first command becomes current', () {
    final ElmCommandQueue queue = ElmCommandQueue();

    final command = queue.incomingQueue("01 0C", const Duration(seconds: 2));

    expect(queue.currentElmCommand, command);
    expect(queue.waitingCommands, isEmpty);
    expect(command.generationId, 1);
  });

  test('second command goes to waiting', () {
    final queue = ElmCommandQueue();

    final command1 = queue.incomingQueue("01 0C", const Duration(seconds: 2));

    final command2 = queue.incomingQueue("01 0D", const Duration(seconds: 2));

    expect(queue.currentElmCommand, command1);
    expect(queue.waitingCommands, [command2]);

    expect(command1.generationId, 1);
    expect(command2.generationId, 2);
  });

  test('completeCurrent switches commands in FIFO order', () {
    final queue = ElmCommandQueue();

    queue.incomingQueue("01 0C", const Duration(seconds: 2));

    final command2 = queue.incomingQueue("01 0D", const Duration(seconds: 2));

    final command3 = queue.incomingQueue("01 05", const Duration(seconds: 2));

    final nextCommand = queue.completeCurrent();

    expect(nextCommand, command2);
    expect(queue.currentElmCommand, command2);
    expect(queue.waitingCommands, [command3]);
  });

  test('completeCurrent clears current when waiting is empty', () {
    final queue = ElmCommandQueue();

    queue.incomingQueue("01 0C", const Duration(seconds: 2));

    final nextCommand = queue.completeCurrent();

    expect(nextCommand, isNull);
    expect(queue.currentElmCommand, isNull);
    expect(queue.waitingCommands, isEmpty);
  });
}
