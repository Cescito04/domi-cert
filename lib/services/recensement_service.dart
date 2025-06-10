import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/recensement_data.dart';

class RecensementService {
  List<RecensementData>? _recensementData;
  List<String>? _communes;

  Future<void> loadData() async {
    if (_recensementData != null) return;

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/data-recensement.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      Map<String, List<String>> communeQuartiersMap = {};
      for (var item in jsonList) {
        String commune = item['COMMUNE'] as String;
        List<String> quartiersToAdd = [];

        var quartierData = item['QUARTIER'];
        if (quartierData is String) {
          quartiersToAdd.add(quartierData);
        } else if (quartierData is List) {
          quartiersToAdd.addAll(List<String>.from(quartierData));
        } else {
          // Gérer les types inattendus, par exemple en ignorant l'entrée
          print(
              'Type inattendu pour le champ QUARTIER : ${quartierData.runtimeType}');
          continue; // Passer à l'entrée suivante
        }

        if (!communeQuartiersMap.containsKey(commune)) {
          communeQuartiersMap[commune] = [];
        }
        for (String q in quartiersToAdd) {
          if (!communeQuartiersMap[commune]!.contains(q)) {
            communeQuartiersMap[commune]!.add(q);
          }
        }
      }

      _recensementData = communeQuartiersMap.entries.map((entry) {
        return RecensementData(
          commune: entry.key,
          quartiers: entry.value,
        );
      }).toList();

      _communes = _recensementData!.map((data) => data.commune).toList();
    } catch (e) {
      throw Exception('Failed to load recensement data: $e');
    }
  }

  List<String> getCommunes() {
    if (_communes == null) {
      throw Exception('Data not loaded. Call loadData() first.');
    }
    return _communes!;
  }

  List<String> getQuartiersForCommune(String commune) {
    if (_recensementData == null) {
      throw Exception('Data not loaded. Call loadData() first.');
    }

    final data = _recensementData!.firstWhere(
      (data) => data.commune == commune,
      orElse: () => throw Exception('Commune not found: $commune'),
    );

    return data.quartiers;
  }
}
