import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/sockets/socket.dart';

class CCTradeInfoItem extends CCSocketItem {

  static int SUBSCRIPTION_ID = 0;

  CCTradeInfoItem(List<CoinTradingPair> coinTradingPairs, Function callback(TradeInfo tradeInfo))
      : super(coinTradingPairs, SUBSCRIPTION_ID, callback);

  @override
  void parseFormattedExchangeDataList(List exchangeDataList) {
    this.callback(new TradeInfo(
        new CoinTradingPair(exchangeDataList[2], exchangeDataList[3], exchangeDataList[1]),
        new DateTime.fromMillisecondsSinceEpoch(int.parse(exchangeDataList[6])),
        double.parse(exchangeDataList[7]),
        double.parse(exchangeDataList[9]),
        int.parse(exchangeDataList[4])
    )
    );
  }
}

class CCTradeInfoAggItem extends CCBinaryMaskSocketItem {

  static int SUBSCRIPTION_ID = 5;

  CCTradeInfoAggItem(List<CoinTradingPair> coinTradingPairs, Function callback(TradeInfo tradeInfo))
      : super(coinTradingPairs, SUBSCRIPTION_ID, CCBinaryMaskSocketItem.TRADE_DESIRED_FIELDS,callback){
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