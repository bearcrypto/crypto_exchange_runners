import 'dart:convert';
import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:request_throttler/src/request_items/http.dart';

class CCCoinListItem extends CallbackHttpRequestItem {

  CCCoinListItem(Function callback(List<CoinInfo> coins))
      : super.oneTimeRequest(CCHelpers.TIME_BETWEEN_HTTP_REQUESTS, callback);

  @override
  List<HttpEndPoint> getApiEndPoints() {
    return [new HttpEndPoint("${CCHelpers.MIN_API_BASE_URL}data/all/coinlist")];
  }

  @override
  void parseReceivedData(String receivedData, HttpEndPoint dataSource) {
    Map coinListMap = JSON.decode(receivedData.toString());
    if(coinListMap["Response"] == "Success"){
      List<CoinInfo> coins = new List<CoinInfo>();
      String baseImageUrl = coinListMap["BaseImageUrl"];
      coinListMap["Data"].forEach((key, value){
        coins.add(
            new CoinInfo(
                value["CoinName"],
                value["Symbol"],
                value["Algorithm"],
                value["ProofType"],
                int.parse(value["SortOrder"]),
                baseImageUrl + value["ImageUrl"].toString(),
                value["Id"]
            )
        );
      });
      coins.sort((CoinInfo a, CoinInfo b){
        return a.sortOrder.compareTo(b.sortOrder);
      });
      this.callback(coins);
    }
  }
}