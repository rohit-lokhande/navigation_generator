import 'package:build/build.dart';
import 'package:merging_builder/merging_builder.dart';
import 'package:route_generator/generators/routes_generator.dart';
import 'package:route_generator/models/class_definition.dart';

Builder routeBuilder(BuilderOptions options) {
  final defaultOptions = BuilderOptions({
    'input_files': 'lib/*.dart',
    'output_file': 'lib/output.dart',
    'sort_assets': true,
  });

  // Apply user set options.
  options = defaultOptions.overrideWith(options);
  return MergingBuilder<ClassDefinition?, LibDir>(
    generator: RoutesGenerator(),
    inputFiles: options.config['input_files'],
    outputFile: options.config['output_file'],
    sortAssets: options.config['sort_assets'],
  );
}