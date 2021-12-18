// Flutter Imports
import 'package:flutter/material.dart';

// Local Imports
import '../../configs/size_config.dart';

/*
-------------------------------------------------------------------- @PogoTeams
A floating action button that is docked at the bottom center. This is used to
exit from the current screen, returning to the previous screen on the
navigator stack. No information is returned from the current screen.
-------------------------------------------------------------------------------
*/

class ExitButton extends StatelessWidget {
  const ExitButton({
    Key? key,
    required this.onPressed,
    this.icon = const Icon(Icons.close),
    this.backgroundColor = Colors.teal,
  }) : super(key: key);

  final VoidCallback onPressed;
  final Icon icon;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    // Block size from MediaQuery
    return Container(
      height: SizeConfig.blockSizeHorizontal * 9.0,
      width: SizeConfig.blockSizeHorizontal * 9.0,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.white,
          width: SizeConfig.blockSizeHorizontal * 0.7,
        ),
        shape: BoxShape.circle,
      ),
      child: FloatingActionButton(
        heroTag: key,
        child: Icon(
          icon.icon,
          size: SizeConfig.blockSizeHorizontal * 5.0,
        ),
        foregroundColor: Colors.white,
        backgroundColor: backgroundColor,

        // Callback
        onPressed: onPressed,
      ),
    );
  }
}
