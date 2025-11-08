import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TextWidget extends StatelessWidget {
  const TextWidget({
    super.key,
    this.isTextCenterd = false,
    required this.text,
    required this.color,
    required this.textSize,
    this.isTitle = false,
    this.maxLines = 10,
  });

  final String text;
  final Color color;
  final double textSize;
  final bool isTextCenterd;
  final bool isTitle;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      minFontSize: 2,
      maxLines: maxLines,
      textDirection: TextDirection.ltr,
      textAlign: isTextCenterd ? TextAlign.center : TextAlign.start,
      style: TextStyle(
        color: color,
        overflow: TextOverflow.ellipsis,
        fontSize: textSize,
        fontWeight: isTitle ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }
}
