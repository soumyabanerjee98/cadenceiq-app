import 'package:flutter_dotenv/flutter_dotenv.dart';

class Env {
  static String get apiKey => dotenv.env["API_KEY"]!;
  static String get mapApiKey => dotenv.env["MAP_API_KEY"]!;
}
