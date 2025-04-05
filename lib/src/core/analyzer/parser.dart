import 'dart:convert';

class AnalyzerIssue {
  final IssueSeverity severity;
  final String filePath;
  final int line;
  final int column;
  final String message;
  final String code;
  final String? additional;

  AnalyzerIssue({
    required this.severity,
    required this.filePath,
    required this.line,
    required this.column,
    required this.message,
    required this.code,
    this.additional,
  });

  @override
  String toString() {
    return '${severity.name} - $filePath:$line:$column - $message - $code';
  }
}

enum IssueSeverity {
  error,
  warning,
  info;

  static IssueSeverity fromString(String value) {
    return IssueSeverity.values.firstWhere(
      (severity) => severity.name == value,
      orElse: () => IssueSeverity.info,
    );
  }
}

class AnalyzerResult {
  final List<AnalyzerIssue> issues;

  AnalyzerResult({required this.issues});

  int get errorCount => issues.where((issue) => issue.severity == IssueSeverity.error).length;
  int get warningCount => issues.where((issue) => issue.severity == IssueSeverity.warning).length;
  int get infoCount => issues.where((issue) => issue.severity == IssueSeverity.info).length;
  int get totalIssueCount => issues.length;

  @override
  String toString() {
    return '$totalIssueCount issues found (Errors: $errorCount, Warnings: $warningCount, Info: $infoCount)';
  }
}

class AnalyzerCodec extends Codec<AnalyzerResult, String> {
  const AnalyzerCodec();

  @override
  Converter<AnalyzerResult, String> get encoder => const AnalyzerEncoder();

  @override
  Converter<String, AnalyzerResult> get decoder => const AnalyzerDecoder();
}

class AnalyzerDecoder extends Converter<String, AnalyzerResult> {
  const AnalyzerDecoder();

  @override
  AnalyzerResult convert(String output) {
    // Ignore header lines
    final lines =
        LineSplitter.split(output)
            .where(
              (line) =>
                  line.trim().isNotEmpty &&
                  !line.trim().startsWith('Analyzing') &&
                  !line.contains('issues found'),
            )
            .toList();

    final issues = <AnalyzerIssue>[];
    String? currentAdditional;

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i].trim();

      // Check if this is an issue line or an additional info line
      if (line.startsWith(RegExp('error|info|warning'))) {
        // If we were collecting additional info, add it to the previous issue
        if (currentAdditional != null && issues.isNotEmpty) {
          issues.last = AnalyzerIssue(
            severity: issues.last.severity,
            filePath: issues.last.filePath,
            line: issues.last.line,
            column: issues.last.column,
            message: issues.last.message,
            code: issues.last.code,
            additional: currentAdditional,
          );
          currentAdditional = null;
        }

        // Parse issue line using regex
        final issueRegex = RegExp(
          r'^(\w+)\s+-\s+([^:]+):(\d+):(\d+)\s+-\s+(.+)\s+-\s+(\w+(?:_\w+)*)$',
        );
        final match = issueRegex.firstMatch(line);

        if (match != null) {
          issues.add(
            AnalyzerIssue(
              severity: IssueSeverity.fromString(match.group(1)!),
              filePath: match.group(2)!,
              line: int.parse(match.group(3)!),
              column: int.parse(match.group(4)!),
              message: match.group(5)!,
              code: match.group(6)!,
            ),
          );
        }
      } else if (line.startsWith('-')) {
        // This is an additional info line
        final infoText = line.substring(1).trim();
        currentAdditional = currentAdditional == null ? infoText : '$currentAdditional\n$infoText';
      }
    }

    // Add any final additional info
    if (currentAdditional != null && issues.isNotEmpty) {
      issues.last = AnalyzerIssue(
        severity: issues.last.severity,
        filePath: issues.last.filePath,
        line: issues.last.line,
        column: issues.last.column,
        message: issues.last.message,
        code: issues.last.code,
        additional: currentAdditional,
      );
    }

    return AnalyzerResult(issues: issues);
  }
}

class AnalyzerEncoder extends Converter<AnalyzerResult, String> {
  const AnalyzerEncoder();

  @override
  String convert(AnalyzerResult result) {
    // Basic implementation to convert analysis result to string
    // This could be expanded for specific formatting needs
    final buffer = StringBuffer();
    
    for (final issue in result.issues) {
      buffer.writeln('${issue.severity.name} - ${issue.filePath}:${issue.line}:${issue.column} - ${issue.message} - ${issue.code}');
      
      if (issue.additional != null) {
        for (final line in LineSplitter.split(issue.additional!)) {
          buffer.writeln('- $line');
        }
      }
    }
    
    buffer.writeln('${result.totalIssueCount} issues found (Errors: ${result.errorCount}, Warnings: ${result.warningCount}, Info: ${result.infoCount})');
    
    return buffer.toString();
  }
}

// Provides convenient access to the analyzer codec
const analyzerCodec = AnalyzerCodec();
