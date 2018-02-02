library crypto_compare;

export 'exchange_runners/browser_runner.dart';
export 'exchange_runners/vm_runner.dart';

class CCHelpers {
  static Duration TIME_BETWEEN_HTTP_REQUESTS = const Duration(milliseconds: 85);
  static String MIN_API_BASE_URL = "https://min-api.cryptocompare.com/";
  static String STANDARD_API_BASE_URL = "https://www.cryptocompare.com/api/";
  static String CORS_PROXY_BASE_URL = "http://crossorigin.herokuapp.com/";
}
