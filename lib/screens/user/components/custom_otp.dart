// ignore_for_file: prefer_const_constructors, avoid_print
import 'package:flutter/material.dart';

class CustomOtpField extends StatefulWidget {
  final int length;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onCompleted;

  const CustomOtpField({
    required this.length,
    required this.onChanged,
    required this.onCompleted,
  });

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
            child: TextField(
              controller: _controllers[index],
              keyboardType: TextInputType.number,
              maxLength: 1,
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
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
