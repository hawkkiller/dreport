import 'package:args/command_runner.dart';
import 'package:dreport/src/cli/commands/analyze/analyze_convert_command.dart';

class AnalyzeCommand extends Command<void> {
  AnalyzeCommand() {
    addSubcommand(AnalyzeConvertCommand());
  }

  @override
  String get name => 'analyze';

  @override
  String get description => 'Commands for working with analysis results.';
}
