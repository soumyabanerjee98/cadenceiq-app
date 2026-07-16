import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomNumberPicker extends StatefulWidget {
  const CustomNumberPicker({
    super.key,
    required this.label,
    required this.initialValue,
    required this.min,
    required this.max,
    required this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.suffixText,
  });

  final String label;
  final int? initialValue;
  final int min;
  final int max;
  final ValueChanged<int?> onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? suffixText;
  final String? Function(String?)? validator;

  @override
  State<CustomNumberPicker> createState() => _CustomNumberPickerState();
}

class _CustomNumberPickerState extends State<CustomNumberPicker> {
  late int? value;
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
    controller = TextEditingController(
      text: value == null
          ? "-"
          : widget.suffixText == null
          ? "$value"
          : "$value ${widget.suffixText}",
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _showPicker() async {
    int? temp = value;

    await showModalBottomSheet(
      context: context,
      builder: (_) {
        return SafeArea(
          child: SizedBox(
            height: 280,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Text(
                        widget.label,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            value = temp;
                            controller.text = widget.suffixText == null
                                ? "$value"
                                : "$value ${widget.suffixText}";
                          });

                          widget.onChanged(value);
                          Navigator.pop(context);
                        },
                        child: const Text("Done"),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: CupertinoPicker(
                    itemExtent: 44,
                    scrollController: FixedExtentScrollController(
                      initialItem: value == null ? 0 : (value! - widget.min),
                    ),
                    onSelectedItemChanged: (index) {
                      temp = widget.min + index;
                    },
                    children: List.generate(
                      widget.max - widget.min + 1,
                      (i) => Center(
                        child: Text(
                          widget.suffixText == null
                              ? "${widget.min + i}"
                              : "${widget.min + i} ${widget.suffixText}",
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        validator: widget.validator,
        onTap: _showPicker,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.prefixIcon,
          suffixIcon:
              widget.suffixIcon ??
              const Icon(Icons.keyboard_arrow_down_rounded),
        ),
      ),
    );
  }
}
