import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/sockets/socket.dart';

class CCTicker24HourItem extends CCBinaryMaskSocketItem {

  static int SUBSCRIPTION_ID = 2;

  CCTicker24HourItem(List<CoinTradingPair> coinTradingPairs, Function callback(Ticker24Hour ticker24Hour))
      : super(coinTradingPairs, SUBSCRIPTION_ID, CCBinaryMaskSocketItem.TICKER_DESIRED_FIELDS,callback);

  @override
  void parseFormattedExchangeDataMap(Map exchangeDataMap) {
    if(isCompleteTicker24Hour(exchangeDataMap)){
      this.callback(new Ticker24Hour.fromMap(exchangeDataMap));
    }
  }

  bool isCompleteTicker24Hour(Map tickerMap){
    return tickerMap.containsKey("volume24Hour") || tickerMap.containsKey("currentPrice");
  }
}

class CCTicker24HourAggItem extends CCBinaryMaskSocketItem {

  static int SUBSCRIPTION_ID = 5;

  CCTicker24HourAggItem(List<CoinTradingPair> coinTradingPairs, Function callback(Ticker24Hour ticker24Hour))
      : super(coinTradingPairs, SUBSCRIPTION_ID, CCBinaryMaskSocketItem.TICKER_DESIRED_FIELDS,callback);

  @override
  void parseFormattedExchangeDataMap(Map exchangeDataMap) {
    if(isCompleteTicker24Hour(exchangeDataMap)){
      this.callback(new Ticker24Hour.fromMap(exchangeDataMap));
    }
  }

  bool isCompleteTicker24Hour(Map tickerMap){
    return tickerMap.containsKey("volume24Hour") || tickerMap.containsKey("currentPrice");
  }
}

class CCTicker24HourTradeInfoAggItem extends CCBinaryMaskSocketItem {

  Function tradeInfoCallback;
  static int SUBSCRIPTION_ID = 5;

  CCTicker24HourTradeInfoAggItem(List<CoinTradingPair> coinTradingPairs, Function ticker24HourCallback(Ticker24Hour ticker24Hour),
      Function tradeInfoCallback(TradeInfo tradeInfo))
      : super(coinTradingPairs, SUBSCRIPTION_ID, CCBinaryMaskSocketItem.TICKER_TRADE_DESIRED_FIELDS,ticker24HourCallback){
    this.tradeInfoCallback = tradeInfoCallback;
  }

  @override
  void parseFormattedExchangeDataMap(Map exchangeDataMap) {
    if(isCompleteTradeInfo(exchangeDataMap)){
      this.tradeInfoCallback(new TradeInfo.fromMap(exchangeDataMap));
    }
    if(isCompleteTicker24Hour(exchangeDataMap)){
      exchangeDataMap["exchangeName"] = "CCCAGG";
      this.callback(new Ticker24Hour.fromMap(exchangeDataMap));
    }
  }

  bool isCompleteTicker24Hour(Map tickerMap){
    return tickerMap.containsKey("volume24Hour") || tickerMap.containsKey("currentPrice");
  }

  bool isCompleteTradeInfo(Map tradeInfoMap){
    return tradeInfoMap.containsKey("amountTraded") && tradeInfoMap.containsKey("amountPaid");
  }
}