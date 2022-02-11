import 'package:build/build.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:navigation_generator/generators/navigation_generator.dart';
import 'package:navigation_generator/models/class_definition.dart';

Builder navigationBuilder(BuilderOptions options) {
  const defaultOptions =  BuilderOptions({
    'input_files': 'lib/*.dart',
    'output_file': 'lib/output.dart',
    'sort_assets': true,
  });

  // Apply user set options.
  options = defaultOptions.overrideWith(options);
  return MergingBuilder<ClassDefinition?, LibDir>(
    generator: NavigationGenerator(),
    inputFiles: options.config['input_files'],
    outputFile: options.config['output_file'],
    sortAssets: options.config['sort_assets'],
  );
}