import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:picnic_app/resources/assets.gen.dart';
import 'package:picnic_app/utils/extensions/responsive_extensions.dart';
import 'package:picnic_ui_components/ui/theme/picnic_theme.dart';
import 'package:picnic_ui_components/ui/widgets/picnic_icon_button.dart';

class PicnicCommentTextInput extends StatelessWidget {
  const PicnicCommentTextInput({
    Key? key,
    this.textController,
    this.onChanged,
    this.fillColor,
    this.textColor,
    this.focusNode,
    required this.hintText,
    this.isDense = false,
    this.maxLines = 1,
    this.dropShadow = false,
    this.onTapSend,
  }) : super(key: key);

  final String hintText;
  final TextEditingController? textController;
  final ValueChanged<String>? onChanged;
  final Color? fillColor;
  final Color? textColor;
  final FocusNode? focusNode;
  final bool isDense;
  final int? maxLines;
  final bool dropShadow;
  final VoidCallback? onTapSend;

  static const _defaultBorderRadius = 40.0;
  static const _defaultBlurRadius = 4.0;
  static const _shadowOpacity = 0.1;
  static const _shadowBlurRadius = 40.0;
  static const _sendButtonSize = 16.0;

  @override
  Widget build(BuildContext context) {
    final theme = PicnicTheme.of(context);
    final blackAndWhite = theme.colors.blackAndWhite;
    final textStyles = theme.styles;
    final textStyle = textStyles.body20
        .copyWith(
          fontSize: context.responsiveValue(
            small: 14,
            medium: 14,
            large: 16,
          ),
        )
        .copyWith(
          color: textColor ?? blackAndWhite.shade100,
        );
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(25.0),
      borderSide: BorderSide(
        color: blackAndWhite.shade300,
      ),
    );
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(_defaultBorderRadius),
        boxShadow: dropShadow
            ? [
                BoxShadow(
                  offset: const Offset(0, 4),
                  color: blackAndWhite.shade900.withOpacity(_shadowOpacity),
                  blurRadius: _shadowBlurRadius,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.all(Radius.circular(_defaultBorderRadius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: _defaultBlurRadius,
            sigmaY: _defaultBlurRadius,
          ),
          child: TextFormField(
            focusNode: focusNode,
            controller: textController,
            onChanged: onChanged,
            style: textStyle,
            decoration: InputDecoration(
              fillColor: fillColor,
              filled: false,
              enabledBorder: border,
              focusedBorder: border,
              contentPadding: isDense
                  ? const EdgeInsets.symmetric(horizontal: 18, vertical: 14)
                  : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              isDense: isDense,
              hintText: hintText,
              hintStyle: textStyle,
              suffixIcon: Padding(
                padding: const EdgeInsets.all(8),
                child: PicnicIconButton(
                  size: _sendButtonSize,
                  icon: Assets.images.arrowRight.path,
                  color: theme.colors.blue,
                  onTap: onTapSend,
                ),
              ),
            ),
            maxLines: maxLines,
          ),
        ),
      ),
    );
  }
}
