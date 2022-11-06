// Flutter Imports
import 'package:flutter/material.dart';

// Local Imports
import 'empty_node.dart';
import 'move_node.dart';
import '../../game_objects/pokemon.dart';
import '../../game_objects/cup.dart';
import '../pvp_stats.dart';
import '../dropdowns/move_dropdowns.dart';
import '../traits_icons.dart';
import '../colored_container.dart';
import '../formatted_pokemon_name.dart';
import '../../modules/data/stats.dart';
import '../../modules/ui/sizing.dart';
import '../../modules/ui/pogo_colors.dart';
import '../../modules/ui/pogo_icons.dart';

/*
-------------------------------------------------------------------- @PogoTeams
Any Pokemon information being displayed in the app is done so through a
PokemonNode. The node can take many different forms depending on the context.
-------------------------------------------------------------------------------
*/

class PokemonNode extends StatelessWidget {
  PokemonNode.square({
    Key? key,
    required this.pokemon,
    this.onPressed,
    this.onEmptyPressed,
    this.emptyTransparent = false,
    this.padding,
  }) : super(key: key) {
    width = Sizing.blockSizeHorizontal * 25.0;
    height = Sizing.blockSizeHorizontal * 25.0;
    cup = null;
    dropdowns = false;
    rating = false;

    if (pokemon == null) return;

    body = _SquareNodeBody(pokemon: pokemon!);
  }

  PokemonNode.small({
    Key? key,
    required this.pokemon,
    this.onPressed,
    this.onEmptyPressed,
    this.onMoveChanged,
    this.emptyTransparent = false,
    this.padding,
    this.dropdowns = true,
    this.rating = false,
  }) : super(key: key) {
    width = double.infinity;
    height = Sizing.blockSizeVertical * 15.0;

    body = _SmallNodeBody(
      pokemon: pokemon!,
      dropdowns: dropdowns,
      onMoveChanged: onMoveChanged,
      rating: rating,
    );
  }

  PokemonNode.large({
    Key? key,
    required this.pokemon,
    this.onPressed,
    this.onEmptyPressed,
    this.onMoveChanged,
    this.cup,
    this.footer,
    this.emptyTransparent = false,
    this.padding,
  }) : super(key: key) {
    width = double.infinity;
    height = Sizing.blockSizeVertical * 22.0;
    dropdowns = false;
    rating = false;

    if (pokemon == null) return;

    body = _LargeNodeBody(
      pokemon: pokemon!,
      cup: cup,
      footer: footer,
      onMoveChanged: onMoveChanged,
    );
  }

  final Pokemon? pokemon;
  late final VoidCallback? onPressed;
  late final VoidCallback? onEmptyPressed;
  late final VoidCallback? onMoveChanged;

  late final Cup? cup;

  late final Widget body;
  late final Widget? footer;
  final bool emptyTransparent;
  final EdgeInsets? padding;
  late final double width;
  late final double height;
  late final bool dropdowns;
  late final bool rating;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: pokemon == null
          ? EmptyNode(
              onPressed: onEmptyPressed,
              emptyTransparent: emptyTransparent,
            )
          : ColoredContainer(
              padding: padding ??
                  EdgeInsets.only(
                    top: Sizing.blockSizeVertical * .5,
                    left: Sizing.blockSizeHorizontal * 2.0,
                    right: Sizing.blockSizeHorizontal * 2.0,
                    bottom: Sizing.blockSizeVertical * .5,
                  ),
              pokemon: pokemon!,
              child: onPressed == null
                  ? body
                  : MaterialButton(
                      onPressed: onPressed,
                      child: body,
                    ),
            ),
    );
  }
}

class _SquareNodeBody extends StatelessWidget {
  const _SquareNodeBody({
    Key? key,
    required this.pokemon,
  }) : super(key: key);

  final Pokemon pokemon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Pokemon name
        FormattedPokemonName(
          name: pokemon.name,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headline6,
          suffixStyle: Theme.of(context).textTheme.bodyMedium,
        ),

        // A line divider
        Divider(
          color: Colors.white,
          thickness: Sizing.blockSizeHorizontal * 0.2,
        ),

        TraitsIcons(
          pokemon: pokemon,
          scale: .7,
        ),

        MoveDots(
            moveColors: PogoColors.getPokemonMovesetColors(pokemon.moveset)),
      ],
    );
  }
}

class _SmallNodeBody extends StatelessWidget {
  const _SmallNodeBody({
    Key? key,
    required this.pokemon,
    required this.dropdowns,
    required this.onMoveChanged,
    required this.rating,
  }) : super(key: key);

  final Pokemon pokemon;
  final bool dropdowns;
  final VoidCallback? onMoveChanged;
  final bool rating;

  // Display the Pokemon's name perfect PVP ivs and typing icon(s)
  // If rating is true, place the rating in the upper left corner
  Row _buildNodeHeader(BuildContext context, Pokemon pokemon) {
    if (rating) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pokemon cup - specific rating
          // Used for the ratings pages
          Text(
            pokemon.ratingString,
            style: Theme.of(context).textTheme.headline5,
          ),

          // Pokemon name
          Text(
            pokemon.name,
            style: Theme.of(context).textTheme.headline5,
          ),

          // Traits Icons
          TraitsIcons(pokemon: pokemon),

          // Typing icon(s)
          Container(
            alignment: Alignment.topRight,
            height: Sizing.blockSizeHorizontal * 8.0,
            child: Row(
              children: PogoIcons.getPokemonTypingIcons(pokemon.typing),
            ),
          ),
        ],
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pokemon name
        Text(
          pokemon.name,
          style: Theme.of(context).textTheme.headline5,
        ),

        // Traits Icons
        TraitsIcons(pokemon: pokemon),

        // Typing icon(s)
        Container(
          alignment: Alignment.topRight,
          height: Sizing.blockSizeHorizontal * 8.0,
          child: Row(
            children: PogoIcons.getPokemonTypingIcons(pokemon.typing),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Sizing.blockSizeVertical * .5,
        left: Sizing.blockSizeHorizontal * 2.0,
        right: Sizing.blockSizeHorizontal * 2.0,
        bottom: Sizing.blockSizeVertical * 1.5,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNodeHeader(context, pokemon),

          // A line divider
          Divider(
            color: Colors.white,
            thickness: Sizing.blockSizeHorizontal * 0.2,
          ),

          // The dropdowns for the Pokemon's moves
          // Defaults to the most meta relavent moves
          dropdowns
              ? MoveDropdowns(
                  pokemon: pokemon,
                  onChanged: onMoveChanged,
                )
              : MoveNodes(pokemon: pokemon),
        ],
      ),
    );
  }
}

class _LargeNodeBody extends StatelessWidget {
  const _LargeNodeBody({
    Key? key,
    required this.pokemon,
    required this.cup,
    required this.footer,
    this.onMoveChanged,
  }) : super(key: key);

  final Pokemon pokemon;
  final Cup? cup;
  final Widget? footer;
  final VoidCallback? onMoveChanged;

  // Display the Pokemon's name perfect PVP ivs and typing icon(s)
  Row _buildNodeHeader(BuildContext context, Pokemon pokemon, Cup? cup) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pokemon name
        Text(
          pokemon.name,
          style: Theme.of(context).textTheme.headline5,
        ),

        // Traits Icons
        TraitsIcons(pokemon: pokemon),

        // The perfect IVs for this Pokemon given the selected cup
        cup == null
            ? Container()
            : PvpStats(
                cp: Stats.calculateCP(pokemon.stats, pokemon.getIvs(cup.cp)),
                ivs: pokemon.getIvs(cup.cp),
              ),

        // Typing icon(s)
        Container(
          alignment: Alignment.topRight,
          height: Sizing.blockSizeHorizontal * 8.0,
          child: Row(
            children: PogoIcons.getPokemonTypingIcons(pokemon.typing),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: Sizing.blockSizeVertical * .5,
        left: Sizing.blockSizeHorizontal * 2.0,
        right: Sizing.blockSizeHorizontal * 2.0,
        bottom: Sizing.blockSizeVertical * .2,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Pokemon name, perfect IVs, and typing icons
          _buildNodeHeader(context, pokemon, cup),

          // A line divider
          Divider(
            color: Colors.white,
            thickness: Sizing.blockSizeHorizontal * 0.2,
          ),

          // The dropdowns for the Pokemon's moves
          // Defaults to the most meta relavent moves
          MoveDropdowns(
            pokemon: pokemon,
            onChanged: onMoveChanged,
          ),

          footer ?? Container(),
        ],
      ),
    );
  }
}
