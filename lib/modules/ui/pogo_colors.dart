// Flutter Imports
import 'package:flutter/material.dart';

// Local
import '../../pogo_data/pokemon_typing.dart';
import '../../pogo_data/move.dart';

/*
-------------------------------------------------------------------- @PogoTeams
All color association is handled by the maps that are implemented here.
-------------------------------------------------------------------------------
*/

class PogoColors {
  static const Map<String, Color> _typeColors = {
    'normal': Color(0xFFA8A77A),
    'fire': Color(0xFFEE8130),
    'water': Color(0xFF6390F0),
    'electric': Color(0xFFC7B000),
    'grass': Color(0xFF7AC74C),
    'ice': Color(0xFF96D9D6),
    'fighting': Color(0xFFC22E28),
    'poison': Color(0xFFA33EA1),
    'ground': Color(0xFFE2BF65),
    'flying': Color(0xFFA98FF3),
    'psychic': Color(0xFFF95587),
    'bug': Color(0xFFA6B91A),
    'rock': Color(0xFFB6A136),
    'ghost': Color(0xFF735797),
    'dragon': Color(0xFF6F35FC),
    'dark': Color(0xFF705746),
    'steel': Color(0xFFB7B7CE),
    'fairy': Color(0xFFD685AD),
  };

  static Color get defaultTypeColor => Colors.black;
  static Color get defaultCupColor => Colors.cyan;

  static const Map<String, Color> _cupColors = {};

  static Color getPokemonTypeColor(String typeId) =>
      _typeColors[typeId] ?? defaultTypeColor;

  static List<Color> getPokemonTypingColors(PokemonTyping typing) {
    if (typing.isMonoType) {
      return [_typeColors[typing.typeA.typeId] ?? defaultTypeColor];
    }

    return [
      _typeColors[typing.typeA.typeId] ?? defaultTypeColor,
      _typeColors[typing.typeB?.typeId] ?? defaultTypeColor,
    ];
  }

  static List<Color> getPokemonMovesetColors(List<Move> moveset) => moveset
      .map((move) => _typeColors[move.moveId] ?? defaultTypeColor)
      .toList();

  static Color getCupColor(String cupId) =>
      _cupColors[cupId] ?? defaultCupColor;

  static void addCupColor(String cupId, String cupColorHex) {
    _cupColors[cupId] = Color(int.parse(cupColorHex, radix: 16));
  }
}
