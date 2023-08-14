import 'package:flutter/material.dart';

import '../screens/vendor/screens/registration_vendor_two.dart';

class BottomSheetContent extends StatefulWidget {
  final List<String> selectedItems;
  final void Function(String) removeItem;

  const BottomSheetContent({
    super.key,
    required this.selectedItems,
    required this.removeItem,
  });

  @override
  _BottomSheetContentState createState() => _BottomSheetContentState();
}

class _BottomSheetContentState extends State<BottomSheetContent> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: widget.selectedItems.isNotEmpty
          ? Column(
              children: [
                const Text("Tap on the items to dismiss the selection.",
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                Wrap(
                  spacing: 10,
                  runSpacing: 5,
                  children: widget.selectedItems.map((item) {
                    return InkWell(
                      onTap: () {
                        widget.removeItem(item);
                        setState(() {
                          widget.selectedItems.remove(item);
                        });
                      },
                      child: Chip(
                        elevation: 1,
                        side: const BorderSide(
                          color: Colors.grey,
                        ),
                        label: Text(
                          convertToSentenceCase(item),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color.fromARGB(255, 143, 143, 143),
                          ),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 255, 255, 255),
                      ),
                    );
                  }).toList(),
                ),
              ],
            )
          : const Text(
              "Please choose your preferred services.",
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
    );
  }
}
