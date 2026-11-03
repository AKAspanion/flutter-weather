import 'package:flutter/material.dart';

/// One segment of a [SegmentedChoice]: the [value] it stands for and what it shows.
class SegmentedOption<T> {
  final T value;

  /// A Text or an Icon; it is drawn in the segment's colour.
  final Widget child;

  /// Read out by screen readers, for an option that shows only an icon.
  final String? semanticLabel;

  const SegmentedOption({required this.value, required this.child, this.semanticLabel});
}

/// A small two-part (or more) toggle: the selected option is filled with [accent] and drawn white, the others are
/// transparent in [textColor]. The temperature unit and the theme share it so the two can't drift apart.
class SegmentedChoice<T> extends StatelessWidget {
  final List<SegmentedOption<T>> options;
  final T selected;
  final Color accent;
  final Color textColor;

  /// Not called for the already-selected option.
  final void Function(T value) onChanged;

  const SegmentedChoice({
    super.key,
    required this.options,
    required this.selected,
    required this.accent,
    required this.textColor,
    required this.onChanged,
  });

  Widget _segment(SegmentedOption<T> option) {
    final bool isSelected = option.value == selected;
    final Color color = isSelected ? Colors.white : textColor;
    Widget segment = InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: isSelected ? null : () => onChanged(option.value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? accent : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: DefaultTextStyle(
          style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold),
          child: IconTheme(data: IconThemeData(color: color, size: 20), child: option.child),
        ),
      ),
    );
    if (option.semanticLabel != null) {
      segment = Semantics(
        label: option.semanticLabel,
        button: true,
        selected: isSelected,
        excludeSemantics: true,
        child: segment,
      );
    }
    return segment;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < options.length; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          _segment(options[i]),
        ],
      ],
    );
  }
}
