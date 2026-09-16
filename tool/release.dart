// ignore_for_file: avoid_print
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
    if (dryRun) {
      _warning('There are uncommitted changes in tracked files (ignored for dry-run):');
      for (final line in modifiedTracked) {
        print('    $line');
      }
    } else {
      _error('There are uncommitted changes in tracked files:');
      for (final line in modifiedTracked) {
        print('    $line');
      }
      _error('Release requires a clean working tree to switch and merge branches.');
      _error('Please commit or stash your changes before running make release.');
      exit(1);
    }
  }

  // 2. Identify current branch
  final branchProc = await Process.run('git', ['branch', '--show-current']);
  final currentBranch = branchProc.stdout.toString().trim();
  print('Current branch: \x1B[35m$currentBranch\x1B[0m');

  if (currentBranch != 'dev' && currentBranch != 'main') {
    _warning('You are currently on branch "$currentBranch".');
    _warning('Standard release workflow requires releasing from "dev" or "main".');
    if (!dryRun) {
      stdout.write('\x1B[33mDo you want to proceed anyway? [y/N]: \x1B[0m');
      final answer = stdin.readLineSync()?.trim().toLowerCase();
      if (answer != 'y' && answer != 'yes') {
        _error('Release aborted.');
        exit(1);
      }
    }
  }

  // 3. Read pubspec.yaml to get current version
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

  // 4. Compute new version and build number
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

  // 5. Run tests and static checks
  if (!skipTests) {
    print('\x1B[1;34m==> Running pre-release checks (analyze, test)...\x1B[0m');
    final analyzeResult = await _runCommand('fvm', ['dart', 'analyze']);
    if (analyzeResult != 0) {
      _error('Pre-release static analysis failed. Aborting release.');
      exit(analyzeResult);
    }
    print('\x1B[32m✔ Static analysis clean.\x1B[0m');

    final testResult = await _runCommand('fvm', ['flutter', 'test']);
    if (testResult != 0) {
      _error('Pre-release tests failed. Aborting release.');
      exit(testResult);
    }
    print('\x1B[32m✔ Tests passed.\x1B[0m\n');
  } else {
    _warning('Pre-release tests skipped (--skip-tests).');
  }

  if (dryRun) {
    print('\x1B[1;33m[DRY RUN] Release flow preview:\x1B[0m');
    if (currentBranch == 'dev') {
      print('  1. git fetch origin');
      print('  2. git checkout main && git pull origin main');
      print('  3. git merge dev --no-edit');
    } else {
      print('  1. git fetch origin && git pull origin main');
    }
    print('  4. Update files on main:');
    print('     - pubspec.yaml -> version: $newFullVersion');
    print('     - lib/core/config/app_config.dart -> version: $newSemver, buildNumber: $newBuildNumber');
    print('     - packaging/windows/inno_setup.iss -> MyAppVersion: $newSemver');
    print('  5. git commit -m "chore(release): bump version to v$newSemver"');
    print('  6. git tag -a v$newSemver -m "Release v$newSemver"');
    if (currentBranch == 'dev') {
      print('  7. git checkout dev && git merge main --no-edit');
      print('  8. Push:');
      print('     - git push origin main');
      print('     - git push origin dev');
      print('     - git push origin v$newSemver');
    } else {
      print('  7. Push:');
      print('     - git push origin main');
      print('     - git push origin v$newSemver');
    }
    print('\n\x1B[32mDry run complete. No changes were made.\x1B[0m');
    exit(0);
  }

  // 6. Branch sync & checkout main if starting from dev
  final isDev = (currentBranch == 'dev');
  if (isDev) {
    print('\x1B[1;34m==> Synchronizing branches: dev -> main...\x1B[0m');
    await _runCommand('git', ['fetch', 'origin']);

    int code = await _runCommand('git', ['checkout', 'main']);
    if (code != 0) {
      _error('Failed to checkout main. Aborting release.');
      exit(1);
    }

    code = await _runCommand('git', ['pull', 'origin', 'main']);
    if (code != 0) {
      _error('Failed to pull latest main from origin.');
      await _runCommand('git', ['checkout', 'dev']);
      exit(1);
    }

    code = await _runCommand('git', ['merge', 'dev', '--no-edit']);
    if (code != 0) {
      _error('Merge conflict or failure merging dev into main.');
      _error('Aborting merge. Returning to dev branch.');
      await _runCommand('git', ['merge', '--abort']);
      await _runCommand('git', ['checkout', 'dev']);
      exit(1);
    }
    print('\x1B[32m✔ Merged dev into main successfully.\x1B[0m\n');
  }

  // 7. Update files on main
  print('\x1B[1;34m==> Updating version metadata across codebase...\x1B[0m');

  // Re-read pubspec on main to avoid any drift
  final currentPubspecContent = pubspecFile.readAsStringSync();
  final updatedPubspec = currentPubspecContent.replaceFirst(
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
      RegExp(r"static const String defaultVersion = '[^']+';"),
      "static const String defaultVersion = '$newSemver';",
    );
    configContent = configContent.replaceFirst(
      RegExp(r"static const int defaultBuildNumber = \d+;"),
      "static const int defaultBuildNumber = $newBuildNumber;",
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

  // 8. Git commit & tag on main
  print('\n\x1B[1;34m==> Creating release commit and tag on main...\x1B[0m');

  final addCode = await _runCommand('git', [
    'add',
    'pubspec.yaml',
    'lib/core/config/app_config.dart',
    'packaging/windows/inno_setup.iss',
  ]);
  if (addCode != 0) {
    _error('Failed to stage version files.');
    if (isDev) await _runCommand('git', ['checkout', 'dev']);
    exit(1);
  }

  final commitCode = await _runCommand('git', [
    'commit',
    '-m',
    'chore(release): bump version to v$newSemver',
  ]);
  if (commitCode != 0) {
    _error('Failed to commit version bump.');
    if (isDev) await _runCommand('git', ['checkout', 'dev']);
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
    if (isDev) await _runCommand('git', ['checkout', 'dev']);
    exit(1);
  }

  print('\x1B[32m✔ Successfully committed and tagged v$newSemver on main\x1B[0m\n');

  // 9. If started from dev, switch back to dev and sync release commit
  if (isDev) {
    print('\x1B[1;34m==> Syncing release commit back to dev...\x1B[0m');
    int code = await _runCommand('git', ['checkout', 'dev']);
    if (code == 0) {
      code = await _runCommand('git', ['merge', 'main', '--no-edit']);
      if (code == 0) {
        print('\x1B[32m✔ dev is now up-to-date with main.\x1B[0m\n');
      } else {
        _warning('Could not automatically merge main back to dev. Please run: git merge main');
      }
    }
  }

  // 10. Push to remote
  bool doPush = autoPush;
  if (!doPush) {
    stdout.write('\x1B[1;33mPush commits (main, dev) and tag (v$newSemver) to origin now? [y/N]: \x1B[0m');
    final answer = stdin.readLineSync()?.trim().toLowerCase();
    doPush = (answer == 'y' || answer == 'yes');
  }

  if (doPush) {
    print('\x1B[1;34m==> Pushing to origin...\x1B[0m');
    final pushMainCode = await _runCommand('git', ['push', 'origin', 'main']);
    if (pushMainCode != 0) {
      _error('Failed to push main to origin.');
      _printManualPushInstructions(newSemver, isDev: isDev);
      exit(1);
    }

    if (isDev) {
      final pushDevCode = await _runCommand('git', ['push', 'origin', 'dev']);
      if (pushDevCode != 0) {
        _error('Failed to push dev to origin.');
        _printManualPushInstructions(newSemver, isDev: isDev);
        exit(1);
      }
    }

    final pushTagCode = await _runCommand('git', ['push', 'origin', 'v$newSemver']);
    if (pushTagCode != 0) {
      _error('Failed to push tag v$newSemver to origin.');
      _printManualPushInstructions(newSemver, isDev: isDev);
      exit(1);
    }
    print('\x1B[32m✔ Pushed main, ${isDev ? 'dev, ' : ''}and tag v$newSemver to origin!\x1B[0m');
    print('\x1B[1;35m🚀 GitHub Actions workflow has been triggered.\x1B[0m');
    print('Track release progress: https://github.com/zoroneo/flanki/actions\n');
  } else {
    _printManualPushInstructions(newSemver, isDev: isDev);
  }
}

void _printManualPushInstructions(String semver, {required bool isDev}) {
  print('\n\x1B[33mRelease commit and tag v$semver are created locally. To push and trigger CI/CD, run:\x1B[0m');
  print('  git push origin main');
  if (isDev) {
    print('  git push origin dev');
  }
  print('  git push origin v$semver');
  print('  (hoặc: make release-push)\n');
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
  --push, -p         Automatically push commits and tag to origin without prompt.
  --skip-tests       Skip running tests before release.
  --dry-run          Preview changes without modifying files or git branches/tags.
  -h, --help         Show this help message.

Examples:
  make release                  # Bump patch from dev -> merge to main -> tag & prompt push
  make release v=minor          # Bump minor (1.0.2 -> 1.1.0)
  make release v=1.2.0          # Set explicit version
  make release ARGS="--push"    # Auto push to GitHub to trigger CI/CD build
  make release ARGS="--dry-run" # Preview release operations safely
''');
}
