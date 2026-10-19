
class CloudinaryConfig {
  CloudinaryConfig._();

  static const String cloudName = 'eg1emi5z';

  static const String uploadPreset = 'expense_receipts_unsigned';

  static const String uploadFolder = 'expense_receipts';

  static const int maxFileSizeInBytes = 10 * 1024 * 1024;

  static const List<String> allowedFormats = [
    'jpg',
    'jpeg',
    'png',
    'webp',
  ];

  static String get imageUploadUrl =>
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload';
}
