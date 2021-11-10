// Dart Imports
import 'dart:ui';

// Flutter Imports
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';

// Local Imports
import '../data/pokemon/pokemon.dart';
import '../data/cup.dart';
import '../data/pokemon/move.dart';
import '../configs/size_config.dart';
import 'colored_container.dart';
import '../screens/pokemon_search.dart';
import '../data/globals.dart' as globals;

/*
-------------------------------------------------------------------------------
The Pokemon Team data model contains a list of 3 nullable Pokemon references
and a Cup reference. This collection represents a single Pokemon PVP Team.
This Pokemon Team can then be used to compute various information throughout
the app.
-------------------------------------------------------------------------------
*/

// The data model for a Pokemon PVP Team
// Every team page manages one instance of this class
class PokemonTeam {
  // The list of 3 pokemon references
  List<Pokemon?> team = List.filled(3, null);

  // The selected PVP cup for this team
  // Defaults to Great League
  Cup cup = globals.gamemaster.cups.firstWhere((cup) => cup.name == 'great');

  // Get the list of non-null pokemon
  List<Pokemon> getPokemonTeam() {
    return team.whereType<Pokemon>().toList();
  }

  // True if there are no pokemon on the team
  bool isEmpty() {
    return team[0] == null && team[1] == null && team[2] == null;
  }

  // Switch to a different cup with the specified cupTitle
  void setCup(String cupTitle) {
    cup = globals.gamemaster.cups.firstWhere((cup) => cup.title == cupTitle);
  }
}

// A single page of 3 TeamNodes to represent a single Pokemon team
class TeamPage extends StatefulWidget {
  const TeamPage({
    Key? key,
    required this.pokemonTeam,
  }) : super(key: key);

  // This team page's Pokemon team
  final PokemonTeam pokemonTeam;

  @override
  _TeamPageState createState() => _TeamPageState();
}

class _TeamPageState extends State<TeamPage>
    with AutomaticKeepAliveClientMixin {
  void _onCupChanged(String? newCup) {
    if (newCup == null) return;

    setState(() {
      widget.pokemonTeam.setCup(newCup);
    });
  }

  void _onLeadChanged(Pokemon? newLead) {
    setState(() {
      widget.pokemonTeam.team[0] = newLead;
    });
  }

  void _onMidChanged(Pokemon? newMid) {
    setState(() {
      widget.pokemonTeam.team[1] = newMid;
    });
  }

  void _onCloserChanged(Pokemon? newCloser) {
    setState(() {
      widget.pokemonTeam.team[2] = newCloser;
    });
  }

  // Keeps page state upon swiping away in PageView
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final team = widget.pokemonTeam.team;
    final cup = widget.pokemonTeam.cup;

    return Padding(
      padding: EdgeInsets.only(
        right: SizeConfig.screenWidth * .025,
        left: SizeConfig.screenWidth * .025,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Dropdown for pvp cup selection
          CupDropdown(
            cup: cup,
            onCupChanged: _onCupChanged,
          ),

          // The 3 TeamNodes
          TeamNode(
            pokemon: team[0],
            cup: cup,
            onNodeChanged: _onLeadChanged,
          ),
          TeamNode(
            pokemon: team[1],
            cup: cup,
            onNodeChanged: _onMidChanged,
          ),
          TeamNode(
            pokemon: team[2],
            cup: cup,
            onNodeChanged: _onCloserChanged,
          ),
        ],
      ),
    );
  }
}

// A single dropdown button to display all pvp cup options.
// The selected cup will affect all meta calculations
// as well as the Pokemon's ideal IVs.
class CupDropdown extends StatefulWidget {
  const CupDropdown({
    Key? key,
    required this.cup,
    required this.onCupChanged,
  }) : super(key: key);

  final Cup cup;
  final void Function(String?) onCupChanged;

  @override
  _CupDropdownState createState() => _CupDropdownState();
}

class _CupDropdownState extends State<CupDropdown>
    with AutomaticKeepAliveClientMixin {
  // List of pvp cups
  final List<Cup> cups = globals.gamemaster.cups;

  // List of pvp cup names
  late final List<String> cupNames = cups.map((cup) => cup.title).toList();

  // List of dropdown menu items
  late final cupOptions =
      cupNames.map<DropdownMenuItem<String>>((String cupName) {
    return DropdownMenuItem(
      value: cupName,
      child: Center(
        child: Text(
          cupName,
          style: TextStyle(
            fontSize: SizeConfig.h2,
          ),
        ),
      ),
    );
  }).toList();

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final _selectedCup = widget.cup;

    return Container(
      alignment: Alignment.center,
      width: SizeConfig.screenWidth * .95,
      height: SizeConfig.blockSizeVertical * 4.5,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: SizeConfig.blockSizeHorizontal * .4,
        ),
        borderRadius: BorderRadius.circular(100.0),
        color: _selectedCup.cupColor,
      ),

      // Cup dropdown button
      child: DropdownButtonHideUnderline(
        child: DropdownButton(
          isExpanded: true,
          value: _selectedCup.title,
          icon: const Icon(Icons.arrow_drop_down),
          style: DefaultTextStyle.of(context).style,
          onChanged: widget.onCupChanged,
          items: cupOptions,
        ),
      ),
    );
  }
}

// A TeamNode is either an EmptyNode or PokemonNode
// An EmptyNode can be tapped by the user to add a Pokemon to it
// After a Pokemon is added it is a PokemonNode
class TeamNode extends StatefulWidget {
  const TeamNode({
    Key? key,
    required this.pokemon,
    required this.cup,
    required this.onNodeChanged,
  }) : super(key: key);

  final Pokemon? pokemon;
  final Cup cup;
  final Function(Pokemon?) onNodeChanged;

  @override
  _TeamNodeState createState() => _TeamNodeState();
}

class _TeamNodeState extends State<TeamNode> {
  // Open a new app page that allows the user to search for a given Pokemon
  // If a Pokemon is selected in that page, the Pokemon reference will be kept
  // The node will then populate all data related to that Pokemon
  _searchMode() async {
    final newPokemon = await Navigator.push(
      context,
      MaterialPageRoute<Pokemon>(builder: (BuildContext context) {
        return const PokemonSearch();
      }),
    );

    // If a pokemon was returned from the search page, update the node
    // Should only be null when the user exits the search page using the app bar
    if (newPokemon != null) {
      widget.onNodeChanged(newPokemon);
    }
  }

  // Revert a PokemonNode back to an EmptyNode
  _clearNode() {
    widget.onNodeChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: SizeConfig.screenWidth * .95,
      height: SizeConfig.screenHeight * .205,

      // If the Pokemon ref is null, build an empty node
      // Otherwise build a Pokemon node with cooresponding data
      child: (widget.pokemon == null
          ? EmptyNode(
              onPressed: _searchMode,
            )
          : PokemonNode(
              pokemon: widget.pokemon as Pokemon,
              cup: widget.cup,
              searchMode: _searchMode,
              clear: _clearNode,
            )),
    );
  }
}

// An icon button indicating that the user can add a Pokemon to the current node
// Once a Pokemon is added, the node will become a PokemonNode
class EmptyNode extends StatelessWidget {
  const EmptyNode({Key? key, required this.onPressed}) : super(key: key);

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final double blockSize = SizeConfig.blockSizeHorizontal;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: blockSize * .8,
        ),
        borderRadius: BorderRadius.circular(blockSize * 2.5),
      ),
      child: IconButton(
        icon: const Icon(
          Icons.add,
        ),
        iconSize: blockSize * 20.0,
        tooltip: 'add a pokemon to your team',
        onPressed: onPressed,
      ),
    );
  }
}

// A node that is occupied by a Pokemon
// All necessary Pokemon GO information will be accessible in this node
class PokemonNode extends StatelessWidget {
  const PokemonNode({
    Key? key,
    required this.pokemon,
    required this.cup,
    required this.searchMode,
    required this.clear,
  }) : super(key: key);

  final Pokemon pokemon;

  final Cup cup;

  // Search for a new Pokemon
  final VoidCallback searchMode;

  // Remove the Pokemon and restore to an EmptyNode
  final VoidCallback clear;

  // Display the Pokemon's name perfect PVP ivs and typing icon(s)
  Row _buildNodeHeader(Pokemon pokemon, BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Pokemon name
        Container(
          padding: EdgeInsets.all(SizeConfig.blockSizeHorizontal * 2.0),
          child: Text(
            pokemon.speciesName,
            style: TextStyle(
              fontSize: SizeConfig.h1,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // The perfect IVs for this Pokemon given the selected cup
        PvpStats(
          perfectStats: pokemon.getPerfectPvpStats(cup.cp),
        ),
        // Typing icon(s)
        Container(
          alignment: Alignment.topRight,
          height: SizeConfig.blockSizeHorizontal * 8.0,
          child: Row(
            children: pokemon.getTypeIcons(iconColor: 'white'),
          ),
        ),
      ],
    );
  }

  // Build a row of icon buttons at the bottom of a Pokemon's Node
  Row _buildNodeFooter() {
    // Size of the footer icons
    final double iconSize = SizeConfig.blockSizeHorizontal * 6.2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: clear,
          icon: const Icon(Icons.clear),
          tooltip: 'remove this pokemon from your team',
          iconSize: iconSize,
        ),
        IconButton(
          onPressed: searchMode,
          icon: const Icon(Icons.swap_horiz),
          tooltip: 'search for a different pokemon',
          iconSize: iconSize,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final double blockSize = SizeConfig.blockSizeHorizontal;

    return ColoredContainer(
      padding: EdgeInsets.only(
        top: blockSize * 1.0,
        right: blockSize * 2.5,
        bottom: blockSize * .5,
        left: blockSize * 2.5,
      ),
      pokemon: pokemon,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Pokemon name, perfect IVs, and typing icons
          _buildNodeHeader(pokemon, context),

          // A line divider
          Divider(
            color: Colors.white,
            thickness: blockSize * 0.2,
          ),

          // The dropdowns for the Pokemon's moves
          // Defaults to the most meta relavent moves
          MoveDropdowns(
            pokemon: pokemon,
            fastMoveNames: pokemon.getFastMoveNames(),
            chargedMoveNames: pokemon.getChargedMoveNames(),
          ),

          // Icon buttons to remove, replace or toggle shadow of a Pokemon
          _buildNodeFooter(),
        ],
      ),
    );
  }
}

// This class manages the 3 dropdown menu buttons cooresponding to a Pokemon's :
// Fast Move
// Charge Move 1
// Charge Move 2
class MoveDropdowns extends StatefulWidget {
  const MoveDropdowns({
    Key? key,
    required this.pokemon,
    required this.fastMoveNames,
    required this.chargedMoveNames,
  }) : super(key: key);

  final Pokemon pokemon;

  // Lists of the moves a Pokemon can learn
  final List<String> fastMoveNames;
  final List<String> chargedMoveNames;

  @override
  _MoveDropdownsState createState() => _MoveDropdownsState();
}

class _MoveDropdownsState extends State<MoveDropdowns> {
  // List of dropdown items for fast moves
  late List<DropdownMenuItem<String>> fastMoveOptions;

  // List of charged move names
  // These lists will filter out the selected move from the other list
  // This prevents the user from selecting the same charge move twice
  late List<String> chargedMoveNamesL;
  late List<String> chargedMoveNamesR;

  // List of dropdown items for charged moves
  late List<DropdownMenuItem<String>> chargedMoveOptionsL;
  late List<DropdownMenuItem<String>> chargedMoveOptionsR;

  // Setup the move dropdown items
  void _initializeMoveData() {
    fastMoveOptions = _generateDropdownItems(widget.fastMoveNames);

    _updateChargedMoveOptions();
  }

  // Upon initial build, update, or dropdown onChanged callback
  // Filter the left and right charged move lists for the dropdowns
  void _updateChargedMoveOptions() {
    chargedMoveNamesL = widget.chargedMoveNames
        .where((moveName) =>
            moveName != widget.pokemon.selectedChargedMoves[1].name)
        .toList();

    chargedMoveNamesR = widget.chargedMoveNames
        .where((moveName) =>
            moveName != widget.pokemon.selectedChargedMoves[0].name)
        .toList();

    chargedMoveOptionsL = _generateDropdownItems(chargedMoveNamesL);
    chargedMoveOptionsR = _generateDropdownItems(chargedMoveNamesR);
  }

  // Generate the list of dropdown items from moveOptionNames
  // Called for each of the 3 move dropdowns
  List<DropdownMenuItem<String>> _generateDropdownItems(
      List<String> moveOptionNames) {
    return moveOptionNames.map<DropdownMenuItem<String>>((String moveName) {
      return DropdownMenuItem<String>(
        value: moveName,
        child: Center(
          child: Text(
            moveName,
            style: TextStyle(
              fontFamily: DefaultTextStyle.of(context).style.fontFamily,
              fontSize: SizeConfig.p,
            ),
          ),
        ),
      );
    }).toList();
  }

  // Called on first build
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    widget.pokemon.initializeMetaMoves();

    _initializeMoveData();
  }

  // Called on any consecutive build
  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);

    widget.pokemon.initializeMetaMoves();
    _initializeMoveData();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MoveNode(
          label: 'F A S T',
          move: widget.pokemon.selectedFastMove,
          options: fastMoveOptions,
          onChanged: (String? newFastMove) {
            setState(() {
              widget.pokemon.updateSelectedFastMove(newFastMove);
            });
          },
        ),
        MoveNode(
          label: 'C H A R G E  1',
          move: widget.pokemon.selectedChargedMoves[0],
          options: chargedMoveOptionsL,
          onChanged: (String? newChargedMove) {
            setState(() {
              widget.pokemon.updateSelectedChargedMove(0, newChargedMove);
              _updateChargedMoveOptions();
            });
          },
        ),
        MoveNode(
          label: 'C H A R G E  2',
          move: widget.pokemon.selectedChargedMoves[1],
          options: chargedMoveOptionsR,
          onChanged: (String? newChargedMove) {
            setState(() {
              widget.pokemon.updateSelectedChargedMove(1, newChargedMove);
              _updateChargedMoveOptions();
            });
          },
        ),
      ],
    );
  }
}

// The label and dropdown button for a given move
// The _MovesDropdownsState will dynamically generate 3 of the nodes
class MoveNode extends StatelessWidget {
  const MoveNode({
    Key? key,
    required this.label,
    required this.move,
    required this.options,
    required this.onChanged,
  }) : super(key: key);

  final String label;
  final Move move;
  final List<DropdownMenuItem<String>> options;
  final Function(String?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Move name
        Text(
          label,
          style: TextStyle(
            fontSize: SizeConfig.h3,
            fontWeight: FontWeight.w600,
            fontStyle: FontStyle.italic,
          ),
        ),

        // Dropdown button
        Container(
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
              isExpanded: true,
              value: move.name,
              icon: const Icon(Icons.arrow_drop_down),
              style: DefaultTextStyle.of(context).style,
              items: options,
              onChanged: onChanged,
            ),
          ),
          margin: EdgeInsets.only(top: SizeConfig.blockSizeVertical * .7),
          width: SizeConfig.screenWidth * .28,
          height: SizeConfig.blockSizeVertical * 3.5,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.white,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(100.0),
            color: move.type.typeColor,
          ),
        ),
      ],
    );
  }
}

class PvpStats extends StatelessWidget {
  const PvpStats({
    Key? key,
    required this.perfectStats,
  }) : super(key: key);

  final List<num> perfectStats;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'CP ' + perfectStats[4].toString(),
          style: TextStyle(
            letterSpacing: SizeConfig.blockSizeHorizontal * .7,
            fontSize: SizeConfig.p,
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          perfectStats[1].toString() +
              ' | ' +
              perfectStats[2].toString() +
              ' | ' +
              perfectStats[3].toString(),
          style: TextStyle(
            letterSpacing: SizeConfig.blockSizeHorizontal * .7,
            fontSize: SizeConfig.h3,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
