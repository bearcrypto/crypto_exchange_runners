import 'dart:convert';
import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:request_throttler/request_items.dart';
import 'package:crypto_exchange_model/crypto_exchange_model.dart';


class CCExchangeListItem extends CallbackHttpRequestItem {

  CCExchangeListItem(Function callback(List<Exchange> exchanges))
      : super.oneTimeRequest(CCHelpers.TIME_BETWEEN_HTTP_REQUESTS, callback);

  @override
  List<HttpEndPoint> getApiEndPoints() {
    return [new HttpEndPoint("${CCHelpers.MIN_API_BASE_URL}data/all/exchanges")];
  }

  @override
  void parseReceivedData(String receivedData, HttpEndPoint dataSource) {
    Map exchangeListMap = JSON.decode(receivedData.toString());
    List<Exchange> exchanges = new List<Exchange>();
    exchangeListMap.forEach((String exchangeName, Map<String, List<String>>coinPairMap){
      List<CoinPair> coinPairs = new List<CoinPair>();
      coinPairMap.forEach((String baseCoin, List<String> listOfQuoteCoins){
        listOfQuoteCoins.forEach((quoteCoin){
          coinPairs.add(new CoinPair(baseCoin, quoteCoin));
        });
      });
      exchanges.add(new Exchange(exchangeName, coinPairs));
    });
    this.callback(exchanges);
  }
}


//https://min-api.cryptocompare.com/data/all/exchanges