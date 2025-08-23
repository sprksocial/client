class AppSpacing {
  AppSpacing._();

  // Base unit - All spacing should be multiples of this
  static const double baseUnit = 8;

  // Spacing scale
  static const double xs = baseUnit * 0.5;  // 4pt
  static const double sm = baseUnit;        // 8pt
  static const double md = baseUnit * 2;    // 16pt
  static const double lg = baseUnit * 3;    // 24pt
  static const double xl = baseUnit * 4;    // 32pt
  static const double xxl = baseUnit * 5;   // 40pt
  static const double xxxl = baseUnit * 6;  // 48pt

  // Semantic spacing - Use these for specific purposes
  static const double componentPaddingSmall = sm;     // 8pt
  static const double componentPaddingMedium = md;    // 16pt
  static const double componentPaddingLarge = lg;     // 24pt
  
  static const double sectionSpacing = xl;            // 32pt
  static const double pageMargin = md;                // 16pt
  static const double listItemSpacing = sm;          // 8pt
}
