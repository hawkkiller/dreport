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

  Map<String, Object?> toJson() {
    return {
      'description': description,
      'check_name': checkName,
      'fingerprint': fingerprint,
      'severity': severity,
      'location': location.toJson(),
      if (additional != null) 'additional': additional,
    };
  }

  factory GitLabIssue.fromJson(Map<String, Object?> json) {
    return GitLabIssue(
      description: json['description']! as String,
      checkName: json['check_name']! as String,
      fingerprint: json['fingerprint']! as String,
      severity: json['severity']! as String,
      location: GitLabLocation.fromJson(json['location']! as Map<String, Object?>),
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

  Map<String, Object?> toJson() {
    return {'path': path, 'lines': lines.toJson(), 'positions': positions.toJson()};
  }

  factory GitLabLocation.fromJson(Map<String, Object?> json) {
    return GitLabLocation(
      path: json['path']! as String,
      lines: GitLabLines.fromJson(json['lines']! as Map<String, Object?>),
      positions: GitLabPositions.fromJson(json['positions']! as Map<String, Object?>),
    );
  }
}

/// Lines information for a GitLab issue
class GitLabLines {
  final int begin;

  GitLabLines({required this.begin});

  Map<String, Object?> toJson() => {'begin': begin};

  factory GitLabLines.fromJson(Map<String, Object?> json) {
    return GitLabLines(
      begin: json['begin'] is int ? json['begin']! as int : int.parse(json['begin'].toString()),
    );
  }
}

/// Position information for a GitLab issue
class GitLabPositions {
  final GitLabPosition begin;

  GitLabPositions({required this.begin});

  Map<String, Object?> toJson() => {'begin': begin.toJson()};

  factory GitLabPositions.fromJson(Map<String, Object?> json) {
    return GitLabPositions(begin: GitLabPosition.fromJson(json['begin']! as Map<String, Object?>));
  }
}

/// Begin position for a GitLab issue
class GitLabPosition {
  final int line;
  final int column;

  GitLabPosition({required this.line, required this.column});

  Map<String, Object?> toJson() => {'line': line, 'column': column};

  factory GitLabPosition.fromJson(Map<String, Object?> json) {
    return GitLabPosition(
      line: json['line'] is int ? json['line']! as int : int.parse(json['line'].toString()),
      column: json['column'] is int ? json['column']! as int : int.parse(json['column'].toString()),
    );
  }
}
