import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/exchange_runners/exchange_runner.dart';
import 'package:request_throttler/browser_throttlers.dart';

class CCBrowserExchangeRunner extends CCCryptoExchangeRunner {

  CCBrowserExchangeRunner() : super(new SocketIoConnectionThrottler.empty(),
      new HttpRequestThrottler.empty(), proxyUrl: CCHelpers.CORS_PROXY_BASE_URL);
}