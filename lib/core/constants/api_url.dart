const String environment = "UAT";

const Map<String, String> baseUrl = {
  "UAT":
      "https://df19-2409-40d0-1173-54e5-d126-b4bc-4ea7-60fe.ngrok-free.app/api",
  "LIVE": "https://cadenceiq.onrender.com/api",
};

abstract final class ApiUrl {
  static final String base = baseUrl[environment]!;

  static const login = '/auth/login';
  static const register = '/auth/register';
  static const profile = '/auth/profile';
  static const refreshToken = '/auth/refresh-token';
}
