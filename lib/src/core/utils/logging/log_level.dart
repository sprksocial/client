/// Defines the severity levels for logging
enum LogLevel {
  verbose(0, 'VERBOSE'),
  debug(1, 'DEBUG'),
  info(2, 'INFO'),
  warning(3, 'WARNING'),
  error(4, 'ERROR'),
  fatal(5, 'FATAL'),
  nothing(6, 'NOTHING')
  ;

  final int value;
  final String name;

  const LogLevel(this.value, this.name);

  /// Checks if this log level is at least as severe as [other]
  bool isAtLeast(LogLevel other) => value >= other.value;

  @override
  String toString() => name;
}
