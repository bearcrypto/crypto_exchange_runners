import 'dart:convert';
import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:request_throttler/request_items.dart';

class CCMiningRigsItem extends CallbackHttpRequestItem{

  String proxyUrl;

  CCMiningRigsItem(Function callback(List<MiningRig> miningRigs), {this.proxyUrl})
      : super.oneTimeRequest(CCHelpers.TIME_BETWEEN_HTTP_REQUESTS, callback);


  @override
  List<HttpEndPoint> getApiEndPoints() {
    return [new HttpEndPoint("${this.proxyUrl != null ? this.proxyUrl : ""}"
        "${CCHelpers.STANDARD_API_BASE_URL}data/miningequipment/")];
  }

  @override
  void parseReceivedData(String receivedData, HttpEndPoint dataSource) {
    Map miningRigsMap = JSON.decode(receivedData.toString());
    if(miningRigsMap["Response"] == "Success"){
      List<MiningRig> miningRigs = new List<MiningRig>();
      String baseImageUrl = miningRigsMap["BaseImageUrl"];
      miningRigsMap["MiningData"].forEach((String id, Map miningRigDataMap){
        String powerConsumption = miningRigDataMap["PowerConsumption"].toString().toLowerCase();
        if(powerConsumption.contains("w")){
          powerConsumption = powerConsumption.replaceAll("w", "");
        }
        miningRigs.add(new MiningRig(
              id,
              miningRigDataMap["Name"],
              "https://www.cryptocompare.com" + miningRigDataMap["LogoUrl"],
              miningRigDataMap["AffiliateURL"],
              miningRigDataMap["Algorithm"],
              int.parse(miningRigDataMap["HashesPerSecond"]),
              double.parse(miningRigDataMap["Cost"]),
              miningRigDataMap["Currency"],
              int.parse(powerConsumption),
              new CoinInfo(miningRigDataMap["CurrenciesAvailableName"], miningRigDataMap["CurrenciesAvailable"], null, null, null, "https://www.cryptocompare.com" + miningRigDataMap["CurrenciesAvailableLogo"], null),
              miningRigDataMap["EquipmentType"]
          )
        );
      });
      this.callback(miningRigs);
    }
  }
}




//https://www.cryptocompare.com/api/data/miningequipment/