/// Where the shrunken home card sits while the menu is open: centred between the button row and the accent picker.
class OpenCardLayout {
  /// The least gap kept above and below the card.
  static const double minGap = 24;

  /// The card's top edge, from the top of the screen.
  final double top;

  /// The card's scale, of the full screen height.
  final double scale;

  const OpenCardLayout({required this.top, required this.scale});

  factory OpenCardLayout.compute({
    required double screenHeight,
    required double rowBottom,
    required double pickerHeight,
    required double bottomInset,
  }) {
    final space = screenHeight - bottomInset - pickerHeight - rowBottom;
    final scale = ((space - 2 * minGap) / screenHeight).clamp(0.3, 0.65);
    // Half of what the card leaves of the space goes above it and half below, so the gaps stay equal.
    final gap = (space - screenHeight * scale) / 2;
    return OpenCardLayout(top: rowBottom + gap, scale: scale);
  }
}
