import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart' show BuildStep;
import 'package:merging_builder/merging_builder.dart';
import 'package:route_generator/annotations/annotations.dart';
import 'package:route_generator/models/class_definition.dart';
import 'package:source_gen/source_gen.dart';

class RoutesGenerator extends MergingGenerator<ClassDefinition?, AppRoute> {
  @override
  ClassDefinition? generateStreamItemForAnnotatedElement(
    Element element,
    ConstantReader annotation,
    BuildStep buildStep,
  ) {
    if (element is ClassElement) {
      return ClassDefinition(
          displayName: element.displayName,
          classPath: element.source.uri.toString(),
          route: annotation.objectValue.getField('path')!.toStringValue(),
          description:
              annotation.objectValue.getField('description')!.toStringValue(),
          constructors: element.constructors,
          fields: element.fields);
    }
    return null;
  }

  /// Returns the merged content.
  @override
  FutureOr<String> generateMergedContent(
      Stream<ClassDefinition?> stream) async {
    final buffer = StringBuffer();
    buffer.writeln("import 'package:flutter/material.dart';");
    List<ClassDefinition?> classes = [];
    await for (final values in stream) {
      classes.add(values);
      buffer.writeln("import '${values!.classPath}';");
    }
    buffer.writeln('class Routes {');
    for (final value in classes) {
      buffer.writeln("//${value!.description}");
      if (value.fields!.isNotEmpty) {
        buffer.writeln(
            'static void navigateTo${value.constructors!.first.displayName}(BuildContext context,');
        List<String> constructorParameters =
            _getConstructorParameters(value.constructors!.first.parameters);
        buffer.write(constructorParameters.join(","));
        buffer.write("){");
        buffer.writeln(
            "Navigator.push(context,MaterialPageRoute(builder: (context) =>  ${value.constructors!.first.displayName}(");
        List<String> parameters =
            _getParameterList(value.constructors!.first.parameters);
        buffer.write(parameters.join(","));
        buffer.write(')),);');
        buffer.writeln('}');
      } else {
        buffer.writeln(
            'static void navigateTo${value.constructors!.first.displayName}(BuildContext context,');
        buffer.write("){");
        buffer.writeln(
            "Navigator.push(context,MaterialPageRoute(builder: (context) =>  ${value.constructors!.first.displayName}(");
        buffer.write(')),);');
        buffer.writeln('}');
      }
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  List<String> _getParameterList(List<ParameterElement> parameterElement) {
    List<String> parameters = [];
    for (var e in parameterElement) {
      if (e.name.toLowerCase() != 'key') {
        if (e.isOptional) {
          parameters.add("${e.name}: ${e.name}");
        } else if (e.isRequiredNamed) {
          parameters.add("${e.name}: ${e.name}");
        } else {
          parameters.add(e.name);
        }
      }
    }
    return parameters;
  }

  List<String> _getConstructorParameters(List<ParameterElement> parameters) {
    List<String> constructorParameters = [];
    for (var e in parameters) {
      if (e.type.isDartCoreString && e.isOptional) {
        constructorParameters.add('String? ${e.displayName}');
      } else if (e.type.isDartCoreInt) {
        constructorParameters.add('int ${e.displayName}');
      } else if (e.type.isDartCoreBool) {
        constructorParameters.add('bool ${e.displayName}');
      } else if (e.type.isDartCoreDouble) {
        constructorParameters.add('double ${e.displayName}');
      } else if (e.type.isDartCoreList || e.type.isDartCoreObject) {
        constructorParameters.add(
            '${e.type.getDisplayString(withNullability: false)} ${e.displayName}');
      }
    }
    return constructorParameters;
  }
}
