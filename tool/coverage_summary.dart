import 'dart:io';

void main(List<String> arguments) {
  final enforceCritical = arguments.contains('--enforce-critical');
  final positionalArguments = arguments
      .where((argument) => !argument.startsWith('--'))
      .toList();
  final coveragePath = positionalArguments.isEmpty
      ? 'coverage/lcov.info'
      : positionalArguments.first;
  final coverageFile = File(coveragePath);
  if (!coverageFile.existsSync()) {
    stderr.writeln('Coverage file not found: $coveragePath');
    exitCode = 1;
    return;
  }

  final reports = _readReports(coverageFile.readAsLinesSync()).where((report) {
    return _relativePath(report.path).startsWith('lib/') &&
        !_isGenerated(report.path);
  }).toList();
  final covered = reports.fold<int>(0, (sum, report) => sum + report.covered);
  final found = reports.fold<int>(0, (sum, report) => sum + report.found);
  final percent = found == 0 ? 0.0 : covered * 100 / found;

  final productionFiles = Directory('lib')
      .listSync(recursive: true)
      .whereType<File>()
      .map((file) => file.path)
      .where((path) => path.endsWith('.dart') && !_isGenerated(path))
      .toSet();
  final coveredProductionFiles = reports
      .map((report) => _relativePath(report.path))
      .where(productionFiles.contains)
      .toSet();
  final missingProductionFiles = productionFiles.difference(
    coveredProductionFiles,
  );
  final criticalFiles = productionFiles.where(_isCriticalRepository).toSet();
  final zeroCoveredCriticalFiles =
      reports
          .where(
            (report) =>
                _isCriticalRepository(_relativePath(report.path)) &&
                report.found > 0 &&
                report.covered == 0,
          )
          .map((report) => _relativePath(report.path))
          .toSet()
        ..addAll(criticalFiles.difference(coveredProductionFiles));

  final reportsByArea = <String, List<_CoverageReport>>{};
  for (final report in reports) {
    final path = _relativePath(report.path);
    reportsByArea.putIfAbsent(_areaFor(path), () => []).add(report);
  }
  final productionFilesByArea = <String, Set<String>>{};
  for (final path in productionFiles) {
    productionFilesByArea.putIfAbsent(_areaFor(path), () => {}).add(path);
  }

  stdout
    ..writeln('## Test coverage')
    ..writeln()
    ..writeln(
      '- Coverage among nongenerated production executable lines represented '
      'in LCOV: $covered / $found '
      '(${percent.toStringAsFixed(1)}%)',
    )
    ..writeln(
      '- Nongenerated production files represented in LCOV: '
      '${coveredProductionFiles.length} / ${productionFiles.length}',
    )
    ..writeln()
    ..writeln('### Coverage balance by area')
    ..writeln()
    ..writeln('| Area | Files represented | Executable lines | Coverage |')
    ..writeln('| --- | ---: | ---: | ---: |');

  final areas = productionFilesByArea.keys.toList()..sort();
  for (final area in areas) {
    final areaReports = reportsByArea[area] ?? const <_CoverageReport>[];
    final areaCovered = areaReports.fold<int>(
      0,
      (sum, report) => sum + report.covered,
    );
    final areaFound = areaReports.fold<int>(
      0,
      (sum, report) => sum + report.found,
    );
    final areaPercent = areaFound == 0 ? 0.0 : areaCovered * 100 / areaFound;
    stdout.writeln(
      '| `$area` | ${areaReports.length} / '
      '${productionFilesByArea[area]!.length} | '
      '$areaCovered / $areaFound | ${areaPercent.toStringAsFixed(1)}% |',
    );
  }

  stdout
    ..writeln()
    ..writeln(
      '- Critical auth/network repository implementations with zero executed '
      'lines or absent from LCOV: ${zeroCoveredCriticalFiles.length}',
    );

  if (zeroCoveredCriticalFiles.isNotEmpty) {
    stdout
      ..writeln()
      ..writeln('<details>')
      ..writeln('<summary>Critical repository coverage gaps</summary>')
      ..writeln()
      ..writeln('```text');
    for (final path in zeroCoveredCriticalFiles.toList()..sort()) {
      stdout.writeln(path);
    }
    stdout
      ..writeln('```')
      ..writeln('</details>');
  }

  if (missingProductionFiles.isNotEmpty) {
    stdout
      ..writeln()
      ..writeln('<details>')
      ..writeln(
        '<summary>Production files absent from coverage '
        '(${missingProductionFiles.length})</summary>',
      )
      ..writeln()
      ..writeln('```text');
    for (final path in missingProductionFiles.toList()..sort()) {
      stdout.writeln(path);
    }
    stdout
      ..writeln('```')
      ..writeln('</details>');
  }

  if (enforceCritical && zeroCoveredCriticalFiles.isNotEmpty) {
    stderr.writeln(
      'Critical repository coverage check failed: '
      '${zeroCoveredCriticalFiles.length} implementation(s) have no coverage.',
    );
    exitCode = 1;
  }
}

List<_CoverageReport> _readReports(List<String> lines) {
  final reports = <_CoverageReport>[];
  String? path;
  var found = 0;
  var covered = 0;

  for (final line in lines) {
    if (line.startsWith('SF:')) {
      path = line.substring(3);
    } else if (line.startsWith('LF:')) {
      found = int.parse(line.substring(3));
    } else if (line.startsWith('LH:')) {
      covered = int.parse(line.substring(3));
    } else if (line == 'end_of_record' && path != null) {
      reports.add(_CoverageReport(path: path, found: found, covered: covered));
      path = null;
      found = 0;
      covered = 0;
    }
  }

  return reports;
}

String _relativePath(String path) {
  final root = Directory.current.absolute.path;
  final prefix = '$root${Platform.pathSeparator}';
  return path.startsWith(prefix) ? path.substring(prefix.length) : path;
}

bool _isGenerated(String path) {
  return path.endsWith('.g.dart') ||
      path.endsWith('.freezed.dart') ||
      path.endsWith('.gr.dart') ||
      path.endsWith('app_localizations.dart') ||
      path.contains('app_localizations_');
}

String _areaFor(String path) {
  final parts = path.split(Platform.pathSeparator);
  if (parts.length >= 4 && parts[0] == 'lib' && parts[1] == 'src') {
    if (parts[2] == 'core' || parts[2] == 'features') {
      return '${parts[2]}/${parts[3]}';
    }
  }
  return 'root';
}

bool _isCriticalRepository(String path) {
  if (!path.startsWith('lib/src/core/auth/') &&
      !path.startsWith('lib/src/core/network/')) {
    return false;
  }

  return (path.endsWith('_repository_impl.dart') &&
          path.contains('/data/repositories/')) ||
      path.endsWith('/data/repository/messages_repository_xrpc.dart');
}

class _CoverageReport {
  const _CoverageReport({
    required this.path,
    required this.found,
    required this.covered,
  });

  final String path;
  final int found;
  final int covered;
}
