import 'package:flutter_dotenv/flutter_dotenv.dart';

/// API Constants Base URL and Endpoints
class ApiConstants {
  static String get baseUrl =>
      dotenv.maybeGet('BASE_URL') ?? 'https://admin.rudhiraksh.com/api';
}
