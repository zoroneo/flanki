/// Utility to format raw camelCase keys from formulas and extraGuides
/// into elegant, human-readable section titles.
class GrammarKeyBeautifier {
  const GrammarKeyBeautifier._();

  static const Map<String, String> _customTitles = {
    // Tenses & Aspect
    'presentSimple': 'Hiện tại đơn (Present Simple)',
    'presentContinuous': 'Hiện tại tiếp diễn (Present Continuous)',
    'pastSimple': 'Quá khứ đơn (Past Simple)',
    'pastContinuous': 'Quá khứ tiếp diễn (Past Continuous)',
    'presentPerfect': 'Hiện tại hoàn thành (Present Perfect)',
    'presentPerfectContinuous':
        'Hiện tại hoàn thành tiếp diễn (Present Perfect Continuous)',
    'pastPerfect': 'Quá khứ hoàn thành (Past Perfect)',
    'will': 'Tương lai đơn với "Will"',
    'beGoingTo': 'Tương lai gần với "Be Going To"',
    'presentContinuousForFuture':
        'Hiện tại tiếp diễn chỉ tương lai có kế hoạch',
    'presentSimpleForTimetable': 'Hiện tại đơn cho lịch trình / thời gian biểu',
    'futureTimeClauses': 'Mệnh đề thời gian ở tương lai (Future Time Clauses)',
    'basicTenses': 'Công thức các thì cơ bản (Basic Tenses)',
    'actionVsStativeVerbs':
        'Động từ hành động vs. Động từ trạng thái (Action vs. Stative)',
    'sinceForAndStructures': 'Cấu trúc Since / For và các biến thể',
    'timeConnectorsAndStructures':
        'Liên từ thời gian & Cấu trúc đặc biệt (Before, After, By the time)',

    // Guides & Traps
    'stativeVerbsGuide': 'Cẩm nang động từ trạng thái (Stative Verbs)',
    'whenWhileRules': 'Quy tắc kết hợp liên từ When, While & As',
    'pastHabitsAndStative':
        'Thói quen quá khứ (Used to / Would) & Động từ trạng thái',
    'modalVerbs': 'Động từ khuyết thiếu (Modal Verbs)',
    'modalPerfect': 'Modal Verbs trong quá khứ (Modal Perfect)',
    'modalPerfectGuide':
        'Cẩm nang suy đoán & Nuối tiếc quá khứ (Modal Perfect)',
    'causative': 'Thể truyền khiến / Cầu khiến (Causative Form)',
    'activeCausatives': 'Động từ cầu khiến chủ động (Have / Make / Get / Let)',
    'passiveCausatives':
        'Động từ cầu khiến bị động (Have / Get something done)',
    'advancedStructures': 'Cấu trúc nâng cao & Bị động đặc biệt',
    'inversionAndAlternatives': 'Đảo ngữ câu điều kiện & Các cấu trúc thay thế',

    // Conditionals & Subjunctive
    'type0': 'Điều kiện Loại 0 (Chân lý khoa học / Quy luật)',
    'type1': 'Điều kiện Loại 1 (Có thể xảy ra ở hiện tại / tương lai)',
    'type2': 'Điều kiện Loại 2 (Trái ngược thực tế ở hiện tại)',
    'type3': 'Điều kiện Loại 3 (Trái ngược thực tế trong quá khứ)',
    'mixed': 'Điều kiện hỗn hợp (Mixed Conditionals)',
    'wishAndIfOnly': 'Cấu trúc Wish & If only',
    'wouldRatherAndTime': 'Cấu trúc Would Rather & It\'s Time',
    'presentSubjunctive': 'Thể giả định hiện tại (Present Subjunctive)',

    // Prepositions & Parts of Speech
    'caseTable': 'Bảng hệ thống đại từ & Sở hữu (Pronoun Case Paradigm)',
    'pyramidTimeAndPlace': 'Kim tự tháp không gian & thời gian (In - On - At)',
    'deadlinesAndDuration':
        'Phân biệt thời hạn & Độ dài (By vs. Until / For vs. During)',
    'motionAndDirection': 'Giới từ chuyển động & Phương hướng',
    'dependentPrepositions': 'Cụm giới từ cố định bắt buộc nhớ',
    'functionalPhrases': 'Cụm giới từ chức năng công sở',
    'osascomp': 'Trật tự tính từ trước danh từ (OSASCOMP)',
    'whetherVsIf': 'Ràng buộc cú pháp giữa Whether và If',
    'toVsForVerbs': 'Động từ dùng To (Chuyển giao) vs. For (Lợi ích / Làm hộ)',

    // SVA & Parallelism & Modifiers
    'correlativeAndIntervening': 'Cấu trúc hô ứng & Thành phần can thiệp',
    'quantifiersAndIndefinite': 'Từ định lượng, phân số & Đại từ bất định',
    'separableVerbs': 'Cụm động từ có thể tách rời (Separable Phrasal Verbs)',
    'inseparableVerbs':
        'Cụm động từ không tách rời (Inseparable Phrasal Verbs)',
    'threePartVerbs': 'Cụm động từ 3 thành phần (Three-Word Phrasal Verbs)',
    'standardTagRules':
        'Nguyên tắc câu hỏi đuôi chuẩn (Standard Tag Questions)',
    'specialSubjectTags': 'Câu hỏi đuôi với chủ ngữ đặc biệt',
    'participleAspectVoice': 'Phân loại 4 dạng phân từ theo thời gian & Thể',
    'danglingParticipleRules':
        'Quy tắc khắc phục bổ ngữ lơ lửng (Dangling Modifiers)',
  };

  /// Converts a raw key into a formatted, human-readable title.
  static String format(String rawKey) {
    if (rawKey.isEmpty) return '';

    final mapped = _customTitles[rawKey];
    if (mapped != null) return mapped;

    // Fallback: Split camelCase into Title Case
    final buffer = StringBuffer();
    for (var i = 0; i < rawKey.length; i++) {
      final char = rawKey[i];
      if (i > 0 &&
          char.toUpperCase() == char &&
          rawKey[i - 1].toLowerCase() == rawKey[i - 1]) {
        buffer.write(' ');
      }
      if (i == 0) {
        buffer.write(char.toUpperCase());
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
