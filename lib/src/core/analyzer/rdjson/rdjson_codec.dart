import 'dart:convert';

import 'package:dreport/src/core/analyzer/parser.dart';
import 'package:dreport/src/core/analyzer/rdjson/model.dart';

/// Converts between AnalyzerIssue and RDDiagnostic formats
class RDJsonIssueCodec extends Codec<AnalyzerIssue, RDDiagnostic> {
  final String sourceName;
  final String? sourceUrl;

  const RDJsonIssueCodec({
    required this.sourceName,
    this.sourceUrl,
  });

  @override
  Converter<AnalyzerIssue, RDDiagnostic> get encoder => RDJsonIssueEncoder(
        sourceName: sourceName,
        sourceUrl: sourceUrl,
      );

  @override
  Converter<RDDiagnostic, AnalyzerIssue> get decoder => const RDJsonIssueDecoder();
}

/// Converts a single AnalyzerIssue to an RDDiagnostic
class RDJsonIssueEncoder extends Converter<AnalyzerIssue, RDDiagnostic> {
  final String sourceName;
  final String? sourceUrl;

  const RDJsonIssueEncoder({
    required this.sourceName,
    this.sourceUrl,
  });

  /// Maps severity levels from AnalyzerIssue to RDSeverity
  RDSeverity _mapSeverity(IssueSeverity severity) {
    switch (severity) {
      case IssueSeverity.error:
        return RDSeverity.error;
      case IssueSeverity.warning:
        return RDSeverity.warning;
      case IssueSeverity.info:
        return RDSeverity.info;
    }
  }

  @override
  RDDiagnostic convert(AnalyzerIssue issue) {
    // Create location with range (start position)
    final location = RDLocation(
      path: issue.filePath,
      range: RDRange(
        start: RDPosition(
          line: issue.line,
          column: issue.column,
        ),
        // End position is optional in RDFormat
      ),
    );

    // Create code information
    final code = RDCode(
      value: issue.code,
      // URL could be constructed if we have a base URL pattern for the rules
      // url: 'https://example.com/rules/${issue.code}',
    );

    // Source information
    final source = RDSource(
      name: sourceName,
      url: sourceUrl,
    );

    return RDDiagnostic(
      message: issue.message,
      location: location,
      severity: _mapSeverity(issue.severity),
      source: source,
      code: code,
      originalOutput: issue.toString(),
    );
  }
}

/// Converts an RDDiagnostic to an AnalyzerIssue
class RDJsonIssueDecoder extends Converter<RDDiagnostic, AnalyzerIssue> {
  const RDJsonIssueDecoder();

  /// Maps RDSeverity to IssueSeverity
  IssueSeverity _mapRDSeverity(RDSeverity? severity) {
    if (severity == null) return IssueSeverity.info;

    switch (severity) {
      case RDSeverity.error:
        return IssueSeverity.error;
      case RDSeverity.warning:
        return IssueSeverity.warning;
      case RDSeverity.info:
      case RDSeverity.unknownSeverity:
        return IssueSeverity.info;
    }
  }

  @override
  AnalyzerIssue convert(RDDiagnostic diagnostic) {
    // Extract line and column from the range
    final line = diagnostic.location.range?.start.line ?? 1;
    final column = diagnostic.location.range?.start.column ?? 1;

    // Extract code value or fallback
    final codeValue = diagnostic.code?.value ?? 'unknown';

    // Extract any suggestions as additional information
    String? additional;
    if (diagnostic.suggestions != null && diagnostic.suggestions!.isNotEmpty) {
      final suggestionTexts = diagnostic.suggestions!.map((s) => 'Fix: ${s.text}').join('\n');
      additional = suggestionTexts;
    } else if (diagnostic.originalOutput != null) {
      additional = diagnostic.originalOutput;
    }

    return AnalyzerIssue(
      severity: _mapRDSeverity(diagnostic.severity),
      filePath: diagnostic.location.path,
      line: line,
      column: column,
      message: diagnostic.message,
      code: codeValue,
      additional: additional,
    );
  }
}

/// Result converter for RDDiagnosticResult and AnalyzerResult
class RDJsonResultCodec extends Codec<AnalyzerResult, RDDiagnosticResult> {
  final String sourceName;
  final String? sourceUrl;

  const RDJsonResultCodec({
    required this.sourceName,
    this.sourceUrl,
  });

  @override
  Converter<AnalyzerResult, RDDiagnosticResult> get encoder => RDJsonResultEncoder(
        sourceName: sourceName,
        sourceUrl: sourceUrl,
      );

  @override
  Converter<RDDiagnosticResult, AnalyzerResult> get decoder => const RDJsonResultDecoder();
}

/// Converts an AnalyzerResult to an RDDiagnosticResult
class RDJsonResultEncoder extends Converter<AnalyzerResult, RDDiagnosticResult> {
  final String sourceName;
  final String? sourceUrl;

  const RDJsonResultEncoder({
    required this.sourceName,
    this.sourceUrl,
  });

  @override
  RDDiagnosticResult convert(AnalyzerResult result) {
    final issueCodec = RDJsonIssueCodec(sourceName: sourceName, sourceUrl: sourceUrl);

    // Convert each issue
    final diagnostics = result.issues.map(issueCodec.encode).toList();

    // Determine the overall severity based on the highest severity found
    RDSeverity? overallSeverity;
    if (result.errorCount > 0) {
      overallSeverity = RDSeverity.error;
    } else if (result.warningCount > 0) {
      overallSeverity = RDSeverity.warning;
    } else if (result.infoCount > 0) {
      overallSeverity = RDSeverity.info;
    }

    return RDDiagnosticResult(
      diagnostics: diagnostics,
      source: RDSource(name: sourceName, url: sourceUrl),
      severity: overallSeverity,
    );
  }
}

/// Converts an RDDiagnosticResult to an AnalyzerResult
class RDJsonResultDecoder extends Converter<RDDiagnosticResult, AnalyzerResult> {
  const RDJsonResultDecoder();

  @override
  AnalyzerResult convert(RDDiagnosticResult diagnosticResult) {
    const issueDecoder = RDJsonIssueDecoder();

    // Convert each diagnostic
    final issues =
        diagnosticResult.diagnostics.map((diagnostic) => issueDecoder.convert(diagnostic)).toList();

    return AnalyzerResult(issues: issues);
  }
}

/// Provides convenient access to the RDJSON codec
RDJsonResultCodec createRDJsonCodec({
  required String sourceName,
  String? sourceUrl,
}) {
  return RDJsonResultCodec(
    sourceName: sourceName,
    sourceUrl: sourceUrl,
  );
}
