import 'package:flutter/material.dart';

class CustomTextFormField extends StatefulWidget {
  final String label;
  final String initialValue;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obsecureText;
  const CustomTextFormField({
    super.key,
    required this.label,
    this.initialValue = '',
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.validator,
    this.obsecureText = false,
  });

  @override
  State<CustomTextFormField> createState() => _CustomTextFormFieldState();
}

class _CustomTextFormFieldState extends State<CustomTextFormField> {
  final TextEditingController _controller = TextEditingController();
  bool obsecureField = true;

  void toggleVisibility() {
    setState(() {
      obsecureField = !obsecureField;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    _controller.text = widget.initialValue;
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controller,
        decoration: InputDecoration(
          labelText: widget.label,
          prefixIcon: widget.prefixIcon,
          suffixIcon: widget.obsecureText
              ? IconButton(
                  onPressed: toggleVisibility,
                  icon: Icon(
                    obsecureField
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                )
              : widget.suffixIcon,
        ),
        obscureText: widget.obsecureText ? obsecureField : false,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
      ),
    );
  }
}
