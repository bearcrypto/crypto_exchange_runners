import 'package:crypto_exchange_runners/src/crypto_compare/exchange_runners/exchange_runner.dart';
import 'package:request_throttler/vm_throttlers.dart';

class CCVmExchangeRunner extends CCCryptoExchangeRunner {
  CCVmExchangeRunner() : super(new SocketIoConnectionThrottler.empty(), new HttpRequestThrottler.empty());
}