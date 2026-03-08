import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Smart TextFormField with auto-formatting on Enter key
/// Supports bullet points (•) and auto-numbering (1-, 2-, etc.)
class SmartTextFormField extends StatefulWidget {
  const SmartTextFormField({
    required this.controller,
    required this.label,
    this.maxLines = 3,
    this.formatType = SmartFormatType.bullet,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final int maxLines;
  final SmartFormatType formatType;

  @override
  State<SmartTextFormField> createState() => _SmartTextFormFieldState();
}

enum SmartFormatType { bullet, numbered }

class _SmartTextFormFieldState extends State<SmartTextFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: const TextStyle(
          fontSize: 16,
          color: Colors.grey,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: const TextStyle(
          fontSize: 18,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        border: const OutlineInputBorder(),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        isDense: true,
      ),
      maxLines: widget.maxLines,
      keyboardType: TextInputType.multiline,
      textInputAction: TextInputAction.newline,
      inputFormatters: [
        SmartTextInputFormatter(
          formatType: widget.formatType,
          onLineNumberChanged: (_) {},
        ),
      ],
    );
  }
}

/// Text Input Formatter for Smart Fields
/// Automatically adds bullet points or numbering when Enter is pressed
class SmartTextInputFormatter extends TextInputFormatter {
  SmartTextInputFormatter({
    required this.formatType,
    required this.onLineNumberChanged,
  });

  final SmartFormatType formatType;
  final void Function(int) onLineNumberChanged;
  int _lineNumber = 1;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Detect Enter key press (newline added at end)
    if (newValue.text.length > oldValue.text.length &&
        newValue.text.endsWith('\n')) {
      // Determine prefix based on format type
      final prefix = formatType == SmartFormatType.bullet
          ? '• '
          : '$_lineNumber- ';

      _lineNumber++;
      onLineNumberChanged(_lineNumber);

      return TextEditingValue(
        text: newValue.text + prefix,
        selection: TextSelection.collapsed(
          offset: newValue.text.length + prefix.length,
        ),
      );
    }

    // Handle backspace to update line number
    if (newValue.text.length < oldValue.text.length) {
      final newlines = '\n'.allMatches(newValue.text).length;
      _lineNumber = newlines + 1;
      onLineNumberChanged(_lineNumber);
    }

    return newValue;
  }
}
