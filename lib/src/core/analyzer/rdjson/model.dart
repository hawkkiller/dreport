/// Represents the top level diagnostic result structure
/// Based on https://github.com/reviewdog/reviewdog/blob/master/proto/rdf/jsonschema/DiagnosticResult.json
class RDDiagnosticResult {
  /// List of diagnostic issues
  final List<RDDiagnostic> diagnostics;

  /// The source of diagnostics, e.g. 'dart_analyzer'
  final RDSource? source;

  /// Overall severity level
  final RDSeverity? severity;

  RDDiagnosticResult({
    required this.diagnostics,
    this.source,
    this.severity,
  });

  Map<String, Object?> toJson() {
    return {
      'diagnostics': diagnostics.map((d) => d.toJson()).toList(),
      if (source != null) 'source': source!.toJson(),
      if (severity != null) 'severity': severity!.toName(),
    };
  }

  factory RDDiagnosticResult.fromJson(Map<String, Object?> json) {
    return RDDiagnosticResult(
      diagnostics: (json['diagnostics']! as List)
          .map((d) => RDDiagnostic.fromJson(d as Map<String, Object?>))
          .toList(),
      source: json['source'] != null
          ? RDSource.fromJson(json['source']! as Map<String, Object?>)
          : null,
      severity:
          json['severity'] != null ? RDSeverity.fromString(json['severity'].toString()) : null,
    );
  }
}

/// Represents a single diagnostic issue
class RDDiagnostic {
  /// The diagnostic message
  final String message;

  /// Location information
  final RDLocation location;

  /// Severity level of this diagnostic
  final RDSeverity? severity;

  /// Source of this diagnostic
  final RDSource? source;

  /// Rule code information
  final RDCode? code;

  /// Suggested fixes
  final List<RDSuggestion>? suggestions;

  /// Original output if converted from another format
  final String? originalOutput;

  /// Related locations
  final List<RDRelatedLocation>? relatedLocations;

  RDDiagnostic({
    required this.message,
    required this.location,
    this.severity,
    this.source,
    this.code,
    this.suggestions,
    this.originalOutput,
    this.relatedLocations,
  });

  Map<String, Object?> toJson() {
    return {
      'message': message,
      'location': location.toJson(),
      if (severity != null) 'severity': severity!.toName(),
      if (source != null) 'source': source!.toJson(),
      if (code != null) 'code': code!.toJson(),
      if (suggestions != null) 'suggestions': suggestions!.map((s) => s.toJson()).toList(),
      if (originalOutput != null) 'original_output': originalOutput,
      if (relatedLocations != null)
        'related_locations': relatedLocations!.map((r) => r.toJson()).toList(),
    };
  }

  factory RDDiagnostic.fromJson(Map<String, Object?> json) {
    return RDDiagnostic(
      message: json['message']! as String,
      location: RDLocation.fromJson(json['location']! as Map<String, Object?>),
      severity:
          json['severity'] != null ? RDSeverity.fromString(json['severity'].toString()) : null,
      source: json['source'] != null
          ? RDSource.fromJson(json['source']! as Map<String, Object?>)
          : null,
      code: json['code'] != null ? RDCode.fromJson(json['code']! as Map<String, Object?>) : null,
      suggestions: json['suggestions'] != null
          ? (json['suggestions']! as List<Object?>)
              .map((s) => RDSuggestion.fromJson(s! as Map<String, Object?>))
              .toList()
          : null,
      originalOutput: json['original_output'] as String?,
      relatedLocations: json['related_locations'] != null
          ? (json['related_locations']! as List<Object?>)
              .map((r) => RDRelatedLocation.fromJson(r! as Map<String, Object?>))
              .toList()
          : null,
    );
  }
}

/// Location information for a diagnostic
class RDLocation {
  /// File path (absolute or relative)
  final String path;

  /// Range in the file
  final RDRange? range;

  RDLocation({
    required this.path,
    this.range,
  });

  Map<String, Object?> toJson() {
    return {
      'path': path,
      if (range != null) 'range': range!.toJson(),
    };
  }

  factory RDLocation.fromJson(Map<String, Object?> json) {
    return RDLocation(
      path: json['path']! as String,
      range:
          json['range'] != null ? RDRange.fromJson(json['range']! as Map<String, Object?>) : null,
    );
  }
}

/// Position in a file (line and column)
class RDPosition {
  /// Line number, starting at 1
  final int? line;

  /// Column number, starting at 1 (byte count in UTF-8)
  final int? column;

  RDPosition({
    this.line,
    this.column,
  });

  Map<String, Object?> toJson() {
    return {
      if (line != null) 'line': line,
      if (column != null) 'column': column,
    };
  }

  factory RDPosition.fromJson(Map<String, Object?> json) {
    return RDPosition(
      line: json['line'] as int?,
      column: json['column'] as int?,
    );
  }
}

/// Range in a text document with start and end positions
class RDRange {
  /// Start position (required)
  final RDPosition start;

  /// End position (optional)
  final RDPosition? end;

  RDRange({
    required this.start,
    this.end,
  });

  Map<String, Object?> toJson() {
    return {
      'start': start.toJson(),
      if (end != null) 'end': end!.toJson(),
    };
  }

  factory RDRange.fromJson(Map<String, Object?> json) {
    return RDRange(
      start: RDPosition.fromJson(json['start']! as Map<String, Object?>),
      end: json['end'] != null ? RDPosition.fromJson(json['end']! as Map<String, Object?>) : null,
    );
  }
}

/// Source information
class RDSource {
  /// Human-readable name of the source
  final String name;

  /// URL to the source
  final String? url;

  RDSource({
    required this.name,
    this.url,
  });

  Map<String, Object?> toJson() {
    return {
      'name': name,
      if (url != null) 'url': url,
    };
  }

  factory RDSource.fromJson(Map<String, Object?> json) {
    return RDSource(
      name: json['name']! as String,
      url: json['url'] as String?,
    );
  }
}

/// Code/rule information
class RDCode {
  /// The rule's code/identifier
  final String value;

  /// URL with more information about this rule
  final String? url;

  RDCode({
    required this.value,
    this.url,
  });

  Map<String, Object?> toJson() {
    return {
      'value': value,
      if (url != null) 'url': url,
    };
  }

  factory RDCode.fromJson(Map<String, Object?> json) {
    return RDCode(
      value: json['value']! as String,
      url: json['url'] as String?,
    );
  }
}

/// Suggestion for fixing a diagnostic issue
class RDSuggestion {
  /// Range where the suggestion applies
  final RDRange range;

  /// Text to replace the range with
  final String text;

  RDSuggestion({
    required this.range,
    required this.text,
  });

  Map<String, Object?> toJson() {
    return {
      'range': range.toJson(),
      'text': text,
    };
  }

  factory RDSuggestion.fromJson(Map<String, Object?> json) {
    return RDSuggestion(
      range: RDRange.fromJson(json['range']! as Map<String, Object?>),
      text: json['text']! as String,
    );
  }
}

/// Related location information
class RDRelatedLocation {
  /// Explanation message
  final String? message;

  /// The location
  final RDLocation location;

  RDRelatedLocation({
    required this.location,
    this.message,
  });

  Map<String, Object?> toJson() {
    return {
      if (message != null) 'message': message,
      'location': location.toJson(),
    };
  }

  factory RDRelatedLocation.fromJson(Map<String, Object?> json) {
    return RDRelatedLocation(
      message: json['message'] as String?,
      location: RDLocation.fromJson(json['location']! as Map<String, Object?>),
    );
  }
}

/// Severity levels for diagnostics
enum RDSeverity {
  unknownSeverity,
  error,
  warning,
  info;

  String toName() {
    switch (this) {
      case RDSeverity.unknownSeverity:
        return 'UNKNOWN_SEVERITY';
      case RDSeverity.error:
        return 'ERROR';
      case RDSeverity.warning:
        return 'WARNING';
      case RDSeverity.info:
        return 'INFO';
    }
  }

  static RDSeverity fromString(String value) {
    switch (value.toUpperCase()) {
      case 'UNKNOWN_SEVERITY':
      case '0':
        return RDSeverity.unknownSeverity;
      case 'ERROR':
      case '1':
        return RDSeverity.error;
      case 'WARNING':
      case '2':
        return RDSeverity.warning;
      case 'INFO':
      case '3':
        return RDSeverity.info;
      default:
        return RDSeverity.unknownSeverity;
    }
  }
}
