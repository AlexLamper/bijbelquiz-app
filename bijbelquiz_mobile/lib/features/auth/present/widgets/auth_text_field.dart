import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';

/// Labelled input for the sign-in forms: a bold label above a 52px white
/// field, an optional hint below, and a show/hide toggle for passwords.
class AuthTextField extends StatefulWidget {
  const AuthTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.keyboardType = TextInputType.text,
    this.textInputAction,
    this.obscure = false,
    this.autofillHints,
    this.onSubmitted,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final TextInputType keyboardType;
  final TextInputAction? textInputAction;
  final bool obscure;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final TextCapitalization textCapitalization;

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _hidden = widget.obscure;

  @override
  Widget build(BuildContext context) {
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      borderSide: const BorderSide(color: AppTheme.ruleStrong),
    );

    final helper = widget.helper;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Read out as the field's own label instead.
        ExcludeSemantics(
          child: Text(
            widget.label,
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppTheme.ink,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Semantics(
          label: widget.label,
          child: TextField(
            controller: widget.controller,
            enabled: widget.enabled,
            obscureText: _hidden,
            keyboardType: widget.keyboardType,
            textInputAction: widget.textInputAction,
            textCapitalization: widget.textCapitalization,
            autofillHints: widget.autofillHints,
            autocorrect: !widget.obscure,
            enableSuggestions: !widget.obscure,
            onSubmitted: widget.onSubmitted,
            cursorColor: AppTheme.lapis,
            style: const TextStyle(
              fontFamily: AppTheme.sansFontName,
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.ink,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              hintStyle: const TextStyle(
                fontFamily: AppTheme.sansFontName,
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.inkFaint,
              ),
              filled: true,
              fillColor: AppTheme.paperRaised,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 15,
              ),
              border: border,
              enabledBorder: border,
              disabledBorder: border,
              focusedBorder: border.copyWith(
                borderSide: const BorderSide(color: AppTheme.lapis, width: 2),
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 48,
                minHeight: 44,
              ),
              suffixIcon: widget.obscure
                  ? IconButton(
                      tooltip: _hidden
                          ? 'Wachtwoord tonen'
                          : 'Wachtwoord verbergen',
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(
                        _hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                        color: AppTheme.inkMuted,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(helper, style: AppTheme.caption),
        ],
      ],
    );
  }
}
