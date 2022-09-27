import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';

class BadgeNumberPicker extends StatefulWidget {
  final int initialAmount;
  final ValueChanged onChanged;

  const BadgeNumberPicker({required this.initialAmount, required this.onChanged, Key? key}) : super(key: key);

  @override
  _BadgeNumberPickerState createState() => _BadgeNumberPickerState();
}

class _BadgeNumberPickerState extends State<BadgeNumberPicker> {
  late int _amount;

  @override
  void initState() {
    _amount = widget.initialAmount;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NumberPicker(
      value: _amount,
      selectedTextStyle: TextStyle(
          color: Colors.deepPurple,
          fontWeight: FontWeight.bold,
          fontSize: 36.0
      ),
      minValue: 0,
      maxValue: 9999,
      onChanged: (value){
          if(_amount != value){
            setState((){
              _amount = value;
              widget.onChanged(value);
            });
          }
      }
    );
  }
}
