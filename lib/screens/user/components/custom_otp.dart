// ignore_for_file: prefer_const_constructors, avoid_print
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class CustomOtpField extends StatefulWidget {
  final int length;
  double height;
  Color borderColor;
  Color textColor;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  CustomOtpField(
      {super.key,
      required this.length,
      required this.onChanged,
      required this.onCompleted,
      this.height = 60,
      this.textColor = Colors.black,
      this.borderColor = Colors.black});

  @override
  _CustomOtpFieldState createState() => _CustomOtpFieldState();
}

class _CustomOtpFieldState extends State<CustomOtpField> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers =
        List.generate(widget.length, (index) => TextEditingController());
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        widget.length,
        (index) => Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: SizedBox(
              height: widget.height,
              child: TextField(
                controller: _controllers[index],
                keyboardType: TextInputType.number,
                maxLength: 2,
                style: TextStyle(color: widget.textColor),
                textAlign: TextAlign.center,
                onChanged: (value) {
                  widget.onChanged(_getCurrentOtp());
                  if (index == widget.length - 1 && value.isNotEmpty) {
                    widget.onCompleted(_getCurrentOtp());
                  } else if (index < widget.length - 1 && value.isNotEmpty) {
                    FocusScope.of(context).nextFocus();
                  }
                },
                decoration: InputDecoration(
                  counterText: '',
                  contentPadding: EdgeInsets.all(10),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: widget.borderColor)),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getCurrentOtp() {
    return _controllers.map((controller) => controller.text).join();
  }
}
