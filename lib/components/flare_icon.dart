import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';

/// A looping Flare animation isolated in its own layer, so its per-frame
/// repaints don't force the rest of the screen (shadows, gradients) to repaint.
class FlareIcon extends StatelessWidget {
  final String file;
  final String animation;

  const FlareIcon(this.file, {required this.animation});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FlareActor(
        file,
        alignment: Alignment.center,
        animation: animation,
      ),
    );
  }
}
