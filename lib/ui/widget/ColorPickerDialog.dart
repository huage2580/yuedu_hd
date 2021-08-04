
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class ColorPickerDialog extends StatefulWidget{
  final Color initColor;

  const ColorPickerDialog({Key? key, required this.initColor}) : super(key: key);
  @override
  _ColorPickerDialogState createState() => _ColorPickerDialogState();
}

class _ColorPickerDialogState extends State<ColorPickerDialog> {
  // create some values
  late Color pickerColor;

// ValueChanged<Color> callback
  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  @override
  void initState() {
    pickerColor = widget.initColor;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Pick a color!'),
      content: SingleChildScrollView(
        child: ColorPicker(
          pickerColor: pickerColor,
          onColorChanged: changeColor,
          showLabel: true,
          pickerAreaHeightPercent: 0.8,
        ),
        // Use Material color picker:
        //
        // child: MaterialPicker(
        //   pickerColor: pickerColor,
        //   onColorChanged: changeColor,
        //   showLabel: true, // only on portrait mode
        // ),
        //
        // Use Block color picker:
        //
        // child: BlockPicker(
        //   pickerColor: currentColor,
        //   onColorChanged: changeColor,
        // ),
      ),
      actions: <Widget>[
        FlatButton(
          child: const Text('确定'),
          onPressed: () {
            Navigator.of(context).pop(pickerColor);
          },
        ),
      ],
    );
  }
}