class CloudinaryConfig {
  const CloudinaryConfig._();

  static const String cloudName = 'kyazyt6i'; 

  static const String uploadPreset = 'raporta_reports';

  static String get uploadUrl =>
      'https://api.cloudinary.com/v1_1/'
      '$cloudName/image/upload';

  static const int maxFileSize = 5 * 1024 * 1024;
}
