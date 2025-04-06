import 'dart:async';
import 'dart:convert';

import 'package:dreport/src/cli/commands/base_command.dart';
import 'package:dreport/src/core/analyzer/gitlab/gitlab_issue_codec.dart';
import 'package:dreport/src/core/analyzer/parser.dart';
import 'package:dreport/src/core/analyzer/rdjson/rdjson_codec.dart';

/// Formats that the analysis results can be converted to.
enum OutputFormat {
  gitlab,
  rdjson;

  /// Returns the [OutputFormat] corresponding to the given string.
  static OutputFormat fromString(String format) {
    return switch (format) {
      'gitlab' => gitlab,
      'rdjson' => rdjson,
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
      allowed: ['gitlab', 'rdjson'],
      allowedHelp: {
        'gitlab': 'Format suitable for GitLab CI.',
        'rdjson': 'Format suitable for ReviewDog (RDFormat).'
      },
      defaultsTo: 'gitlab',
    );

    argParser.addOption(
      'output',
      abbr: 'o',
      help: 'Output file to write to. If not provided, writes to stdout.',
    );

    // RDJSON specific options
    argParser.addOption(
      'source-name',
      help: 'Source name for RDJSON format (e.g., dart_analyzer).',
      defaultsTo: 'dart_analyzer',
    );

    argParser.addOption(
      'source-url',
      help: 'Source URL for RDJSON format.',
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
      OutputFormat.rdjson => _outputRDJson(parsedInput),
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

  String _outputRDJson(AnalyzerResult parsedInput) {
    const sourceName = 'dart analyze';

    final rdJsonCodec = createRDJsonCodec(sourceName: sourceName);

    final rdResult = rdJsonCodec.encode(parsedInput);
    return jsonEncode(rdResult.toJson());
  }
}
