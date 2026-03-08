import 'package:elajtech/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// Custom Text Field Widget - حقل نص مخصص
class CustomTextField extends StatefulWidget {
  const CustomTextField({
    required this.label,
    super.key,
    this.hint,
    this.controller,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
    this.validator,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLines = 1,
    this.enabled = true,
    this.onChanged,
    this.textDirection,
    this.textAlign = TextAlign.start,
    this.maxLength,
    this.letterSpacing,
    this.helperText,
  });
  final String label;
  final String? hint;
  final String? helperText;
  final TextEditingController? controller;
  final TextInputType keyboardType;
  final bool obscureText;
  final String? Function(String?)? validator;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final int maxLines;
  final bool enabled;
  final void Function(String)? onChanged;
  final TextDirection? textDirection;
  final TextAlign textAlign;
  final int? maxLength;
  final double? letterSpacing;

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isObscured = true;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: widget.controller,
    keyboardType: widget.keyboardType,
    obscureText: widget.obscureText && _isObscured,
    validator: widget.validator,
    maxLines: widget.obscureText ? 1 : widget.maxLines,
    enabled: widget.enabled,
    onChanged: widget.onChanged,
    textDirection: widget.textDirection,
    textAlign: widget.textAlign,
    maxLength: widget.maxLength,
    style: widget.letterSpacing != null
        ? TextStyle(letterSpacing: widget.letterSpacing)
        : null,
    decoration: InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      helperText: widget.helperText,
      prefixIcon: widget.prefixIcon != null
          ? Icon(widget.prefixIcon, color: AppColors.primary)
          : null,
      suffixIcon: widget.obscureText
          ? IconButton(
              icon: Icon(
                _isObscured ? Icons.visibility_off : Icons.visibility,
                color: AppColors.textSecondaryLight,
              ),
              onPressed: () {
                setState(() {
                  _isObscured = !_isObscured;
                });
              },
            )
          : widget.suffixIcon,
    ),
  );
}
