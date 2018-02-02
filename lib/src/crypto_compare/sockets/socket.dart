import 'dart:convert';
import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:crypto_exchange_runners/src/request_items.dart';
import 'package:request_throttler/src/request_items/socket.dart';


/// Abstracts some of the commonalities between getting data from the Crypto Compare
/// socket server.
abstract class CCSocketItem extends CryptoSocketIoRequestItem {

  /// Crypto Compare identifies socket streams by an integer id.
  ///
  int subscriptionId;

  CCSocketItem(List<CoinTradingPair> coinTradingPairs, this.subscriptionId,
      Function callback(ExchangeData exchangeData)) : super(coinTradingPairs, CCHelpers.TIME_BETWEEN_HTTP_REQUESTS, callback);

  @override
  SocketEndPoint getSocketEndPoint() {
    Map<String, List<String>> subscriptionsMap = {'"subs"' : []};
    coinTradingPairs.forEach((coinTradingPair){
      if(this.subscriptionId == 5){
        coinTradingPair.exchangeName = "CCCAGG";
      }
      subscriptionsMap['"subs"'].add('"${this.subscriptionId}~${coinTradingPair.exchangeName}~${coinTradingPair.baseCoinSymbol.toUpperCase()}~${coinTradingPair.quoteCoinSymbol.toUpperCase()}"');
    });
    String handshakeData = SocketIoRequestItem.formatAsEmit("SubAdd", subscriptionsMap);
    return new SocketEndPoint("wss://streamer.cryptocompare.com/socket.io/?transport=websocket", handshakeData);
  }

  @override
  void parseReceivedData(receivedData) {
    if(receivedData.toString().substring(0, 2) == "42"){
      Map dataMap = JSON.decode('{"data" : ${receivedData.toString().substring(2)}}');
      List exchangeData = dataMap["data"][1].toString().split("~");
      if(int.parse(exchangeData[0]) == this.subscriptionId) {
        this.parseFormattedExchangeDataList(exchangeData);
      }
    }
  }

  void parseFormattedExchangeDataList(List exchangeDataList);


}

/// Abstracts some of the commonalities between getting data from the Crypto Compare
/// socket server.
abstract class CCBinaryMaskSocketItem extends CCSocketItem {

  /// The index positions of fields in the [fieldNames] list that the client
  /// wants.
  ///
  /// Common field indexes are stored in static class attributes.
  List<int> desiredFields;

  /// List of fields that could possibly be returned from the Crypto Compare
  /// socket server in a single piece of data.
  static List<String> fieldNames = ["currentPrice", "bid", "offer", "timestamp", "avg",
  "amountTraded", "amountPaid", "lastTradeId", "volumeHour", "volumeHourTo",
  "volume24Hour", "volume24HourTo", "openHour", "highHour", "lowHour",
  "open24Hour", "high24Hour", "low24Hour", "exchangeName"];

  static List<int> TICKER_DESIRED_FIELDS = [0, 3, 10, 15, 16, 17];
  static List<int> TRADE_DESIRED_FIELDS = [2, 3, 5, 6, 18];
  static List<int> TICKER_TRADE_DESIRED_FIELDS = [0, 2, 3, 5, 6, 10, 15, 16, 17, 18];

  CCBinaryMaskSocketItem(List<CoinTradingPair> coinTradingPairs, int subscriptionId, this.desiredFields,
      Function callback(ExchangeData exchangeData)) : super(coinTradingPairs, subscriptionId, callback);


  /// Intermediate step between receiving the data from the socket and delegating
  /// it do a subclass.
  ///
  /// This function implements the Crypto Compare mapping scheme to decode what
  /// information was sent over the socket.
  @override
  void parseFormattedExchangeDataList(List exchangeDataList){

    CoinTradingPair tradingPair = new CoinTradingPair(exchangeDataList[2], exchangeDataList[3], exchangeDataList[1]);
    Map exchangeDataMap = {"timestamp" : new DateTime.now().millisecondsSinceEpoch};
    exchangeDataMap["priceFlag"] = int.parse(exchangeDataList[4]);

    List<String> availableFields = new List<String>();
    availableFields.addAll(int.parse(exchangeDataList[exchangeDataList.length - 1], radix: 16).toRadixString(2).split("").reversed.join().split(""));
    while(availableFields.length < 19){
      availableFields.add("0");
    }
    int count = 1;
    for(int i = 0; i < availableFields.length; i++){
      if(availableFields[i] == "1"){
        if(this.desiredFields.contains(i)){
          if(i == 18){
            tradingPair.exchangeName = exchangeDataList[count + 4];
          } else if (i == 3) {
            exchangeDataMap[fieldNames[i]] = int.parse(exchangeDataList[count + 4]);
          } else {
            exchangeDataMap[fieldNames[i]] = double.parse(exchangeDataList[count + 4]);
          }
        }
        count++;
      }
    }
    exchangeDataMap.addAll(tradingPair.toMap());
    this.parseFormattedExchangeDataMap(exchangeDataMap);
  }

  /// Intended to be implemented by subclasses for parsing data.
  ///
  /// All Crypto Compare socket data come in the same format. [parseReceivedData]
  /// strips it down to the parts unique to each subscription stream and passes
  /// that stripped down information to [parseFormattedData] as a list.
  void parseFormattedExchangeDataMap(Map exchangeDataMap);

}