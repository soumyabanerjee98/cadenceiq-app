const String environment = "UAT";

const Map<String, String> baseUrl = {
  "UAT": "http://localhost:8000/api",
  "LIVE": "https://cadenceiq.onrender.com/api",
};

abstract final class ApiUrl {
  static final String base = baseUrl[environment]!;

  static const refreshToken = '/auth/refresh-token';
}
