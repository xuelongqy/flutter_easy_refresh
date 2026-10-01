import 'dart:io';

// Each Dart fence is a standalone library. Keep this map in fence order;
// the code itself is always read from the current package documentation.
final examples = <String, List<String>>{
  'easy_refresh/skills/easy-refresh-usage/SKILL.md': ['usage', 'grid'],
  'easy_refresh/skills/easy-refresh-indicators/SKILL.md': ['indicators'],
  'easy_refresh/skills/easy-refresh-indicators/references/custom-and-secondary.md':
      ['custom', 'locator', 'listener', 'secondary'],
  'easy_refresh/skills/easy-refresh-nested-scroll/SKILL.md': [
    'nested',
    'nested_secondary',
  ],
  'easy_paging/skills/easy-paging-usage/SKILL.md': ['paging'],
  for (final style in [
    'bow',
    'bubbles',
    'halloween',
    'skating',
    'space',
    'squats',
  ])
    'easy_refresh_$style/skills/easy-refresh-$style-usage/SKILL.md': [style],
};

List<String> dartBlocks(String markdown, String source) {
  final openings = RegExp(
    r'^```dart[ \t]*\r?$',
    multiLine: true,
  ).allMatches(markdown).length;
  final blocks = RegExp(
    r'^```dart[ \t]*\r?\n(.*?)^```[ \t]*\r?$',
    multiLine: true,
    dotAll: true,
  ).allMatches(markdown).map((match) => match[1]!).toList();
  if (blocks.length != openings || blocks.any((code) => code.trim().isEmpty)) {
    throw FormatException('$source: empty or unclosed Dart fence');
  }
  return blocks;
}

void checkExtraction() {
  final blocks = dartBlocks(
    'Text\r\n```yaml\r\nname: demo\r\n```\r\n'
        '```dart\r\nvoid first() {}\r\n```\r\n'
        '```dart \nvoid second() {}\n```',
    'self-check',
  );
  if (blocks.length != 2 ||
      blocks[0].trim() != 'void first() {}' ||
      blocks[1].trim() != 'void second() {}' ||
      dartBlocks('No examples.', 'self-check').isNotEmpty) {
    throw StateError('Dart fence extraction self-check failed');
  }
  for (final invalid in ['```dart\nvoid f() {}', '```dart\n\n```']) {
    var rejected = false;
    try {
      dartBlocks(invalid, 'self-check');
    } on FormatException {
      rejected = true;
    }
    if (!rejected) throw StateError('Invalid Dart fence was accepted');
  }
}

Future<void> main(List<String> arguments) async {
  checkExtraction();
  if (arguments.length == 1 && arguments.single == '--self-test') {
    stdout.writeln('Dart fence extraction self-check passed.');
    return;
  }
  if (arguments.isNotEmpty) {
    stderr.writeln('Usage: dart run tool/check_skills.dart [--self-test]');
    exitCode = 64;
    return;
  }

  final root = File.fromUri(Platform.script).parent.parent;
  if (!File.fromUri(root.uri.resolve('.dart_tool/package_config.json'))
      .existsSync()) {
    stderr.writeln('Run flutter pub get in ${root.path} first.');
    exitCode = 1;
    return;
  }
  final app = Directory.fromUri(root.uri.resolve('example/'));
  final cache = Directory.fromUri(app.uri.resolve('.dart_tool/'))
    ..createSync(recursive: true);
  final generated = cache.createTempSync('package_skills_');
  var passed = false;
  try {
    final libraries = Directory.fromUri(generated.uri.resolve('examples/'))
      ..createSync(recursive: true);
    final seen = <String>{};
    var count = 0;
    final packages = Directory.fromUri(root.uri.resolve('packages/'));
    for (final package in packages.listSync().whereType<Directory>()) {
      final skills = Directory.fromUri(package.uri.resolve('skills/'));
      if (!skills.existsSync()) continue;
      final documents =
          skills
              .listSync(recursive: true, followLinks: false)
              .whereType<File>()
              .where((file) => file.path.endsWith('.md'))
              .toList()
            ..sort((a, b) => a.path.compareTo(b.path));
      for (final document in documents) {
        final source = document.uri.path.substring(packages.uri.path.length);
        final blocks = dartBlocks(document.readAsStringSync(), source);
        final names = examples[source] ?? const <String>[];
        if (blocks.length != names.length) {
          throw FormatException(
            '$source: expected ${names.length} Dart fences, found '
            '${blocks.length}. Update the map in tool/check_skills.dart.',
          );
        }
        seen.add(source);
        for (var index = 0; index < blocks.length; index++) {
          File.fromUri(libraries.uri.resolve('${names[index]}.dart'))
              .writeAsStringSync(blocks[index]);
          stdout.writeln(
            '${names[index]}.dart <- packages/$source (Dart block ${index + 1})',
          );
          count++;
        }
      }
    }
    final missing = examples.keys.toSet().difference(seen);
    if (missing.isNotEmpty) {
      throw FormatException('Missing skill documents: ${missing.join(', ')}');
    }

    File.fromUri(generated.uri.resolve('analysis_options.yaml'))
        .writeAsStringSync('include: package:flutter_lints/flutter.yaml\n');
    final tests = Directory.fromUri(generated.uri.resolve('test/'))
      ..createSync();
    final testFile = File.fromUri(tests.uri.resolve('skills_test.dart'));
    File.fromUri(root.uri.resolve('tool/skills_test.dart.template'))
        .copySync(testFile.path);

    stdout.writeln(
      'Analyzing $count Markdown examples and their behavior tests.',
    );
    final analysis = await Process.start(
      Platform.resolvedExecutable,
      ['analyze', '--fatal-infos', generated.path],
      workingDirectory: app.path,
      mode: ProcessStartMode.inheritStdio,
    );
    exitCode = await analysis.exitCode;
    if (exitCode != 0) return;

    final testsProcess = await Process.start(
      'flutter',
      ['test', '--no-pub', '--reporter', 'expanded', testFile.path],
      workingDirectory: app.path,
      mode: ProcessStartMode.inheritStdio,
      runInShell: Platform.isWindows,
    );
    exitCode = await testsProcess.exitCode;
    passed = exitCode == 0;
    if (passed)
      stdout.writeln('Package skills check passed ($count examples).');
  } catch (error) {
    stderr.writeln('Package skills check failed: $error');
    exitCode = 1;
  } finally {
    if (passed) {
      generated.deleteSync(recursive: true);
    } else {
      stderr.writeln(
        'Generated files retained for inspection: ${generated.path}',
      );
    }
  }
}
