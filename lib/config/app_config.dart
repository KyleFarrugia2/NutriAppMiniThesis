/// Public URLs and contact details for the web build and tester feedback.
///
/// Override at compile time, e.g.:
/// `flutter build web --dart-define=FEEDBACK_FORM_URL=https://forms.gle/...`
class AppConfig {
  AppConfig._();

  /// Google Form (or similar) for structured tester feedback. Empty = show setup hint only.
  static const feedbackFormUrl = String.fromEnvironment(
    'FEEDBACK_FORM_URL',
    defaultValue: '',
  );

  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'kyle.farrugia.j94928@mcast.edu.mt',
  );

  /// Live site URL (set via Vercel env PUBLIC_WEB_URL or dart-define at build).
  static const publicWebUrl = String.fromEnvironment(
    'PUBLIC_WEB_URL',
    defaultValue: '',
  );

  static String get shareableWebUrl {
    final u = publicWebUrl.trim();
    if (u.isNotEmpty && Uri.tryParse(u)?.hasScheme == true) return u;
    return 'https://your-app.vercel.app';
  }

  static bool get hasFeedbackForm =>
      feedbackFormUrl.trim().isNotEmpty &&
      Uri.tryParse(feedbackFormUrl.trim())?.hasScheme == true;
}
