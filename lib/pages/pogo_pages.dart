// Flutter
import 'package:flutter/material.dart';

// Local Imports
import 'rankings.dart';
import 'battle_logs.dart';
import 'teams/teams.dart';
import 'settings.dart';
import 'tags.dart';
import '../app/ui/sizing.dart';

/*
-------------------------------------------------------------------- @PogoTeams
An enumeration to express the identity of all top-level pages in the app.
-------------------------------------------------------------------------------
*/

enum PogoPages {
  teams,
  tags,
  battleLogs,
  rankings,
  sync,
  settings,
}

extension PogoPagesExt on PogoPages {
  String get displayName {
    switch (this) {
      case PogoPages.teams:
        return 'Teams';
      case PogoPages.tags:
        return 'Tags';
      case PogoPages.battleLogs:
        return 'Battle Logs';
      case PogoPages.rankings:
        return 'Rankings';
      case PogoPages.sync:
        return 'Sync Pogo Data';
      case PogoPages.settings:
        return 'Settings';
    }
  }

  Widget get icon {
    switch (this) {
      case PogoPages.teams:
        return const Icon(
          Icons.catching_pokemon,
          size: Sizing.icon3,
        );
      case PogoPages.tags:
        return const Icon(
          Icons.tag,
          size: Sizing.icon3,
        );
      case PogoPages.battleLogs:
        return const Icon(
          Icons.query_stats,
          size: Sizing.icon3,
        );
      case PogoPages.rankings:
        return const Icon(
          Icons.bar_chart,
          size: Sizing.icon3,
        );
      case PogoPages.sync:
        return const Icon(
          Icons.sync,
          size: Sizing.icon3,
        );
      case PogoPages.settings:
        return const Icon(
          Icons.settings,
          size: Sizing.icon3,
        );
    }
  }

  Widget get page {
    switch (this) {
      case PogoPages.teams:
        return const Teams();
      case PogoPages.tags:
        return const Tags();
      case PogoPages.battleLogs:
        return const BattleLogs();
      case PogoPages.rankings:
        return const Rankings();
      case PogoPages.sync:
        return const Rankings();
      case PogoPages.settings:
        return const Settings();
    }
  }
}

pogoPageFromIndex(int index) {
  switch (index) {
    case 0:
      return PogoPages.teams;
    case 1:
      return PogoPages.tags;
    case 2:
      return PogoPages.battleLogs;
    case 3:
      return PogoPages.rankings;
    case 4:
      return PogoPages.sync;
    case 5:
      return PogoPages.settings;
  }

  return PogoPages.teams;
}
