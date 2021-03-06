import 'dart:io';
import 'package:brick_build/src/annotation_super_generator.dart';
import 'package:path/path.dart' as p;
import 'package:build/build.dart';
import 'package:source_gen/source_gen.dart';
import 'package:logging/logging.dart';
export 'package:brick_build/src/annotation_super_generator.dart';

final brickLogger = Logger('Brick');

abstract class BaseBuilder implements Builder {
  /// The generator used to discover annotated classes
  final AnnotationSuperGenerator generator;

  Logger get logger => brickLogger;

  /// The cached file this will produce
  String get outputExtension;

  @override
  Map<String, List<String>> get buildExtensions => {
        "$aggregateExtension.dart": ["${BaseBuilder.aggregateExtension}$outputExtension"]
      };

  BaseBuilder(this.generator);

  static const aggregateExtension = ".brick_aggregate";

  /// Classes with the class-level annotation. For example, `ConnectOfflineFirst`.
  Future<Iterable<AnnotatedElement>> getAnnotatedElements(BuildStep buildStep) async {
    final libraryReader = LibraryReader(await buildStep.inputLibrary);
    return libraryReader.annotatedWith(generator.typeChecker);
  }

  /// Replace contents of file
  Future<File> replaceWithinFile(String path, Pattern from, String to) async {
    final file = File(p.join("lib", "app", path));
    final fileExists = await file.exists();
    if (!fileExists) {
      return null;
    }
    final contents = await file.readAsString();
    final replacedContents = contents.replaceAll(from, to);
    final writtenFile = await file.writeAsString(replacedContents);
    return writtenFile;
  }

  /// Create or write to file.
  Future<File> manuallyUpsertAppFile(String path, String contents) async {
    final dirName = path.split("/").first;

    if (!dirName.contains(".dart")) {
      final dir = Directory(p.join("lib", "app", dirName));
      final dirExists = await dir.exists();
      if (!dirExists) {
        await dir.create();
      }
    }

    final newFile = File(p.join("lib", "app", path));
    final fileExists = await newFile.exists();
    if (!fileExists) {
      await newFile.create();
    }
    final writtenFile = await newFile.writeAsString(contents);
    return writtenFile;
  }

  /// Stop stopwatch and conditionally format elapsed time as seconds or ms
  String stopwatchToSeconds(Stopwatch stopwatch) {
    stopwatch.stop();
    final milliseconds = stopwatch.elapsedMilliseconds;

    if (milliseconds > 1000) {
      return (milliseconds / 1000).toStringAsFixed(2) + "s";
    } else {
      return "${milliseconds}ms";
    }
  }

  /// After a task has completed, log time to completion.
  void logStopwatch(String task, Stopwatch stopwatch) {
    final elapsedSeconds = stopwatchToSeconds(stopwatch);
    logger.info("$task, took $elapsedSeconds");
  }
}
