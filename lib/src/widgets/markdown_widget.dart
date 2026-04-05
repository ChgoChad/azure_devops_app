import 'package:azure_devops/src/extensions/context_extension.dart';
import 'package:azure_devops/src/screens/file_detail/base_file_detail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_highlighting/flutter_highlighting.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:highlighting/highlighting.dart';
import 'package:highlighting/languages/all.dart';
import 'package:highlighting/src/language.dart';
import 'package:markdown/markdown.dart' as md;

class AppMarkdownWidget extends StatelessWidget {
  const AppMarkdownWidget({
    required this.data,
    this.styleSheet,
    this.onTapLink,
    this.shrinkWrap = true,
    this.paddingBuilders = const <String, MarkdownPaddingBuilder>{},
  });

  final String data;
  final MarkdownStyleSheet? styleSheet;
  final void Function(String, String?, String)? onTapLink;
  final bool shrinkWrap;
  final Map<String, MarkdownPaddingBuilder> paddingBuilders;

  @override
  Widget build(BuildContext context) {
    return SelectionArea(
      child: MarkdownBody(
        data: data,
        styleSheet: styleSheet,
        onTapLink: onTapLink,
        shrinkWrap: shrinkWrap,
        paddingBuilders: paddingBuilders,
        builders: {
          'code': _CodeElementBuilder(),
        },
      ),
    );
  }
}

class _CodeElementBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    var language = '';

    if (element.attributes['class'] != null) {
      final lg = element.attributes['class'] as String;
      if (lg.startsWith('language-')) language = lg.substring(9);
    }

    final isCodeBlock = element.attributes['class'] != null || element.textContent.contains('\n');
    if (!isCodeBlock) return null; // Fallback to default inline code styling

    return Builder(
      builder: (context) {
        var languageId = language.isEmpty ? 'text' : language;

        if (builtinLanguages[languageId] == null) {
          final langFromExtension = languageExtensions[languageId];
          final builtinLang = builtinLanguages[langFromExtension];

          if (langFromExtension != null && builtinLang != null) {
            languageId = builtinLang.id;
          } else if (languageId != 'text') {
            final lang = Language(id: languageId, refs: {});
            highlight.registerLanguage(lang);
          }
        }

        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.colorScheme.surface,
            borderRadius: BorderRadius.circular(4),
          ),
          child: HighlightView(
            element.textContent,
            languageId: languageId,
            theme: _customTheme(context),
            padding: const EdgeInsets.all(8),
            textStyle: context.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.normal),
          ),
        );
      },
    );
  }
}

Map<String, TextStyle> _customTheme(BuildContext context) => {
      'root': TextStyle(color: Colors.transparent, backgroundColor: Colors.transparent),
      'comment': TextStyle(color: Color(0xff999988), fontStyle: FontStyle.italic),
      'quote': TextStyle(color: Color(0xff999988), fontStyle: FontStyle.italic),
      'keyword': TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.normal),
      'selector-tag': TextStyle(color: Colors.green, fontWeight: FontWeight.normal),
      'subst': TextStyle(color: context.colorScheme.secondary, fontWeight: FontWeight.normal),
      'number': TextStyle(color: Colors.green),
      'literal': TextStyle(color: Colors.green),
      'variable': TextStyle(color: Colors.green),
      'template-variable': TextStyle(color: Color(0xff008080)),
      'string': TextStyle(color: context.colorScheme.secondary),
      'doctag': TextStyle(color: Color(0xffdd1144)),
      'title': TextStyle(color: Colors.green, fontWeight: FontWeight.normal),
      'section': TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.normal),
      'selector-id': TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.normal),
      'type': TextStyle(color: Color(0xff445588), fontWeight: FontWeight.normal),
      'tag': TextStyle(color: context.colorScheme.primaryContainer, fontWeight: FontWeight.normal),
      'name': TextStyle(color: context.colorScheme.secondary, fontWeight: FontWeight.normal),
      'attribute': TextStyle(color: context.colorScheme.primary, fontWeight: FontWeight.normal),
      'regexp': TextStyle(color: Color(0xff009926)),
      'link': TextStyle(color: Color(0xff009926)),
      'symbol': TextStyle(color: Color(0xff990073)),
      'bullet': TextStyle(color: Color(0xff990073)),
      'built_in': TextStyle(color: Colors.green),
      'builtin-name': TextStyle(color: Color(0xff0086b3)),
      'meta': TextStyle(color: Color(0xff999999), fontWeight: FontWeight.normal),
      'deletion': TextStyle(backgroundColor: Color(0xffffdddd)),
      'addition': TextStyle(backgroundColor: Color(0xffddffdd)),
      'emphasis': TextStyle(fontStyle: FontStyle.italic),
      'strong': TextStyle(fontWeight: FontWeight.normal),
    };
