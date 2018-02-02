import 'dart:convert';
import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:crypto_exchange_runners/src/request_items.dart';
import 'package:request_throttler/src/request_items/http.dart';

class CCCandleStickItem extends CandleStickHttpRequestItem {
  CCCandleStickItem(List<CoinTradingPair> coinTradingPairs,
      Duration duration, int limit, int aggregate, Function callback(List<CandleStick> candleSticks))
      : super(coinTradingPairs, CCHelpers.TIME_BETWEEN_HTTP_REQUESTS, duration, limit, aggregate, callback);


  @override
  List<HttpEndPoint> getApiEndPoints() {
    List<CryptoHttpEndPoint> httpEndPoints = new List<CryptoHttpEndPoint>();
    String apiBase = "${CCHelpers.MIN_API_BASE_URL}data/";
    String historyString = "histoday";
    if(duration.inMinutes == const Duration(minutes: 1).inMinutes){
      historyString = "histominute";
    } else if(duration.inMinutes == const Duration(hours: 1).inMinutes){
      historyString = "histohour";
    }
    coinTradingPairs.forEach((coinTradingPair){
      httpEndPoints.add(new CryptoHttpEndPoint("${apiBase}${historyString}?"
          "fsym=${coinTradingPair.baseCoinSymbol}&"
          "tsym=${coinTradingPair.quoteCoinSymbol}&"
          "limit=${limit}&"
          "aggregate=${aggregate}&"
          "e=${coinTradingPair.exchangeName}", coinTradingPair));
    });
    return httpEndPoints;
  }

  @override
  void parseReceivedData(String receivedData, HttpEndPoint dataSource) {
    if(dataSource is CryptoHttpEndPoint){
      try {
        Map coinListMap = JSON.decode(receivedData.toString());
        print(coinListMap);
        if(coinListMap["Response"] == "Success"){
          List<CandleStick> candleSticks = new List<CandleStick>();
          coinListMap["Data"].forEach((candleStick){
            candleSticks.add(
                new CandleStick(
                    new CoinTradingPair(dataSource.coinTradingPair.baseCoinSymbol,
                        dataSource.coinTradingPair.quoteCoinSymbol,
                        dataSource.coinTradingPair.exchangeName),
                    new DateTime.now(),
                    new DateTime.fromMillisecondsSinceEpoch(candleStick["time"]),
                    new Duration(milliseconds: this.duration.inMilliseconds * this.aggregate),
                    double.parse(candleStick["open"].toString()),
                    double.parse(candleStick["close"].toString()),
                    double.parse(candleStick["high"].toString()),
                    double.parse(candleStick["low"].toString()),
                    double.parse(candleStick["volumefrom"].toString())
                )
            );
          });

          candleSticks.sort((CandleStick a, CandleStick b){
            return a.openTime.compareTo(b.openTime);
          });
          this.callback(candleSticks);
        }
      }catch(e, stackTrace){
        print(e);
        print(stackTrace);
      }
    }
  }
}