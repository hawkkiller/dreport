import 'dart:async';

import 'package:dreport/src/cli/commands/base_command.dart';
import 'package:dreport/src/core/analyzer/parser.dart';

/// Formats that the analysis results can be converted to.
enum OutputFormat {
  gitlab;

  /// Returns the [OutputFormat] corresponding to the given string.
  static OutputFormat fromString(String format) {
    return switch (format) {
      'gitlab' => gitlab,
      _ => throw ArgumentError('Invalid output format: $format'),
    };
  }
}

final class AnalyzeConvertCommand extends BaseCommand {
  AnalyzeConvertCommand() {
    argParser.addOption(
      'input',
      abbr: 'i',
      help: 'Input file to read from. If not provided, reads from stdin.',
    );

    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output format to convert to.',
      allowed: ['gitlab'],
      allowedHelp: {'gitlab': 'Format suitable for GitLab CI.'},
      defaultsTo: 'gitlab',
    );
  }

  @override
  String get name => 'convert';

  @override
  String get description => 'Convert analysis results to different formats.';

  @override
  Future<void> run() async {
    final output = OutputFormat.fromString(verifyArgProvided<String>('output'));

    final input = await readInput(
      inputFile: argResults?['input'] as String?,
      messageIfPipeFailed: 'Example: dart analyze --format json | dreport analyze convert',
      messageIfFileFailed: 'Example: dreport analyze convert --input analysis.txt',
    );

    logger.trace('Received input:\n$input');
    final parsedInput = analyzerCodec.decode(input);

    logger.trace('Parsed input:\n$parsedInput');
    logger.trace(parsedInput.issues.join('\n'));
  }
}
