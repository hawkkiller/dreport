import 'dart:async';
import 'dart:convert';

import 'package:dreport/src/cli/commands/base_command.dart';
import 'package:dreport/src/core/analyzer/gitlab/gitlab_issue_codec.dart';
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
      'format',
      abbr: 'f',
      help: 'Output format to convert to.',
      allowed: ['gitlab'],
      allowedHelp: {'gitlab': 'Format suitable for GitLab CI.'},
      defaultsTo: 'gitlab',
    );

    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output file to write to. If not provided, writes to stdout.',
    );
  }

  @override
  String get name => 'convert';

  @override
  String get description => 'Convert analysis results to different formats.';

  @override
  Future<void> run() async {
    final output = OutputFormat.fromString(verifyArgProvided<String>('format'));
    final outputFile = argResults?['output'] as String?;

    final input = await readInput(
      inputFile: argResults?['input'] as String?,
      messageIfPipeFailed: 'Example: dart analyze --format json | dreport analyze convert',
      messageIfFileFailed: 'Example: dreport analyze convert --input analysis.txt',
    );

    logger.trace('Received input:\n$input');
    final parsedInput = analyzerCodec.decode(input);

    logger.trace('Parsed input:\n$parsedInput');
    logger.trace(parsedInput.issues.join('\n'));

    final outputString = switch (output) {
      OutputFormat.gitlab => _outputGitlab(parsedInput),
    };

    await writeOutput(outputString, outputFile: outputFile);
  }

  String _outputGitlab(AnalyzerResult parsedInput) {
    return jsonEncode(
      parsedInput.issues
          .map(gitlabIssueCodec.encode)
          .map((issue) => issue.toJson())
          .toList(growable: false),
    );
  }
}
