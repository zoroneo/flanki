/// Representation of an Anki Note Type (Model).
class AnkiModel {
  final int id;
  final String name;
  final List<String> fieldNames;
  final List<AnkiTemplate> templates;
  final String css;

  const AnkiModel({
    required this.id,
    required this.name,
    required this.fieldNames,
    required this.templates,
    this.css = '',
  });

  factory AnkiModel.fromJson(String idKey, Map<String, dynamic> json) {
    final name = (json['name'] ?? 'Model $idKey') as String;
    final css = (json['css'] ?? '') as String;

    final fldsList = (json['flds'] as List<dynamic>? ?? []);
    final fieldNames = <String>[];
    for (final f in fldsList) {
      if (f is Map<String, dynamic>) {
        fieldNames.add((f['name'] ?? '') as String);
      }
    }

    final tmplsList = (json['tmpls'] as List<dynamic>? ?? []);
    final templates = <AnkiTemplate>[];
    for (var i = 0; i < tmplsList.length; i++) {
      final t = tmplsList[i];
      if (t is Map<String, dynamic>) {
        templates.add(
          AnkiTemplate(
            ord: (t['ord'] as int? ?? i),
            name: (t['name'] ?? 'Card ${i + 1}') as String,
            qfmt: (t['qfmt'] ?? '') as String,
            afmt: (t['afmt'] ?? '') as String,
          ),
        );
      }
    }

    return AnkiModel(
      id: int.tryParse(idKey) ?? 0,
      name: name,
      fieldNames: fieldNames,
      templates: templates,
      css: css,
    );
  }
}

class AnkiTemplate {
  final int ord;
  final String name;
  final String qfmt;
  final String afmt;

  const AnkiTemplate({
    required this.ord,
    required this.name,
    required this.qfmt,
    required this.afmt,
  });
}

class RenderedCardContent {
  final String front;
  final String back;

  const RenderedCardContent({
    required this.front,
    required this.back,
  });
}

/// Anki Template rendering engine supporting Mustache-style field replacement,
/// conditionals, {{FrontSide}}, and cloze deletion.
class AnkiTemplateEngine {
  /// Evaluates the question (front) and answer (back) for a note.
  static RenderedCardContent renderCard({
    required AnkiModel? model,
    required int cardOrd,
    required List<String> fieldValues,
  }) {
    // 1. Build field map (Field Name -> Value)
    final fieldMap = <String, String>{};
    if (model != null && model.fieldNames.isNotEmpty) {
      for (var i = 0; i < model.fieldNames.length; i++) {
        final name = model.fieldNames[i];
        final val = i < fieldValues.length ? fieldValues[i].trim() : '';
        fieldMap[name] = val;
      }
    }

    // Find template for this card ord
    AnkiTemplate? template;
    if (model != null && model.templates.isNotEmpty) {
      template = model.templates.firstWhere(
        (t) => t.ord == cardOrd,
        orElse: () => model.templates.first,
      );
    }

    if (template != null && template.qfmt.isNotEmpty) {
      final clozeIndex = cardOrd + 1;

      // Render Front
      final frontRendered = _renderTemplateString(
        template: template.qfmt,
        fields: fieldMap,
        clozeIndex: clozeIndex,
        isBack: false,
      );

      // Strip audio from FrontSide before injecting into Back
      final frontSideClean = frontRendered.replaceAll(RegExp(r'\[sound:[^\]]+\]'), '');

      // Render Back
      var backTemplate = template.afmt;
      if (backTemplate.contains('{{FrontSide}}')) {
        backTemplate = backTemplate.replaceAll('{{FrontSide}}', frontSideClean);
      }

      final backRendered = _renderTemplateString(
        template: backTemplate,
        fields: fieldMap,
        clozeIndex: clozeIndex,
        isBack: true,
      );

      return RenderedCardContent(
        front: frontRendered.trim(),
        back: backRendered.trim(),
      );
    }

    // 2. Smart fallback if no template or template produces empty text
    return _fallbackRender(fieldValues, fieldMap);
  }

  static String _renderTemplateString({
    required String template,
    required Map<String, String> fields,
    required int clozeIndex,
    required bool isBack,
  }) {
    var result = template;

    // 1. Conditional blocks: {{#Field}}...{{/Field}}
    final condRegex = RegExp(r'\{\{#([^}]+)\}\}([\s\S]*?)\{\{\/\1\}\}');
    result = result.replaceAllMapped(condRegex, (m) {
      final key = m.group(1)!.trim();
      final body = m.group(2)!;
      final val = fields[key] ?? '';
      return val.isNotEmpty ? body : '';
    });

    // 2. Inverted conditional blocks: {{^Field}}...{{/Field}}
    final invCondRegex = RegExp(r'\{\{\^([^}]+)\}\}([\s\S]*?)\{\{\/\1\}\}');
    result = result.replaceAllMapped(invCondRegex, (m) {
      final key = m.group(1)!.trim();
      final body = m.group(2)!;
      final val = fields[key] ?? '';
      return val.isEmpty ? body : '';
    });

    // 3. Type-in Cloze tags: {{type:cloze:Field}}
    final typeClozeTagRegex = RegExp(r'\{\{type:cloze:([^}]+)\}\}');
    result = result.replaceAllMapped(typeClozeTagRegex, (m) {
      final key = m.group(1)!.trim();
      final raw = fields[key] ?? '';
      final answer = _extractClozeAnswer(raw, clozeIndex);
      return isBack ? '[[TYPE_RESULT:$answer]]' : '[[TYPE_INPUT:$answer]]';
    });

    // 4. Standard Cloze tags: {{cloze:Field}}
    final clozeTagRegex = RegExp(r'\{\{cloze:([^}]+)\}\}');
    result = result.replaceAllMapped(clozeTagRegex, (m) {
      final key = m.group(1)!.trim();
      final raw = fields[key] ?? '';
      return _renderCloze(raw, clozeIndex, isBack: isBack);
    });

    // 5. Type-in Field tags: {{type:Field}}
    final typeFieldTagRegex = RegExp(r'\{\{type:([^}]+)\}\}');
    result = result.replaceAllMapped(typeFieldTagRegex, (m) {
      final key = m.group(1)!.trim();
      final raw = (fields[key] ?? '').replaceAll(RegExp(r'<[^>]*>'), '').trim();
      return isBack ? '[[TYPE_RESULT:$raw]]' : '[[TYPE_INPUT:$raw]]';
    });

    // 6. Text tags: {{text:Field}}
    final textTagRegex = RegExp(r'\{\{text:([^}]+)\}\}');
    result = result.replaceAllMapped(textTagRegex, (m) {
      final key = m.group(1)!.trim();
      final raw = fields[key] ?? '';
      return raw.replaceAll(RegExp(r'<[^>]*>'), '');
    });

    // 7. Hint tags: {{hint:Field}}
    final hintTagRegex = RegExp(r'\{\{hint:([^}]+)\}\}');
    result = result.replaceAllMapped(hintTagRegex, (m) {
      final key = m.group(1)!.trim();
      final raw = fields[key] ?? '';
      return raw.isNotEmpty ? '<details><summary>Hint</summary>$raw</details>' : '';
    });

    // 8. Simple field replacements: {{Field}}
    final fieldTagRegex = RegExp(r'\{\{([^#^\/:][^}]*)\}\}');
    result = result.replaceAllMapped(fieldTagRegex, (m) {
      final key = m.group(1)!.trim();
      if (fields.containsKey(key)) {
        return fields[key]!;
      }
      return m.group(0)!;
    });

    // 9. Clean up any remaining unhandled {{...}} tags
    result = result.replaceAll(RegExp(r'\{\{[^}]+\}\}'), '');

    return result;
  }

  /// Extracts the target answer text for a specific cloze index
  static String _extractClozeAnswer(String text, int activeIndex) {
    final clozeRegex = RegExp(r'\{\{c' + activeIndex.toString() + r'::([^:]*?)(?:::([^}]*?))?\}\}');
    final match = clozeRegex.firstMatch(text);
    if (match != null) {
      return match.group(1)?.trim() ?? '';
    }
    final fallbackRegex = RegExp(r'\{\{c\d+::([^:]*?)(?:::([^}]*?))?\}\}');
    final fb = fallbackRegex.firstMatch(text);
    return fb?.group(1)?.trim() ?? '';
  }

  /// Process Anki cloze deletion: `{{c1::answer::hint}}` or `{{c1::answer}}`
  static String _renderCloze(String text, int activeIndex, {required bool isBack}) {
    final clozeRegex = RegExp(r'\{\{c(\d+)::([^:]*?)(?:::([^}]*?))?\}\}');
    return text.replaceAllMapped(clozeRegex, (m) {
      final idx = int.tryParse(m.group(1) ?? '1') ?? 1;
      final answer = m.group(2) ?? '';
      final hint = m.group(3);

      if (idx == activeIndex) {
        if (!isBack) {
          // Question: show hint or [...]
          final displayHint = (hint != null && hint.isNotEmpty) ? '[$hint]' : '[...]';
          return '<span class="cloze-hint" style="color: #3b82f6; font-weight: bold;">$displayHint</span>';
        } else {
          // Answer: show answer highlighted
          return '<span class="cloze" style="color: #3b82f6; font-weight: bold;">$answer</span>';
        }
      } else {
        // Other cloze numbers: reveal normal answer text without hint or highlight
        return answer;
      }
    });
  }

  /// Fallback when no model template is defined: preserve all multi-field content!
  static RenderedCardContent _fallbackRender(
    List<String> fieldValues,
    Map<String, String> fieldMap,
  ) {
    if (fieldValues.isEmpty) {
      return const RenderedCardContent(front: '', back: '');
    }

    final front = fieldValues[0].trim();
    if (fieldValues.length == 1) {
      return RenderedCardContent(front: front, back: '');
    }

    // Collect all remaining fields that contain data
    final backParts = <String>[];
    for (var i = 1; i < fieldValues.length; i++) {
      final val = fieldValues[i].trim();
      if (val.isNotEmpty) {
        backParts.add(val);
      }
    }

    return RenderedCardContent(
      front: front,
      back: backParts.join('<br><br>'),
    );
  }
}
