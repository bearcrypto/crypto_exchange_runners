import 'dart:convert';
import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:request_throttler/request_items.dart';

class CCCoinDetails extends CallbackHttpRequestItem {

  String coinId;
  String proxyUrl;


  CCCoinDetails(this.coinId, Function callback(CoinInfo coinDetails), {this.proxyUrl})
      : super.oneTimeRequest(CCHelpers.TIME_BETWEEN_HTTP_REQUESTS, callback);

  @override
  List<HttpEndPoint> getApiEndPoints() {
    return [new HttpEndPoint("${this.proxyUrl != null ? this.proxyUrl : ""}"
        "${CCHelpers.STANDARD_API_BASE_URL}data/coinsnapshotfullbyid/?id=${this.coinId}")];
  }

  @override
  void parseReceivedData(String receivedData, HttpEndPoint dataSource) {
    print(receivedData);
    try {
    Map coinListMap = JSON.decode(receivedData.toString());
    if(coinListMap["Response"] == "Success"){

        String baseImageUrl = coinListMap["Data"]["SEO"]["BaseImageUrl"];
        List<String> startDateList = coinListMap["Data"]["General"]["StartDate"].split("/");
        DateTime startDate = new DateTime(int.parse(startDateList[2]), int.parse(startDateList[1]), int.parse(startDateList[0]));

        CoinInfo coinInfo = new CoinInfo.extended(
            coinListMap["Data"]["General"]["Name"],
            coinListMap["Data"]["General"]["Symbol"],
            coinListMap["Data"]["General"]["Algorithm"],
            coinListMap["Data"]["General"]["ProofType"],
            0,
            baseImageUrl + coinListMap["Data"]["General"]["ImageUrl"],
            this.coinId,
            coinListMap["Data"]["General"]["Description"],
            coinListMap["Data"]["General"]["AffiliateUrl"],
            startDate,
            int.parse(coinListMap["Data"]["General"]["TotalCoinSupply"]),
            coinListMap["Data"]["General"]["TotalCoinsMined"],
            coinListMap["Data"]["General"]["Twitter"]
        );



      this.callback(coinInfo);
    }
    } catch(e, stackTrace){
      print(e);
      print(stackTrace);
    }
  }
}