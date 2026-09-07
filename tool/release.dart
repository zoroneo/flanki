import 'dart:convert';
import 'dart:io';

void main(List<String> args) async {
  if (args.contains('-h') || args.contains('--help')) {
    _printUsage();
    exit(0);
  }

  final dryRun = args.contains('--dry-run');
  final skipTests = args.contains('--skip-tests');
  final autoPush = args.contains('--push') || args.contains('-p');

  // Filter out flags to find target version argument if present
  final positional = args.where((a) => !a.startsWith('-')).toList();
  final targetArg = positional.isNotEmpty ? positional.first : null;

  print('\x1B[1;36m==> Flanki Automated Release Tool\x1B[0m');

  // 1. Check git repository status
  final gitStatus = await Process.run('git', ['status', '--porcelain']);
  if (gitStatus.exitCode != 0) {
    _error('Failed to query git status. Ensure git is installed and in PATH.');
    exit(1);
  }

  final modifiedTracked = LineSplitter.split(gitStatus.stdout.toString())
      .where((line) => !line.startsWith('??'))
      .toList();

  if (modifiedTracked.isNotEmpty) {
    _warning('There are uncommitted changes in tracked files:');
    for (final line in modifiedTracked) {
      print('    $line');
    }
    if (!dryRun) {
      stdout.write('\x1B[33mContinue anyway? [y/N]: \x1B[0m');
      final answer = stdin.readLineSync()?.trim().toLowerCase();
      if (answer != 'y' && answer != 'yes') {
        _error('Release aborted due to uncommitted changes.');
        exit(1);
      }
    }
  }

  // 2. Read pubspec.yaml to get current version
  final pubspecFile = File('pubspec.yaml');
  if (!pubspecFile.existsSync()) {
    _error('pubspec.yaml not found in current directory.');
    exit(1);
  }

  final pubspecContent = pubspecFile.readAsStringSync();
  final versionRegex = RegExp(r'^version:\s*([0-9]+)\.([0-9]+)\.([0-9]+)\+([0-9]+)', multiLine: true);
  final match = versionRegex.firstMatch(pubspecContent);

  if (match == null) {
    _error('Could not parse version in pubspec.yaml (expected format: X.Y.Z+B).');
    exit(1);
  }

  int major = int.parse(match.group(1)!);
  int minor = int.parse(match.group(2)!);
  int patch = int.parse(match.group(3)!);
  int buildNumber = int.parse(match.group(4)!);

  final currentSemver = '$major.$minor.$patch';
  print('Current version: \x1B[32mv$currentSemver+$buildNumber\x1B[0m');

  // 3. Compute new version and build number
  String newSemver;
  int newBuildNumber = buildNumber + 1;

  if (targetArg == null || targetArg == 'patch') {
    patch += 1;
    newSemver = '$major.$minor.$patch';
  } else if (targetArg == 'minor') {
    minor += 1;
    patch = 0;
    newSemver = '$major.$minor.$patch';
  } else if (targetArg == 'major') {
    major += 1;
    minor = 0;
    patch = 0;
    newSemver = '$major.$minor.$patch';
  } else {
    // Custom version passed: e.g. "1.0.3", "v1.0.3", or "1.0.3+5"
    String raw = targetArg.startsWith('v') ? targetArg.substring(1) : targetArg;
    if (raw.contains('+')) {
      final parts = raw.split('+');
      newSemver = parts[0];
      final customBuild = int.tryParse(parts[1]);
      if (customBuild != null) newBuildNumber = customBuild;
    } else {
      newSemver = raw;
    }

    final validSemver = RegExp(r'^[0-9]+\.[0-9]+\.[0-9]+$');
    if (!validSemver.hasMatch(newSemver)) {
      _error('Invalid version "$targetArg". Expected format: X.Y.Z, vX.Y.Z, or patch/minor/major');
      exit(1);
    }
  }

  final newFullVersion = '$newSemver+$newBuildNumber';
  print('Target release:  \x1B[1;32mv$newFullVersion (Tag: v$newSemver)\x1B[0m\n');

  // 4. Run tests and static checks
  if (!skipTests) {
    print('\x1B[1;34m==> Running pre-release checks (format, analyze, test)...\x1B[0m');
    final checkResult = await _runCommand('fvm', ['flutter', 'test']);
    if (checkResult != 0) {
      _error('Pre-release tests failed. Aborting release.');
      exit(checkResult);
    }
    print('\x1B[32m✔ Tests passed.\x1B[0m\n');
  } else {
    _warning('Pre-release tests skipped (--skip-tests).');
  }

  if (dryRun) {
    print('\x1B[1;33m[DRY RUN] Would update:\x1B[0m');
    print('  - pubspec.yaml -> version: $newFullVersion');
    print('  - lib/core/config/app_config.dart -> version: $newSemver, buildNumber: $newBuildNumber');
    print('  - packaging/windows/inno_setup.iss -> MyAppVersion: $newSemver');
    print('  - git commit: "chore(release): bump version to v$newSemver"');
    print('  - git tag: "v$newSemver"');
    if (autoPush) {
      print('  - git push origin HEAD && git push origin v$newSemver');
    }
    print('\n\x1B[32mDry run complete. No changes were made.\x1B[0m');
    exit(0);
  }

  // 5. Update files
  print('\x1B[1;34m==> Updating version metadata across codebase...\x1B[0m');

  // Update pubspec.yaml
  final updatedPubspec = pubspecContent.replaceFirst(
    versionRegex,
    'version: $newFullVersion',
  );
  pubspecFile.writeAsStringSync(updatedPubspec);
  print('  ✔ Updated pubspec.yaml -> \x1B[32m$newFullVersion\x1B[0m');

  // Update lib/core/config/app_config.dart
  final appConfigFile = File('lib/core/config/app_config.dart');
  if (appConfigFile.existsSync()) {
    var configContent = appConfigFile.readAsStringSync();
    configContent = configContent.replaceFirst(
      RegExp(r"static const String version = '[^']+';"),
      "static const String version = '$newSemver';",
    );
    configContent = configContent.replaceFirst(
      RegExp(r"static const int buildNumber = \d+;"),
      "static const int buildNumber = $newBuildNumber;",
    );
    appConfigFile.writeAsStringSync(configContent);
    print('  ✔ Updated lib/core/config/app_config.dart');
  }

  // Update packaging/windows/inno_setup.iss
  final innoFile = File('packaging/windows/inno_setup.iss');
  if (innoFile.existsSync()) {
    var innoContent = innoFile.readAsStringSync();
    innoContent = innoContent.replaceFirst(
      RegExp(r'#define MyAppVersion "[^"]+"'),
      '#define MyAppVersion "$newSemver"',
    );
    innoFile.writeAsStringSync(innoContent);
    print('  ✔ Updated packaging/windows/inno_setup.iss');
  }

  // 6. Git commit & tag
  print('\n\x1B[1;34m==> Creating git commit and tag...\x1B[0m');

  final addCode = await _runCommand('git', [
    'add',
    'pubspec.yaml',
    'lib/core/config/app_config.dart',
    'packaging/windows/inno_setup.iss',
  ]);
  if (addCode != 0) {
    _error('Failed to stage version files.');
    exit(1);
  }

  final commitCode = await _runCommand('git', [
    'commit',
    '-m',
    'chore(release): bump version to v$newSemver',
  ]);
  if (commitCode != 0) {
    _error('Failed to commit version bump.');
    exit(1);
  }

  final tagCode = await _runCommand('git', [
    'tag',
    '-a',
    'v$newSemver',
    '-m',
    'Release v$newSemver',
  ]);
  if (tagCode != 0) {
    _error('Failed to create git tag v$newSemver.');
    exit(1);
  }

  print('\x1B[32m✔ Successfully committed and tagged v$newSemver\x1B[0m\n');

  // 7. Push to remote
  bool doPush = autoPush;
  if (!doPush) {
    stdout.write('\x1B[1;33mPush commit and tag to origin now? [y/N]: \x1B[0m');
    final answer = stdin.readLineSync()?.trim().toLowerCase();
    doPush = (answer == 'y' || answer == 'yes');
  }

  if (doPush) {
    print('\x1B[1;34m==> Pushing to origin...\x1B[0m');
    final pushCommitCode = await _runCommand('git', ['push', 'origin', 'HEAD']);
    if (pushCommitCode != 0) {
      _error('Failed to push commits to origin.');
      exit(1);
    }
    final pushTagCode = await _runCommand('git', ['push', 'origin', 'v$newSemver']);
    if (pushTagCode != 0) {
      _error('Failed to push tag v$newSemver to origin.');
      exit(1);
    }
    print('\x1B[32m✔ Pushed commit & tag to origin!\x1B[0m');
    print('\x1B[1;35m🚀 GitHub Actions workflow has been triggered.\x1B[0m');
    print('Track release progress: https://github.com/zoroneo/flanki/actions\n');
  } else {
    print('\n\x1B[33mTag v$newSemver created locally. To publish later, run:\x1B[0m');
    print('  git push origin HEAD');
    print('  git push origin v$newSemver\n');
  }
}

Future<int> _runCommand(String executable, List<String> args) async {
  final proc = await Process.start(
    executable,
    args,
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  return proc.exitCode;
}

void _error(String msg) {
  stderr.writeln('\x1B[1;31m✖ Error: $msg\x1B[0m');
}

void _warning(String msg) {
  stdout.writeln('\x1B[1;33m⚠ Warning: $msg\x1B[0m');
}

void _printUsage() {
  print('''
Usage: dart run tool/release.dart [VERSION] [FLAGS]

Arguments:
  VERSION            Target version (e.g. 1.0.3, v1.0.3, patch, minor, major).
                     Defaults to 'patch' if omitted.

Flags:
  --push, -p         Automatically push commit and tag to origin without prompt.
  --skip-tests       Skip running tests before release.
  --dry-run          Preview changes without modifying files or git tags.
  -h, --help         Show this help message.

Examples:
  make release                  # Bump patch (1.0.2 -> 1.0.3), test, tag & prompt push
  make release v=minor          # Bump minor (1.0.2 -> 1.1.0)
  make release v=1.2.0          # Set explicit version
  make release ARGS="--push"    # Auto push to GitHub to trigger CI/CD build
''');
}
