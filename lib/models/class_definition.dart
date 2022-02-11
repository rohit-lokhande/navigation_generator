import 'package:analyzer/dart/element/element.dart';

class ClassDefinition {
  final String displayName;
  final List<ConstructorElement>? constructors;
  final List<FieldElement>? fields;
  final String? route;
  final String classPath;
  final String? description;

  ClassDefinition({
    required this.displayName,
    required this.classPath,
    this.constructors,
    this.fields,
    this.route,
    this.description,
  });
}
