import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';

/// Safe, lightweight Markdown renderer for Web AI assistant messages.
///
/// Supports bold (`**text**`), italic (`*text*` / `_text_`), inline code,
/// bullet/numbered lists, paragraphs, line breaks, and safe `http`/`https`
/// links without executing HTML or JavaScript. Automatically aligns Arabic/RTL
/// and English/LTR paragraphs.
class WebMarkdownText extends StatelessWidget {
  const WebMarkdownText({
    super.key,
    required this.text,
    this.style,
    this.linkColor,
    this.onLinkTap,
  });

  final String text;
  final TextStyle? style;
  final Color? linkColor;
  final ValueChanged<String>? onLinkTap;

  static final _rtlRegex = RegExp(r'[\u0600-\u06FF]');
  static final _numberedRegex = RegExp(r'^(\d+)\.\s+(.*)$');

  static bool isRtlText(String value) => _rtlRegex.hasMatch(value);

  @override
  Widget build(BuildContext context) {
    final baseStyle =
        style ??
        Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5) ??
        const TextStyle(fontSize: 14, height: 1.5);
    final effectiveLinkColor =
        linkColor ?? Theme.of(context).colorScheme.primary;

    final normalized = text.replaceAll('\r\n', '\n').trim();
    if (normalized.isEmpty) {
      return const SizedBox.shrink();
    }

    final blocks = normalized.split(RegExp(r'\n\s*\n'));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < blocks.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _buildBlock(
            context,
            blocks[i],
            baseStyle,
            effectiveLinkColor,
          ),
        ],
      ],
    );
  }

  Widget _buildBlock(
    BuildContext context,
    String block,
    TextStyle baseStyle,
    Color linkColor,
  ) {
    final lines = block.split('\n');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < lines.length; i++) ...[
          if (i > 0) const SizedBox(height: 4),
          _buildLine(context, lines[i], baseStyle, linkColor),
        ],
      ],
    );
  }

  Widget _buildLine(
    BuildContext context,
    String rawLine,
    TextStyle baseStyle,
    Color linkColor,
  ) {
    final line = rawLine.trimRight();
    final dir = isRtlText(line) ? TextDirection.rtl : TextDirection.ltr;

    if (line.startsWith('- ') ||
        line.startsWith('* ') ||
        line.startsWith('• ')) {
      final content = line.substring(2).trimLeft();
      return Directionality(
        textDirection: dir,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('•  ', style: baseStyle.copyWith(fontWeight: FontWeight.w700)),
            Expanded(
              child: SelectableText.rich(
                TextSpan(
                  children: _parseInline(content, baseStyle, linkColor),
                ),
                textDirection: dir,
              ),
            ),
          ],
        ),
      );
    }

    final numbered = _numberedRegex.firstMatch(line);
    if (numbered != null) {
      final number = numbered.group(1)!;
      final content = numbered.group(2)!;
      return Directionality(
        textDirection: dir,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$number. ',
              style: baseStyle.copyWith(fontWeight: FontWeight.w700),
            ),
            Expanded(
              child: SelectableText.rich(
                TextSpan(
                  children: _parseInline(content, baseStyle, linkColor),
                ),
                textDirection: dir,
              ),
            ),
          ],
        ),
      );
    }

    final headingMatch = RegExp(r'^#{1,3}\s+(.*)$').firstMatch(line);
    if (headingMatch != null) {
      final headingStyle = baseStyle.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: (baseStyle.fontSize ?? 14) + 1.5,
      );
      return SelectableText.rich(
        TextSpan(
          children: _parseInline(
            headingMatch.group(1)!,
            headingStyle,
            linkColor,
          ),
        ),
        textDirection: dir,
      );
    }

    return SelectableText.rich(
      TextSpan(children: _parseInline(line, baseStyle, linkColor)),
      textDirection: dir,
    );
  }

  List<InlineSpan> _parseInline(
    String input,
    TextStyle baseStyle,
    Color linkColor,
  ) {
    final spans = <InlineSpan>[];
    final tokenRegex = RegExp(
      r'(\*\*[^*]+\*\*|__[^_]+__|\*[^*\n]+\*|_[^_\n]+_|`[^`\n]+`|\[[^\]]+\]\(https?:\/\/[^\s)]+\)|https?:\/\/[^\s)]+)',
    );
    var cursor = 0;
    for (final match in tokenRegex.allMatches(input)) {
      if (match.start > cursor) {
        spans.add(
          TextSpan(
            text: input.substring(cursor, match.start),
            style: baseStyle,
          ),
        );
      }
      final token = match.group(0)!;
      if ((token.startsWith('**') && token.endsWith('**')) ||
          (token.startsWith('__') && token.endsWith('__'))) {
        spans.add(
          TextSpan(
            text: token.substring(2, token.length - 2),
            style: baseStyle.copyWith(fontWeight: FontWeight.w700),
          ),
        );
      } else if ((token.startsWith('*') && token.endsWith('*')) ||
          (token.startsWith('_') && token.endsWith('_'))) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: baseStyle.copyWith(fontStyle: FontStyle.italic),
          ),
        );
      } else if (token.startsWith('`') && token.endsWith('`')) {
        spans.add(
          TextSpan(
            text: token.substring(1, token.length - 1),
            style: baseStyle.copyWith(fontFamily: 'monospace'),
          ),
        );
      } else if (token.startsWith('[')) {
        final linkMatch = RegExp(
          r'^\[([^\]]+)\]\((https?:\/\/[^\s)]+)\)$',
        ).firstMatch(token);
        if (linkMatch != null) {
          final label = linkMatch.group(1)!;
          final url = linkMatch.group(2)!;
          spans.add(
            _buildLinkSpan(label, url, baseStyle, linkColor),
          );
        } else {
          spans.add(TextSpan(text: token, style: baseStyle));
        }
      } else if (token.startsWith('http://') || token.startsWith('https://')) {
        spans.add(_buildLinkSpan(token, token, baseStyle, linkColor));
      } else {
        spans.add(TextSpan(text: token, style: baseStyle));
      }
      cursor = match.end;
    }
    if (cursor < input.length) {
      spans.add(TextSpan(text: input.substring(cursor), style: baseStyle));
    }
    return spans;
  }

  TextSpan _buildLinkSpan(
    String label,
    String url,
    TextStyle baseStyle,
    Color linkColor,
  ) {
    final recognizer = onLinkTap == null
        ? null
        : (TapGestureRecognizer()..onTap = () => onLinkTap!(url));
    return TextSpan(
      text: label,
      style: baseStyle.copyWith(
        color: linkColor,
        decoration: TextDecoration.underline,
      ),
      recognizer: recognizer,
    );
  }
}
