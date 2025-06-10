class RecensementData {
  final String commune;
  final List<String> quartiers;

  RecensementData({
    required this.commune,
    required this.quartiers,
  });

}

class QuartierSelection {
  final String commune;
  final String quartier;

  QuartierSelection({
    required this.commune,
    required this.quartier,
  });

  Map<String, dynamic> toJson() {
    return {
      'commune': commune,
      'quartier': quartier,
    };
  }
}
