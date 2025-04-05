import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dreport/src/core/analyzer/parser.dart';

/// Model class for GitLab code quality issue
class GitLabIssue {
  /// A human-readable description of the code quality violation
  final String description;

  /// A unique name representing the check, or rule, associated with this violation
  final String checkName;

  /// A unique fingerprint to identify this specific code quality violation
  final String fingerprint;

  /// The severity of the violation (info, minor, major, critical, blocker)
  final String severity;

  /// Location information for the issue
  final GitLabLocation location;

  /// Additional information about the issue
  final String? additional;

  GitLabIssue({
    required this.description,
    required this.checkName,
    required this.fingerprint,
    required this.severity,
    required this.location,
    this.additional,
  });

  Map<String, dynamic> toJson() {
    return {
      'description': description,
      'check_name': checkName,
      'fingerprint': fingerprint,
      'severity': severity,
      'location': location.toJson(),
      if (additional != null) 'additional': additional,
    };
  }

  factory GitLabIssue.fromJson(Map<String, dynamic> json) {
    return GitLabIssue(
      description: json['description'] as String,
      checkName: json['check_name'] as String,
      fingerprint: json['fingerprint'] as String,
      severity: json['severity'] as String,
      location: GitLabLocation.fromJson(json['location'] as Map<String, dynamic>),
      additional: json['additional'] as String?,
    );
  }
}

/// Location data for a GitLab code quality issue
class GitLabLocation {
  /// The file containing the code quality violation
  final String path;

  /// Line information
  final GitLabLines lines;

  /// Position information
  final GitLabPositions positions;

  GitLabLocation({required this.path, required this.lines, required this.positions});

  Map<String, dynamic> toJson() {
    return {'path': path, 'lines': lines.toJson(), 'positions': positions.toJson()};
  }

  factory GitLabLocation.fromJson(Map<String, dynamic> json) {
    return GitLabLocation(
      path: json['path'] as String,
      lines: GitLabLines.fromJson(json['lines'] as Map<String, dynamic>),
      positions: GitLabPositions.fromJson(json['positions'] as Map<String, dynamic>),
    );
  }
}

/// Lines information for a GitLab issue
class GitLabLines {
  final int begin;

  GitLabLines({required this.begin});

  Map<String, dynamic> toJson() => {'begin': begin};

  factory GitLabLines.fromJson(Map<String, dynamic> json) {
    return GitLabLines(
      begin: json['begin'] is int ? json['begin'] as int : int.parse(json['begin'].toString()),
    );
  }
}

/// Position information for a GitLab issue
class GitLabPositions {
  final GitLabPosition begin;

  GitLabPositions({required this.begin});

  Map<String, dynamic> toJson() => {'begin': begin.toJson()};

  factory GitLabPositions.fromJson(Map<String, dynamic> json) {
    return GitLabPositions(begin: GitLabPosition.fromJson(json['begin'] as Map<String, dynamic>));
  }
}

/// Begin position for a GitLab issue
class GitLabPosition {
  final int line;
  final int column;

  GitLabPosition({required this.line, required this.column});

  Map<String, dynamic> toJson() => {'line': line, 'column': column};

  factory GitLabPosition.fromJson(Map<String, dynamic> json) {
    return GitLabPosition(
      line: json['line'] is int ? json['line'] as int : int.parse(json['line'].toString()),
      column: json['column'] is int ? json['column'] as int : int.parse(json['column'].toString()),
    );
  }
}

/// Converts between a single AnalyzerIssue and a single GitLabIssue
class GitLabIssueCodec extends Codec<AnalyzerIssue, GitLabIssue> {
  const GitLabIssueCodec();

  @override
  Converter<AnalyzerIssue, GitLabIssue> get encoder => const GitLabIssueEncoder();

  @override
  Converter<GitLabIssue, AnalyzerIssue> get decoder => const GitLabIssueDecoder();
}

/// Converts a single AnalyzerIssue to a GitLabIssue
class GitLabIssueEncoder extends Converter<AnalyzerIssue, GitLabIssue> {
  const GitLabIssueEncoder();

  @override
  GitLabIssue convert(AnalyzerIssue issue) {
    // Create a unique fingerprint by hashing issue properties
    final fingerprint =
        sha256
            .convert(
              utf8.encode(
                '${issue.filePath}${issue.line}${issue.column}${issue.code}${issue.message}',
              ),
            )
            .toString();

    return GitLabIssue(
      description: issue.message,
      checkName: issue.code,
      fingerprint: fingerprint,
      severity: _mapSeverity(issue.severity),
      location: GitLabLocation(
        path: issue.filePath,
        lines: GitLabLines(begin: issue.line),
        positions: GitLabPositions(begin: GitLabPosition(line: issue.line, column: issue.column)),
      ),
      additional: issue.additional,
    );
  }
}

/// Converts a single GitLabIssue to an AnalyzerIssue
class GitLabIssueDecoder extends Converter<GitLabIssue, AnalyzerIssue> {
  const GitLabIssueDecoder();

  @override
  AnalyzerIssue convert(GitLabIssue gitlabIssue) {
    return AnalyzerIssue(
      severity: _mapGitLabSeverity(gitlabIssue.severity),
      filePath: gitlabIssue.location.path,
      line: gitlabIssue.location.lines.begin,
      column: gitlabIssue.location.positions.begin.column,
      message: gitlabIssue.description,
      code: gitlabIssue.checkName,
      additional: gitlabIssue.additional,
    );
  }
}

/// Maps severity levels from AnalyzerIssue to GitLab code quality format
String _mapSeverity(IssueSeverity severity) {
  switch (severity) {
    case IssueSeverity.error:
      return 'critical';
    case IssueSeverity.warning:
      return 'major';
    case IssueSeverity.info:
      return 'info';
  }
}

/// Maps GitLab severity back to IssueSeverity
IssueSeverity _mapGitLabSeverity(String gitlabSeverity) {
  switch (gitlabSeverity) {
    case 'critical':
    case 'blocker':
      return IssueSeverity.error;
    case 'major':
    case 'minor':
      return IssueSeverity.warning;
    case 'info':
    default:
      return IssueSeverity.info;
  }
}

// Provides convenient access to the GitLab issue codec
const gitlabIssueCodec = GitLabIssueCodec();
