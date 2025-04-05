import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dreport/src/core/analyzer/gitlab/model.dart';
import 'package:dreport/src/core/analyzer/parser.dart';

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
    );
  }
}

/// Converts a single GitLabIssue to an AnalyzerIssue
class GitLabIssueDecoder extends Converter<GitLabIssue, AnalyzerIssue> {
  const GitLabIssueDecoder();

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

  @override
  AnalyzerIssue convert(GitLabIssue gitlabIssue) {
    return AnalyzerIssue(
      severity: _mapGitLabSeverity(gitlabIssue.severity),
      filePath: gitlabIssue.location.path,
      line: gitlabIssue.location.lines.begin,
      column: gitlabIssue.location.positions.begin.column,
      message: gitlabIssue.description,
      code: gitlabIssue.checkName,
    );
  }
}

// Provides convenient access to the GitLab issue codec
const gitlabIssueCodec = GitLabIssueCodec();
