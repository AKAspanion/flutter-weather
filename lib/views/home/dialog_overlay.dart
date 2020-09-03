import 'package:flutter/material.dart';
import 'package:flutterweather/services/theme_manager.dart';
import 'package:flutterweather/theme/gradients.dart';
import 'package:provider/provider.dart';

class DialogOverlay extends StatefulWidget {
  final int accent;
  final onSubmit;
  final onCancel;

  DialogOverlay({this.accent, this.onSubmit, this.onCancel});

  @override
  _DialogOverlayState createState() => _DialogOverlayState();
}

class _DialogOverlayState extends State<DialogOverlay> {
  String city;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Color bgColor = Provider.of<ThemeManager>(context).bgColor;
    Color textColor = Provider.of<ThemeManager>(context).textColor;
    final Color accent = GradientValues().gradients[widget.accent].gradient[0];

    return Positioned(
      height: size.height,
      width: size.width,
      child: Container(
        color: Colors.black87,
        child: Center(
          child: Container(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: 12,
            ),
            decoration: BoxDecoration(
              color: bgColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.black38,
                  blurRadius: 40.0,
                )
              ],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Container(
              width: size.width - 150,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    onChanged: (e) => _updateCity(e),
                    decoration: InputDecoration(
                      labelText: "City name",
                      labelStyle: TextStyle(color: textColor),
                      prefixIcon: Icon(
                        Icons.location_city,
                        color: accent,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: accent),
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: accent),
                      ),
                    ),
                    style: TextStyle(
                      color: textColor,
                      fontSize: 18,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: textColor,
                        ),
                        onPressed: () => _cancel(),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.done,
                          color: textColor,
                        ),
                        onPressed: () => _submit(),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      top: 0,
      left: 0,
    );
  }

  _updateCity(String text) {
    setState(() {
      city = text;
    });
  }

  _cancel() {
    if (widget.onCancel != null) {
      widget.onCancel();
      _updateCity("");
    }
  }

  _submit() {
    if (widget.onSubmit != null) {
      widget.onSubmit(city);
      _updateCity("");
    }
  }
}
