import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:request_throttler/request_items.dart';


abstract class CryptoSocketIoRequestItem extends CallbackSocketIoRequestItem {
  List<CoinTradingPair> coinTradingPairs;

  CryptoSocketIoRequestItem(this.coinTradingPairs, Duration timeBetweenRequests, Function callback(ExchangeData exchangeData))
      : super.recurring(timeBetweenRequests, callback);

}

abstract class CryptoHttpRequestItem extends CallbackHttpRequestItem {
  List<CoinTradingPair> coinTradingPairs;

  CryptoHttpRequestItem(this.coinTradingPairs, Duration timeBetweenRequests, Function callback)
      : super.oneTimeRequest(timeBetweenRequests, callback);

}

abstract class CandleStickHttpRequestItem extends CryptoHttpRequestItem {

  Duration duration;
  int aggregate;
  int limit;

  CandleStickHttpRequestItem(List<CoinTradingPair> coinTradingPairs, Duration timeBetweenRequests,
      this.duration, this.limit, this.aggregate, Function callback)
      : super(coinTradingPairs, timeBetweenRequests, callback);
}

class CryptoHttpEndPoint extends HttpEndPoint {
  CoinTradingPair coinTradingPair;

  CryptoHttpEndPoint(String url, this.coinTradingPair) : super(url);
}