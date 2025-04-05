import 'dart:io';

import 'package:args/command_runner.dart';
import 'package:cli_util/cli_logging.dart';
import 'package:dreport/src/cli/commands/analyze/analyze_command.dart';

class DReportCommandRunner extends CommandRunner<void> {
  DReportCommandRunner()
    : super('dreport', 'A command-line tool for generating reports from Dart tests and analysis.') {
    argParser.addFlag('verbose', abbr: 'v', negatable: false, help: 'Enable verbose output.');
    addCommand(AnalyzeCommand());
  }

  final _logger = Logger.standard();

  @override
  Future<void> run(Iterable<String> args) async {
    try {
      await super.run(args);
    } on UsageException catch (e) {
      _logger.stderr(e.toString());
      exit(64);
    }
  }
}
