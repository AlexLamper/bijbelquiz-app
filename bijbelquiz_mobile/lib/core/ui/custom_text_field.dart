import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Site input field.
///
/// ```html
/// <label class="text-[10px] font-medium uppercase tracking-[0.16em]
///               text-ink-muted">Label</label>
/// <input class="h-12 w-full rounded-md border border-rule bg-paper-raised
///               px-4 text-sm text-ink placeholder:text-ink-muted
///               focus:border-lapis" />
/// ```
class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final TextInputType keyboardType;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final String? hintText;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final TextInputAction? textInputAction;
  final bool enabled;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.prefixIcon,
    this.suffixIcon,
    this.hintText,
    this.validator,
    this.onChanged,
    this.textInputAction,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTheme.overline),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          onChanged: onChanged,
          textInputAction: textInputAction,
          enabled: enabled,
          cursorColor: AppTheme.ink,
          cursorWidth: 1.4,
          style: const TextStyle(
            fontFamily: AppTheme.sansFontName,
            fontSize: 15,
            color: AppTheme.ink,
          ),
          decoration: InputDecoration(
            hintText: hintText ?? label,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, size: 18, color: AppTheme.inkMuted)
                : null,
            prefixIconConstraints: const BoxConstraints(
              minWidth: 44,
              minHeight: 44,
            ),
            suffixIcon: suffixIcon,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 15,
            ),
          ),
        ),
      ],
    );
  }
}
