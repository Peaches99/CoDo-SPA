class FeatureItem {
  final String name;
  final String description;
  final List<ScenarioItem> scenarios;

  FeatureItem(this.name, this.description, this.scenarios);

  factory FeatureItem.fromJson(Map json) {
    List<ScenarioItem> scens = [];
    json["Scenarios"].forEach((scen) {
      scens.add(ScenarioItem.fromJson(scen));
    });
    return FeatureItem(json['FeatureName'], json['Description'], scens);
  }
}

class ScenarioItem {
  final String name;
  final SyntaxItem syntax;

  const ScenarioItem(this.name, this.syntax);

  factory ScenarioItem.fromJson(Map json) {
    return ScenarioItem(json["Scenario"], SyntaxItem.fromJson(json["Syntax"]));
  }
}

class SyntaxItem {
  final String given;
  final String when;
  final String then;

  const SyntaxItem(this.given, this.when, this.then);

  factory SyntaxItem.fromJson(Map json) {
    return SyntaxItem(json["Given"], json["When"], json["Then"]);
  }
}
