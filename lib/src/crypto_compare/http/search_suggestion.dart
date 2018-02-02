import 'dart:convert';
import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:request_throttler/request_items.dart';

class CCSearchSuggestionItem extends CallbackHttpRequestItem{
  String searchQuery;
  String proxyUrl;
  CCSearchSuggestionItem(this.searchQuery, Function callback(List<CoinInfo> coins), {this.proxyUrl})
      : super.oneTimeRequest(CCHelpers.TIME_BETWEEN_HTTP_REQUESTS, callback);


  @override
  List<HttpEndPoint> getApiEndPoints() {
    return [new HttpEndPoint("${this.proxyUrl != null ? this.proxyUrl : ""}"
        "${CCHelpers.STANDARD_API_BASE_URL}autosuggest/all/?maxRows=10&q=${this.searchQuery}")];
  }

  @override
  void parseReceivedData(String receivedData, HttpEndPoint dataSource) {
    Map coinListMap = JSON.decode(receivedData.toString());
    if(coinListMap["Response"] == "Success"){
      List<CoinInfo> coins = new List<CoinInfo>();
      String baseImageUrl = coinListMap["BaseImageUrl"];
      coinListMap["Results"].forEach((result){
        if(result["group"] == "Coins"){
          coins.add(
              new CoinInfo.nameOnly(
                result["nodeName"]
              )
          );
        }
      });
      this.callback(coins);
    }
  }
}






//https://www.cryptocompare.com/api/autosuggest/all/?maxRows=10&q=b