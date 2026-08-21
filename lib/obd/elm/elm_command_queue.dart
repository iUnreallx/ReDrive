import 'package:redrive/obd/elm/elm_command.dart';

class ElmCommandQueue {
  int _nextGenerationId = 0;

  ElmCommand? currentElmCommand;
  final List<ElmCommand> waitingCommands = [];

  ElmCommand incomingQueue(String command, Duration timeout) {
    _nextGenerationId++;

    ElmCommand newCommand = ElmCommand(
      command: command,
      timeout: timeout,
      generationId: _nextGenerationId,
    );

    if (currentElmCommand == null) {
      currentElmCommand = newCommand;
    } else {
      waitingCommands.add(newCommand);
    }

    return newCommand;
  }

  ElmCommand? completeCurrent() {
    if (waitingCommands.isEmpty) {
      currentElmCommand = null;
      return null;
    }

    ElmCommand nextResponseCommand = waitingCommands.removeAt(0);
    currentElmCommand = nextResponseCommand;
    return nextResponseCommand;
  }

  List<ElmCommand> abortAll() {
    final commands = <ElmCommand>[];

    if (currentElmCommand != null) {
      commands.add(currentElmCommand!);
    }

    commands.addAll(waitingCommands);

    currentElmCommand = null;
    waitingCommands.clear();

    return commands;
  }
}
