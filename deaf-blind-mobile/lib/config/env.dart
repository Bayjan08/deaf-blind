/// Environment configuration: dev/prod backend URLs.
/// Local Docker backend runs on :9000; dev/prod are the Cloud Run URLs.
class Env {
  static const String backendDev = 'http://localhost:9000';
  static const String backendProd = 'https://deaf-blind-api-prod-xxxxx.a.run.app';

  /// Active base URL. Swap per build flavor.
  static const String baseUrl = backendDev;
  static const String apiPrefix = '/api/v1';
}
