import 'dart:convert';
import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:request_throttler/request_items.dart';

class CCSimilarCoins extends CallbackHttpRequestItem {

  String coinId;
  String proxyUrl;

  CCSimilarCoins(this.coinId, Function callback(List<CoinInfo> similarCoins), {this.proxyUrl})
      : super.oneTimeRequest(CCHelpers.TIME_BETWEEN_HTTP_REQUESTS, callback);

  @override
  List<HttpEndPoint> getApiEndPoints() {
    return [new HttpEndPoint("${this.proxyUrl != null ? this.proxyUrl : ""}"
        "${CCHelpers.STANDARD_API_BASE_URL}data/socialstats/?id=${this.coinId}")];
  }

  @override
  void parseReceivedData(String receivedData, HttpEndPoint dataSource) {
    Map coinListMap = JSON.decode(receivedData.toString());
    if(coinListMap["Response"] == "Success"){
      List<CoinInfo> coins = new List<CoinInfo>();
      coinListMap["Data"]["CryptoCompare"]["SimilarItems"].forEach((Map similarItem){
        coins.add(new CoinInfo(
            similarItem["FullName"],
            null,
            null,
            null,
            null,
            "https://www.cryptocompare.com/" + similarItem["ImageUrl"],
            similarItem["Id"].toString()
        )
        );
      });
      this.callback(coins);
    }
  }
}