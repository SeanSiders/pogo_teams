// Flutter Imports
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Local Imports
import '../tools/pair.dart';
import '../data/pokemon/pokemon.dart';
import '../data/cup.dart';
import '../data/masters/type_master.dart';
import '../data/pokemon/typing.dart';
import '../widgets/nodes/pokemon_nodes.dart';
import '../widgets/buttons/exit_button.dart';
import '../configs/size_config.dart';

/*
-------------------------------------------------------------------------------
Based on the PokemonTeam provided, various analysis will be displayed to the
user. The user will also be able to make adjustments to the team, and see
realtime analysis updates.
-------------------------------------------------------------------------------
*/

class TeamAnalysis extends StatelessWidget {
  TeamAnalysis({
    Key? key,
    required this.pokemonTeam,
    required this.selectedCup,
  }) : super(key: key);

  List<Pokemon> pokemonTeam;
  final Cup selectedCup;

  @override
  Widget build(BuildContext context) {
    final double blockSize = SizeConfig.blockSizeHorizontal;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Selected cup
            Container(
              alignment: Alignment.center,
              width: SizeConfig.screenWidth * .95,
              height: SizeConfig.blockSizeVertical * 4.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white,
                  width: SizeConfig.blockSizeHorizontal * .4,
                ),
                borderRadius: BorderRadius.circular(100.0),
                color: selectedCup.cupColor,
              ),
              child: Text(selectedCup.title),
            ),

            // Spacer
            SizedBox(
              height: blockSize * 3.5,
            ),

            // List of the selected Pokemon team and their selected moves
            Flexible(
              child: SizedBox(
                width: SizeConfig.screenWidth * .95,
                child: ListView(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    children: pokemonTeam.map((pokemon) {
                      return Padding(
                          padding: EdgeInsets.only(bottom: blockSize * 2.0),
                          child: CompactPokemonNode(pokemon: pokemon));
                    }).toList()),
              ),
            ),

            // Spacer
            SizedBox(
              height: blockSize * 3.5,
            ),

            Text('THREATS',
                style: TextStyle(
                  letterSpacing: SizeConfig.blockSizeHorizontal * 5.0,
                  fontSize: SizeConfig.h1,
                  fontWeight: FontWeight.bold,
                )),

            // Spacer
            SizedBox(
              height: blockSize * 3.5,
            ),

            EffectivenessAnalysis(pokemonTeam: pokemonTeam),
          ],
        ),
      ),
      floatingActionButton: ExitButton(
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class EffectivenessAnalysis extends StatelessWidget {
  const EffectivenessAnalysis({
    Key? key,
    required this.pokemonTeam,
  }) : super(key: key);

  final List<Pokemon> pokemonTeam;

  // Determine the type effectiveneses of this team
  Widget _threats() {
    final int teamLen = pokemonTeam.length;

    List<Pair<double, Type>> teamEffectiveness =
        TypeMaster.getNetTypeEffectiveness(pokemonTeam);

    teamEffectiveness.removeWhere((pair) => pair.a <= teamLen);

    // Sort by teamEffectiveness and typeList by highest threat
    teamEffectiveness.sort((prev, curr) => ((curr.a - prev.a) * 1000).round());

    // DEBUG
    //print('DEFENSE EFFECTIVENESS');
    //teamEffectiveness.forEach((i) => print(i.b.typeKey + " " + i.a.toString()));

    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(
          left: SizeConfig.blockSizeHorizontal * 3.0,
          right: SizeConfig.blockSizeHorizontal * 3.0,
        ),
        child: GridView.count(
          shrinkWrap: true,
          crossAxisSpacing: SizeConfig.blockSizeHorizontal * 5.0,
          mainAxisSpacing: SizeConfig.blockSizeVertical * 4.0,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: teamEffectiveness.length,
          children: teamEffectiveness.map((pair) {
            return pair.b.getIcon();
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _threats();
  }
}
