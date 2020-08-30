import 'dart:ui';

class GradientValues {
  List<Gradient> _gradients = [
    Gradient(
      name: "A Lost Memory",
      from: Color(0xFFdd5e89),
      to: Color(0xFFf7bb97),
    ),
    Gradient(
      name: "Lush",
      from: Color(0xFF56ab2f),
      to: Color(0xFFa8e063),
    ),
    Gradient(
      name: "Scooter",
      from: Color(0xFF5b86e5),
      to: Color(0xFF36d1dc),
    ),
    Gradient(
      name: "Aubergine",
      from: Color(0xFFaa076b),
      to: Color(0xFF61045f),
    ),
    Gradient(
      name: "Sea Blue",
      from: Color(0xFF2b5876),
      to: Color(0xFF4e4376),
    ),
  ];

  get gradients => _gradients;
}

class Gradient {
  Color _to;
  Color _from;
  String _name;

  get gradient => [_from, _to];

  get to => _to;

  get from => _from;

  get name => _name;

  Gradient({String name, Color from, Color to})
      : _to = to,
        _from = from,
        _name = name;

  @override
  String toString() {
    return 'Gradient(name: $_name, to: $_from, from: $_to)';
  }
}
