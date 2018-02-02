import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/sockets/socket.dart';

class CCTradeInfoItem extends CCSocketItem {

  CCTradeInfoItem(List<CoinTradingPair> coinTradingPairs, Function callback(TradeInfo tradeInfo))
      : super(coinTradingPairs, 0, callback);

  @override
  void parseFormattedExchangeDataList(List exchangeDataList) {
    print(exchangeDataList);
    try {
      this.callback(new TradeInfo(
          new CoinTradingPair(exchangeDataList[2], exchangeDataList[3], exchangeDataList[1]),
          new DateTime.fromMillisecondsSinceEpoch(int.parse(exchangeDataList[6])),
          double.parse(exchangeDataList[7]),
          double.parse(exchangeDataList[9]),
          int.parse(exchangeDataList[4])
      )
      );
    } catch (e, stackTrace){
      print(e);
      print(stackTrace);
    }

  }
}

class CCTradeInfoAggItem extends CCBinaryMaskSocketItem {
  CCTradeInfoAggItem(List<CoinTradingPair> coinTradingPairs, Function callback(TradeInfo tradeInfo))
      : super(coinTradingPairs, 5, CCBinaryMaskSocketItem.TRADE_DESIRED_FIELDS,callback){
  }

  @override
  void parseFormattedExchangeDataMap(Map exchangeDataMap) {
    if(isCompleteTradeInfo(exchangeDataMap)){
      this.callback(new TradeInfo.fromMap(exchangeDataMap));
    }
  }

  bool isCompleteTradeInfo(Map tradeInfoMap){
    return tradeInfoMap.containsKey("amountTraded") && tradeInfoMap.containsKey("amountPaid");
  }
}