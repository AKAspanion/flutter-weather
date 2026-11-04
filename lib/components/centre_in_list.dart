import 'package:flutter/material.dart';

/// How long the list takes to bring a card to its centre.
const Duration _centreDuration = Duration(milliseconds: 400);

/// Scrolls the list nearest [context] (and no list around it) so the widget's centre meets the list's centre.
/// Does nothing when [context] isn't inside a list or is no longer mounted.
///
/// This uses the nearest list's own [ScrollPosition] rather than `Scrollable.ensureVisible`, which would also scroll
/// every list around it: the hourly strip sits in a vertical panel, and that panel must stay where it is. A list can't
/// scroll past its ends, so the first and last cards stop as near the centre as the list allows.
Future<void> centreInList(BuildContext context) async {
  if (!context.mounted) return;
  final ScrollableState? scrollable = Scrollable.maybeOf(context);
  final RenderObject? renderObject = context.findRenderObject();
  if (scrollable == null || renderObject == null || !renderObject.attached) return;
  await scrollable.position.ensureVisible(
    renderObject,
    alignment: 0.5,
    duration: _centreDuration,
    curve: Curves.easeOutCubic,
  );
}
