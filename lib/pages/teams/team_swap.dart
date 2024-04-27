// Flutter
import 'package:flutter/material.dart';

// Local Imports
import '../../app/ui/sizing.dart';
import '../../modules/pogo_repository.dart';
import '../../model/pokemon.dart';
import '../../widgets/buttons/gradient_button.dart';
import '../../widgets/buttons/pokemon_action_button.dart';
import '../../widgets/nodes/pokemon_node.dart';
import '../../model/pokemon_team.dart';

/*
-------------------------------------------------------------------- @PogoTeams
The user will be able to swap any of the current Pokemon in their team with
the swap Pokemon. Movesets may also be edited here.
-------------------------------------------------------------------------------
*/

class TeamSwap extends StatefulWidget {
  const TeamSwap({
    super.key,
    required this.team,
    required this.swap,
  });

  final PokemonTeam team;
  final UserPokemon swap;

  @override
  _TeamSwapState createState() => _TeamSwapState();
}

class _TeamSwapState extends State<TeamSwap> {
  late List<UserPokemon> _pokemonTeam;
  late UserPokemon _swap;

  Widget _buildFooter(BuildContext context, int index) {
    void onSwap(Pokemon swapPokemon) {
      setState(() {
        _pokemonTeam[index] = _swap;
        _swap = swapPokemon as UserPokemon;
      });
    }

    return PokemonActionButton(
      pokemon: _pokemonTeam[index],
      label: 'Swap Out',
      icon: Icon(
        Icons.swap_horiz_rounded,
        size: Sizing.screenWidth(context) * .5,
        color: Colors.white,
      ),
      onPressed: onSwap,
    );
  }

  Widget _buildFloatingActionButton() {
    return GradientButton(
      onPressed: () {
        _saveTeam();
        Navigator.pop(context);
      },
      width: Sizing.screenWidth(context) * .85,
      height: Sizing.screenHeight(context) * .8,
      child: const Icon(
        Icons.clear,
        size: Sizing.icon2,
      ),
    );
  }

  void _saveTeam() {
    PogoRepository.updatePokemonTeamSync(
      widget.team,
      newPokemonTeam: _pokemonTeam,
    );
  }

  Widget _buildPokemonNode(int index) {
    return PokemonNode.large(
      context: context,
      pokemon: _pokemonTeam[index],
      footer: _buildFooter(context, index),
    );
  }

  @override
  void initState() {
    super.initState();
    _pokemonTeam = widget.team.getOrderedPokemonList();
    _swap = widget.swap;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        bottom: false,
        left: false,
        right: false,
        child: Padding(
          padding: EdgeInsets.only(
            left: Sizing.screenWidth(context) * .2,
            right: Sizing.screenWidth(context) * .2,
          ),
          child: Column(
            children: [
              // The Pokemon to swap out
              Padding(
                padding: const EdgeInsets.only(
                  top: 12.0,
                  bottom: 12.0,
                ),
                child: PokemonNode.small(
                  context: context,
                  pokemon: _swap,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 12.0,
                ),
                child: Text(
                  'Team Swap',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    // List of the current selected team
                    ListView.builder(
                      shrinkWrap: true,
                      itemCount: _pokemonTeam.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(
                            top: Sizing.screenHeight(context) * .05,
                            bottom: Sizing.screenHeight(context) * .05,
                          ),
                          child: Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12.0,
                              ),
                              child: index == _pokemonTeam.length - 1
                                  ? Padding(
                                      padding: EdgeInsets.only(
                                          bottom: Sizing.screenHeight(context) *
                                              .11),
                                      child: _buildPokemonNode(index))
                                  : _buildPokemonNode(index)),
                        );
                      },
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
