import 'dart:async';
import 'package:analyzer/dart/element/element.dart';
import 'package:build/build.dart' show BuildStep;
import 'package:merging_builder/merging_builder.dart';
import 'package:navigation_generator/annotations/annotations.dart';
import 'package:navigation_generator/models/class_definition.dart';
import 'package:source_gen/source_gen.dart';

class NavigationGenerator extends MergingGenerator<ClassDefinition?, Navigation> {
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

    /// material import required for access BuildContext
    buffer.writeln("import 'package:flutter/material.dart';");
    List<ClassDefinition?> classes = [];
    await for (final values in stream) {
      classes.add(values);

      /// import required files for access generated code
      buffer.writeln("import '${values!.classPath}';");
    }

    ///class name
    buffer.writeln('class AppNavigation {');

    ///method to pop user using provided context
    buffer.writeln(
        'static void pop(BuildContext context){Navigator.pop(context);}');

    ///common and private method to navigate all method call this method for navigation
    buffer
        .writeln(' static void _navigate(BuildContext context,Widget child){');
    buffer.writeln('Navigator.push(');
    buffer.writeln('context,');
    buffer.writeln('MaterialPageRoute(builder: (context) => child));}');

    for (final value in classes) {
      /// description of the class
      if (value!.description != null && value.description!.isNotEmpty) {
        buffer.writeln("//${value.description}");
      }

      if (value.fields!.isNotEmpty) {
        buffer.writeln(
            'static void navigateTo${value.constructors!.first.displayName}(BuildContext context,');
        List<String> constructorParameters =
            _getConstructorParameters(value.constructors!.first.parameters);
        buffer.write(constructorParameters.join(","));
        buffer.write("){");
        buffer.writeln(
            "_navigate(context,${value.constructors!.first.displayName}(");
        List<String> parameters =
            _getParameterList(value.constructors!.first.parameters);
        buffer.write(parameters.join(","));
        buffer.writeln("));");
        buffer.writeln('}');
      } else {
        buffer.writeln(
            'static void navigateTo${value.constructors!.first.displayName}(BuildContext context,');
        buffer.write("){");
        buffer.writeln(
            "_navigate(context,${value.constructors!.first.displayName}());");
        buffer.writeln("}");
      }
    }
    buffer.writeln('}');
    return buffer.toString();
  }

  /// _getParameterList return List<String> which contains parameters required for passing to widget to be navigated
  List<String> _getParameterList(List<ParameterElement> parameterElement) {
    List<String> parameters = [];
    for (var e in parameterElement) {
      if (e.name.toLowerCase() != 'key') {
        if (e.isOptional || e.isRequiredNamed) {
          parameters.add("${e.name}: ${e.name}");
        } else {
          parameters.add(e.name);
        }
      }
    }
    return parameters;
  }

  /// _getConstructorParameters return List<String> which contains parameters required to build method constructor
  List<String> _getConstructorParameters(List<ParameterElement> parameters) {
    List<String> constructorParameters = [];
    for (var e in parameters) {
      String value = '';
      if (e.type.isDartCoreString) {
        value = 'String ${e.displayName}';
        if (e.isOptional) {
          value = 'String? ${e.displayName}';
        }
      } else if (e.type.isDartCoreInt) {
        value = 'int ${e.displayName}';
        if (e.isOptional) {
          value = 'int? ${e.displayName}';
        }
      } else if (e.type.isDartCoreBool) {
        value = 'bool ${e.displayName}';
        if (e.isOptional) {
          value = 'bool? ${e.displayName}';
        }
      } else if (e.type.isDartCoreDouble) {
        value = 'double ${e.displayName}';
        if (e.isOptional) {
          value = 'double? ${e.displayName}';
        }
      } else if (e.type.isDartCoreList || e.type.isDartCoreObject) {
        value =
            '${e.type.getDisplayString(withNullability: true)} ${e.displayName}';
      }
      if (value.isNotEmpty) {
        constructorParameters.add(value);
      }
    }
    return constructorParameters;
  }
}
