// Copyright (C) 2020  Cyril Dutrieux <cyril@cdutrieux.fr>
//
// This file is part of Pattle.
//
// Pattle is free software: you can redistribute it and/or modify
// it under the terms of the GNU Affero General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Pattle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Affero General Public License for more details.
//
// You should have received a copy of the GNU Affero General Public License
// along with Pattle.  If not, see <https://www.gnu.org/licenses/>.

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:highlight/highlight.dart';

import '../../../../../resources/theme.dart';

class MarkdownEditingController extends TextEditingController {
  Map<String, TextStyle> _theme;

  List<TextSpan> _convert(List<Node> nodes, bool withComposing) {
    var spans = <TextSpan>[];
    var currentSpans = spans;
    final stack = <List<TextSpan>>[];
    var pos = 0;

    _traverse(Node node) {
      if (node.value != null) {
        var relativeComposing = TextRange(
          start: max(0, value.composing.start - pos),
          end: max(0, value.composing.end - pos),
        );
        var style = _theme[node.className];
        currentSpans.add(
          composingTextSpan(
            text: node.value,
            style: style,
            withComposing: withComposing,
            composing: relativeComposing,
          ),
        );
        pos += node.value.length;
      } else if (node.children != null) {
        List<TextSpan> tmp = [];
        var style = _theme[node.className];
        if (node.className == "bullet" &&
            node.children.length > 0 &&
            node.children.first.value.startsWith(RegExp(r'^\s*[+-]'))) {
          style = null;
        }

        currentSpans.add(TextSpan(children: tmp, style: style));
        stack.add(currentSpans);
        currentSpans = tmp;

        node.children.forEach((n) {
          _traverse(n);
          if (n == node.children.last) {
            currentSpans = stack.isEmpty ? spans : stack.removeLast();
          }
        });
      }
    }

    for (final node in nodes) {
      _traverse(node);
    }

    return spans;
  }

  @override
  TextSpan buildTextSpan({TextStyle style, bool withComposing}) {
    final result = highlight.parse(value.text, language: 'markdown');
    final spans = _convert(result.nodes, withComposing);
    return TextSpan(style: style, children: spans);
  }

  TextSpan composingTextSpan({
    String text,
    TextStyle style,
    bool withComposing,
    TextRange composing,
  }) {
    if (!composing.isValid ||
        !withComposing ||
        composing.isCollapsed ||
        composing.start >= text.length) {
      return TextSpan(style: style, text: text);
    }

    final TextStyle composingStyle = style == null
        ? const TextStyle(decoration: TextDecoration.underline)
        : style.merge(const TextStyle(decoration: TextDecoration.underline));

    return TextSpan(style: style, children: <TextSpan>[
      TextSpan(text: composing.textBefore(text)),
      TextSpan(
        style: composingStyle,
        text: composing.textInside(text),
      ),
      TextSpan(text: composing.textAfter(text)),
    ]);
  }

  void setMarkdownTheme(BuildContext context) {
    _theme = context.pattleTheme.data.markdown;
  }
}
