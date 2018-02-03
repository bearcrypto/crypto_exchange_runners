import 'package:crypto_exchange_model/crypto_exchange_model.dart';

abstract class CryptoExchangeRunner {

  void getCoinList(callback(List<CoinInfo> coinList));

  void getCoinDetails(String coinId, callback(CoinInfo coinDetails));

   void getExchangeList(callback(List<Exchange> exchangeList));

   void getMiningRigList(callback(List<MiningRig> miningRigList));

   void getSearchSuggestions(String searchQuery, callback(List<CoinInfo> searchSuggestions));

  void getSimilarCoins(String coinId, callback(List<CoinInfo> similarCoins));

  void getCandleSticks(CoinTradingPair coinTradingPair, Duration duration, int aggregate, int limit, callback(List<CandleStick> candleSticks));

  void getNewsStories(callback(List<News> newsStories));

  void subscribeToTradeInfo(List<CoinTradingPair> coinTradingPairs, callback(TradeInfo tradeInfo));

  void subscribeToTicker24Hour(List<CoinTradingPair> coinTradingPairs, callback(Ticker24Hour ticker24Hour));

  void unsubscribeFromTradeInfo(List<CoinTradingPair> coinTradingPairs);

  void unsubscribeFromTicker24Hour(List<CoinTradingPair> coinTradingPairs);

}