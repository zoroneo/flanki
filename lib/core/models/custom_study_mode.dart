/// Mode for Custom Study / Cram session filtering.
enum CustomStudyMode {
  byTag('byTag'),
  flagged('flagged'),
  reviewAhead('ahead');

  final String value;
  const CustomStudyMode(this.value);

  static CustomStudyMode fromString(String? val) {
    if (val == null) return CustomStudyMode.byTag;
    for (final mode in CustomStudyMode.values) {
      if (mode.value == val || mode.name == val) return mode;
    }
    if (val == 'reviewAhead') return CustomStudyMode.reviewAhead;
    return CustomStudyMode.byTag;
  }
}
