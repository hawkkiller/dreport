import 'dart:convert';
import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';

abstract base class BaseCommand extends Command<void> {
  BaseCommand() {
    argParser.addFlag('verbose', abbr: 'v', negatable: false, help: 'Enable verbose output.');
  }

  Logger get logger => argResults?['verbose'] == true ? Logger.verbose(logTime: false) : Logger.standard();

  /// Verifies if the command is being run with piped input.
  ///
  /// If the command is not being run with piped input, it throws a [UsageException].
  /// The [message] parameter can be used to provide additional information to the user.
  void verifyPipedInput([String? message]) {
    if (stdin.hasTerminal) {
      final buffer = StringBuffer();
      buffer.write('No piped input detected. Pipe input into this command.');
      if (message != null) {
        buffer.writeln();
        buffer.write(message);
      }
      usageException(buffer.toString());
    }
  }

  /// Reads piped input from the standard input stream.
  ///
  /// The [message] parameter can be used to provide additional information to the user
  /// if the command is not being run with piped input.
  Future<String> readPipedInput({String? message}) async {
    verifyPipedInput(message);

    final input = await stdin.transform(utf8.decoder).join();

    return input;
  }

  /// Reads input from a file.
  Future<String> readFileInput(String inputFile, {String? message}) async {
    final file = File(inputFile);
    if (!file.existsSync()) {
      final buffer = StringBuffer();
      buffer.write('File not found: $inputFile');
      if (message != null) {
        buffer.writeln();
        buffer.write(message);
      }

      usageException(buffer.toString());
    }

    return await file.readAsString();
  }

  /// Reads input from the user.
  ///
  /// If [inputFile] is provided, it reads from that file.
  /// If [messageIfPipeFailed] is provided, it reads from the standard input stream.
  /// Otherwise, it throws an error.
  Future<String> readInput({
    String? inputFile,
    String? messageIfPipeFailed,
    String? messageIfFileFailed,
  }) async {
    if (inputFile != null) {
      return await readFileInput(inputFile, message: messageIfFileFailed);
    } else if (messageIfPipeFailed != null) {
      return await readPipedInput(message: messageIfPipeFailed);
    } else {
      usageException('No input provided. Use --input or pipe input.');
    }
  }

  /// Verifies if a required argument is provided.
  T verifyArgProvided<T>(String arg) {
    final value = argResults?[arg];

    if (value == null) {
      usageException('Argument $arg is required.');
    }

    return value as T;
  }

  /// Writes output to a file or standard output.
  /// 
  /// If [outputFile] is provided, it writes to that file.
  /// Otherwise, it writes to standard output.
  Future<void> writeOutput(String output, {String? outputFile}) async {
    if (outputFile != null) {
      await File(outputFile).writeAsString(output);
    } else {
      logger.stdout(output);
    }
  }
}
