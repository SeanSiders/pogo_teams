// Flutter
import 'package:flutter/material.dart';
import 'package:pogo_teams/pages/analysis/analysis.dart';

// Local Imports
import 'team_builder.dart';
import '../../pogo_objects/pokemon_team.dart';
import '../../pogo_objects/opponent_teams.dart';
import '../../../widgets/nodes/team_node.dart';
import '../../../widgets/buttons/gradient_button.dart';
import '../../../widgets/nodes/win_loss_node.dart';
import '../../modules/data/pogo_data.dart';
import '../../modules/ui/sizing.dart';

/*
-------------------------------------------------------------------- @PogoTeams
The battle log page for a single user team. From here, the user can add or
"log" opponent teams that they've encountered with their team. They can then
perform an analysis on any individual opponent team or a net analysis of all
logged opponenents associated with their team.
-------------------------------------------------------------------------------
*/

class BattleLog extends StatefulWidget {
  const BattleLog({
    Key? key,
    required this.team,
  }) : super(key: key);

  final UserPokemonTeam team;

  @override
  _BattleLogState createState() => _BattleLogState();
}

class _BattleLogState extends State<BattleLog> {
  late final UserPokemonTeam _team = widget.team;
  OpponentPokemonTeams _opponentTeams = OpponentPokemonTeams();
  void _loadLogs() async {
    _opponentTeams = await PogoData.getOpponentPokemonTeams(_team.id);
    setState(() {
      _team.updateWinRate(_opponentTeams);
      PogoData.updateUserPokemonTeam(_team, updateMask: ['winRate']);
    });
  }

  // Build the app bar with the current page title, and icon
  AppBar _buildAppBar() {
    return AppBar(
      // Upon navigating back, return the updated team ref
      leading: IconButton(
        onPressed: () => Navigator.pop(
          context,
          _team,
        ),
        icon: const Icon(Icons.arrow_back_ios),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Page title
          Text(
            'Battle Log',
            style: Theme.of(context).textTheme.headline5?.apply(
                  fontStyle: FontStyle.italic,
                ),
          ),

          // Spacer
          SizedBox(
            width: Sizing.blockSizeHorizontal * 3.0,
          ),

          // Page icon
          Icon(
            Icons.query_stats,
            size: Sizing.icon3,
          ),
        ],
      ),
    );
  }

  Widget _buildScaffoldBody() {
    return Padding(
      padding: EdgeInsets.only(
        top: Sizing.blockSizeVertical * 1.0,
        left: Sizing.blockSizeHorizontal * 2.0,
        right: Sizing.blockSizeHorizontal * 2.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // The user's team
          _buildTeamNode(),

          // Spacer
          SizedBox(
            height: Sizing.blockSizeVertical * 2.0,
          ),

          Text(
            '- Opponent Teams -',
            style: Theme.of(context).textTheme.headline5,
          ),

          // Spacer
          SizedBox(
            height: Sizing.blockSizeVertical * 2.0,
          ),

          // Logged opponent teams
          _buildLogsList(),
        ],
      ),
    );
  }

  // The user's team
  Widget _buildTeamNode() {
    return TeamNode(
      onPressed: (_) {},
      onEmptyPressed: (_) {},
      team: _team,
      cup: _team.cup,
      buildHeader: true,
      emptyTransparent: true,
      collapsible: true,
      padding: EdgeInsets.only(
        top: Sizing.blockSizeHorizontal * 2.0,
        left: Sizing.blockSizeHorizontal * 3.0,
        right: Sizing.blockSizeHorizontal * 3.0,
      ),
    );
  }

  // Build the list of TeamNodes, with the necessary callbacks
  Widget _buildLogsList() {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: _opponentTeams.length,
        itemBuilder: (context, index) {
          if (index == _opponentTeams.length - 1) {
            return Column(
              children: [
                TeamNode(
                  onEmptyPressed: (nodeIndex) =>
                      _onEmptyPressed(index, nodeIndex),
                  onPressed: (_) {},
                  team: _opponentTeams[index],
                  cup: _team.cup,
                  footer: _buildTeamNodeFooter(index),
                ),
                SizedBox(
                  height: Sizing.blockSizeVertical * 10.0,
                ),
              ],
            );
          }

          return TeamNode(
            onEmptyPressed: (nodeIndex) => _onEmptyPressed(index, nodeIndex),
            onPressed: (_) {},
            team: _opponentTeams[index],
            cup: _team.cup,
            footer: _buildTeamNodeFooter(index),
          );
        },
        physics: const BouncingScrollPhysics(),
      ),
    );
  }

  // The icon buttons at the footer of each TeamNode
  Widget _buildTeamNodeFooter(int teamIndex) {
    // Size of the footer icons
    final double iconSize = Sizing.blockSizeHorizontal * 6.0;

    // Provider retrieve
    final log = _opponentTeams[teamIndex];
    final IconData lockIcon = log.locked ? Icons.lock : Icons.lock_open;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Remove team option if the team is unlocked
        log.locked
            ? Container()
            : IconButton(
                onPressed: () => _onClearTeam(teamIndex),
                icon: const Icon(Icons.clear),
                tooltip: 'Remove Team',
                iconSize: iconSize,
                splashRadius: Sizing.blockSizeHorizontal * 5.0,
              ),

        // Analyze team
        IconButton(
          onPressed: () => _onAnalyzeLogTeam(teamIndex),
          icon: const Icon(Icons.analytics),
          tooltip: 'Analyze Team',
          iconSize: iconSize,
          splashRadius: Sizing.blockSizeHorizontal * 5.0,
        ),

        // Edit team
        IconButton(
          onPressed: () => _onEditLogTeam(teamIndex),
          icon: const Icon(Icons.build_circle),
          tooltip: 'Edit Team',
          iconSize: iconSize,
          splashRadius: Sizing.blockSizeHorizontal * 5.0,
        ),

        // Lock team
        IconButton(
          onPressed: () => _onLockPressed(teamIndex),
          icon: Icon(lockIcon),
          tooltip: 'Unlock Team',
          iconSize: iconSize,
          splashRadius: Sizing.blockSizeHorizontal * 5.0,
        ),

        // Win, tie, loss indicator
        Padding(
          padding: EdgeInsets.only(
            top: Sizing.blockSizeVertical,
            bottom: Sizing.blockSizeVertical,
          ),
          child: WinLossNode(outcome: log.battleOutcome),
        ),
      ],
    );
  }

  // Build a log buttton, and if there are existing logs, also an analyze
  // button which will apply to all logged opponent teams.
  Widget _buildFloatingActionButtons() {
    // If logs are empty, then only give the option to add
    if (_opponentTeams.length == 0) {
      return GradientButton(
        onPressed: _onAddTeam,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Log Opponent Team',
              style: Theme.of(context).textTheme.headline6,
            ),
            SizedBox(
              width: Sizing.blockSizeHorizontal * 5.0,
            ),
            Icon(
              Icons.add,
              size: Sizing.blockSizeHorizontal * 7.0,
            ),
          ],
        ),
        width: Sizing.screenWidth * .85,
        height: Sizing.blockSizeVertical * 8.5,
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Analyze button
        GradientButton(
          onPressed: _onAnalyzeLogs,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Analyze',
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(
                width: Sizing.blockSizeHorizontal * 4.0,
              ),
              Icon(
                Icons.analytics,
                size: Sizing.blockSizeHorizontal * 7.0,
              ),
            ],
          ),
          width: Sizing.screenWidth * .44,
          height: Sizing.blockSizeVertical * 8.5,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(50),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
            bottomLeft: Radius.circular(50),
          ),
        ),

        // Log button
        GradientButton(
          onPressed: _onAddTeam,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Log',
                style: Theme.of(context).textTheme.headline5,
              ),
              SizedBox(
                width: Sizing.blockSizeHorizontal * 4.0,
              ),
              Icon(
                Icons.add,
                size: Sizing.blockSizeHorizontal * 7.0,
              ),
            ],
          ),
          width: Sizing.screenWidth * .44,
          height: Sizing.blockSizeVertical * 8.5,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(50),
            bottomRight: Radius.circular(50),
            bottomLeft: Radius.circular(20),
          ),
        ),
      ],
    );
  }

  // Remove the team at specified index
  void _onClearTeam(int teamIndex) {
    PogoData.deleteOpponentPokemonTeam(_opponentTeams[teamIndex].id);

    setState(() {
      _opponentTeams.removeTeamAt(teamIndex);
    });
  }

  // Scroll to the analysis portion of the screen
  void _onAnalyzeLogTeam(int teamIndex) {
    final log = _opponentTeams[teamIndex];

    // If the team is empty, no action will be taken
    if (log.isEmpty()) return;

    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return Analysis(
          team: _team,
          opponentTeam: log,
        );
      }),
    );
  }

  // Edit the team at specified index
  void _onEditLogTeam(int teamIndex) async {
    PokemonTeam log = _opponentTeams[teamIndex];

    final newLog = await Navigator.push(
      context,
      MaterialPageRoute<OpponentPokemonTeam>(builder: (BuildContext context) {
        return TeamBuilder(
          team: log,
          cup: log.cup,
          focusIndex: 0,
        );
      }),
    );

    if (newLog != null) {
      await PogoData.updateOpponentPokemonTeam(newLog);

      setState(() {
        _opponentTeams[teamIndex] = newLog;
        _team.updateWinRate(_opponentTeams);
        PogoData.updateUserPokemonTeam(_team, updateMask: ['winRate']);
      });
    }
  }

  // Add a new empty team
  void _onAddTeam() async {
    final newOpponentTeam = await Navigator.push(
      context,
      MaterialPageRoute<OpponentPokemonTeam>(builder: (BuildContext context) {
        return TeamBuilder(
          team: OpponentPokemonTeam(),
          cup: _team.cup,
          focusIndex: 0,
        );
      }),
    );

    setState(() {
      if (newOpponentTeam != null) {
        newOpponentTeam.userTeamId = _team.id ?? '';
        _opponentTeams.addTeam(newOpponentTeam);
        _team.updateWinRate(_opponentTeams);
        PogoData.updateOpponentPokemonTeam(newOpponentTeam);
        PogoData.updateUserPokemonTeam(_team, updateMask: ['winRate']);
      }
    });
    PogoData.updateUserPokemonTeam(_team, updateMask: ['winRate']);
  }

  // Wrapper for _onEditLogTeam
  void _onEmptyPressed(int teamIndex, int nodeIndex) async {
    PokemonTeam log = _opponentTeams[teamIndex];

    final newLog = await Navigator.push(
      context,
      MaterialPageRoute<OpponentPokemonTeam>(builder: (BuildContext context) {
        return TeamBuilder(
          team: log,
          cup: _team.cup,
          focusIndex: nodeIndex,
        );
      }),
    );

    if (newLog != null) {
      PogoData.updateOpponentPokemonTeam(newLog);

      setState(() {
        _opponentTeams[teamIndex] = newLog;
        _team.updateWinRate(_opponentTeams);
        PogoData.updateUserPokemonTeam(_team, updateMask: ['winRate']);
      });
    }
  }

  void _onLockPressed(int teamIndex) {
    setState(() {
      _opponentTeams[teamIndex].toggleLock();
    });

    PogoData.updateOpponentPokemonTeam(
      _opponentTeams[teamIndex],
      updateMask: ['locked'],
    );
  }

  // Navigate to an analysis of all logged opponent teams
  void _onAnalyzeLogs() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (BuildContext context) {
        return Analysis(
          team: _team,
          opponentTeams: _opponentTeams,
        );
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildScaffoldBody(),

      // Log / Analyze opponent teams FABs
      floatingActionButton: _buildFloatingActionButtons(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
