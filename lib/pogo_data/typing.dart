// Local
import '../modules/globals.dart';
import '../modules/pokemon_types.dart';

/*
-------------------------------------------------------------------------------
Manages a Pokemon's typing which can be exactly 1 or 2 types. This is basically
a helper class that effectively handles the case of a Pokemon with 2 types.
-------------------------------------------------------------------------------
*/

class PokemonTyping {
  PokemonTyping({
    required this.typeA,
    required this.typeB,
  });

  factory PokemonTyping.fromJson(Map<String, dynamic> json) {
    return PokemonTyping(
      typeA: PokemonTypes.typeMap[json['typeA'] as String]!,
      typeB: json.containsKey('typeB')
          ? PokemonTypes.typeMap[json['typeB'] as String]!
          : null,
    );
  }

  final PokemonType typeA;
  final PokemonType? typeB;

  bool isMonoType() {
    return typeB == null;
  }

  bool contains(PokemonType type) {
    return (typeA.isSameType(type) || typeB != null && typeB!.isSameType(type));
  }

  // Get defense effectiveness of all types on this typing
  List<double> get defenseEffectiveness {
    if (isMonoType()) return typeA.getDefenseEffectiveness();

    List<double> aEffectiveness = typeA.getDefenseEffectiveness();
    List<double>? bEffectiveness = typeB?.getDefenseEffectiveness();

    // Calculate duo-type effectiveness
    for (int i = 0; i < Globals.typeCount; ++i) {
      aEffectiveness[i] *= bEffectiveness![i];
    }

    return aEffectiveness;
  }

  num getEffectivenessFromType(PokemonType type) {
    if (isMonoType()) {
      return PokemonTypes.effectivenessMaster[typeA.typeId]![type.typeId]![1];
    }

    return PokemonTypes.effectivenessMaster[typeA.typeId]![type.typeId]![1] *
        PokemonTypes.effectivenessMaster[typeB?.typeId]![type.typeId]![1];
  }

  @override
  String toString() {
    if (isMonoType()) {
      return typeA.typeId;
    }

    return '${typeA.typeId} / ${typeB?.typeId}';
  }
}

/*
Manages all data cooresponding to a single type. This can be a type from a
Pokemon's duo / mono typing or a Pokemon move.
*/
class PokemonType {
  PokemonType({required this.typeId}) {
    effectivenessMap = PokemonTypes.getEffectivenessMap(typeId);
  }

  static final PokemonType none = PokemonType(typeId: 'none');

  final String typeId;

  // The offensive and defensive effectivness of this type to all types
  // [0] : offensive
  // [1] : defensive
  late final Map<String, List<double>> effectivenessMap;

  bool isSameType(PokemonType other) {
    return typeId == other.typeId;
  }

  bool isWeakTo(PokemonType type) {
    return effectivenessMap[type.typeId]![1] > 1.0;
  }

  List<double> getDefenseEffectiveness() {
    List<double> effectiveness =
        List.generate(Globals.typeCount, (index) => 0.0);

    int i = 0;

    for (List<double> effectivenessVal in effectivenessMap.values) {
      effectiveness[i] = effectivenessVal[1];
      ++i;
    }

    return effectiveness;
  }

  List<double> getOffenseEffectiveness() {
    List<double> effectiveness =
        List.generate(Globals.typeCount, (index) => 0.0);

    int i = 0;

    for (List<double> effectivenessVal in effectivenessMap.values) {
      effectiveness[i] = effectivenessVal[0];
      ++i;
    }

    return effectiveness;
  }
}
