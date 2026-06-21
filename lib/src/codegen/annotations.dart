/// Annotations for optional hand-maintained codegen hints.
library;

class ApitoModel {
  const ApitoModel(this.name);
  final String name;
}

class ApitoField {
  const ApitoField(this.name, {this.type = 'string', this.required = false});
  final String name;
  final String type;
  final bool required;
}
