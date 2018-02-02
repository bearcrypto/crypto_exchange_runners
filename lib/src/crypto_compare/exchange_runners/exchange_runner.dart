import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/request_items.dart';
import 'package:crypto_exchange_runners/src/crypto_runner.dart';

abstract class CCCryptoExchangeRunner extends CryptoExchangeRunner {

  dynamic socketThrottler;
  dynamic httpThrottler;
  String proxyUrl;

  CCCryptoExchangeRunner(this.socketThrottler, this.httpThrottler, {this.proxyUrl}){
    socketThrottler.start();
    httpThrottler.start();
  }

  @override
  void getCandleSticks(CoinTradingPair coinTradingPair, Duration duration,
      int aggregate, int limit, callback(List<CandleStick> candleSticks)) {
    this.httpThrottler.addQueuableItem(
        new CCCandleStickItem([coinTradingPair], duration, limit, aggregate, callback)
    );
  }

  @override
  void getCoinDetails(String coinId, callback(CoinInfo coinDetails)) {
    this.httpThrottler.addQueuableItem(
      new CCCoinDetails(coinId, callback)
    );
  }

  @override
  void getCoinList(callback(List<CoinInfo> coinList)) {
    this.httpThrottler.addQueuableItem(
        new CCCoinListItem(callback)
    );
  }

  @override
  void getExchangeList(callback(List<Exchange> exchangeList)) {
    this.httpThrottler.addQueuableItem(
        new CCExchangeListItem(callback)
    );
  }

  @override
  void getMiningRigList(callback(List<MiningRig> miningRigList)) {
    this.httpThrottler.addQueuableItem(
        new CCMiningRigsItem(callback, proxyUrl: this.proxyUrl != null ?this.proxyUrl : "")
    );
  }

  @override
  void getSearchSuggestions(String searchQuery, callback(List<CoinInfo> searchSuggestions)) {
    this.httpThrottler.addQueuableItem(
        new CCSearchSuggestionItem(searchQuery, callback, proxyUrl: this.proxyUrl != null ?this.proxyUrl : "")
    );
  }

  @override
  void getSimilarCoins(String coinId, callback(List<CoinInfo> similarCoins)) {
    this.httpThrottler.addQueuableItem(
        new CCSimilarCoins(coinId, callback, proxyUrl: this.proxyUrl != null ?this.proxyUrl : "")
    );
  }

  @override
  void getNewsStories(callback(List<News> newsStories)){
    this.httpThrottler.addQueuableItem(
        new CCNewsItem(callback)
    );
  }

  @override
  void subscribeToTicker24Hour(List<CoinTradingPair> coinTradingPairs, callback(Ticker24Hour ticker24Hour)) {
    List<CoinTradingPair> aggregationItems = [];
    aggregationItems.addAll(coinTradingPairs.where((coinTradingPair){
      return coinTradingPair.exchangeName == "CCCAGG";
    }));
    List<CoinTradingPair> nonAggregationItems = [];
    nonAggregationItems.addAll(coinTradingPairs.where((coinTradingPair){
      return coinTradingPair.exchangeName != "CCCAGG";
    }));

    this.socketThrottler.addQueuableItem(
        new CCTicker24HourItem(nonAggregationItems, callback)
    );

    this.socketThrottler.addQueuableItem(
        new CCTicker24HourAggItem(aggregationItems, callback)
    );
  }

  @override
  void subscribeToTradeInfo(List<CoinTradingPair> coinTradingPairs, callback(TradeInfo tradeInfo)) {
    List<CoinTradingPair> aggregationItems = [];
    aggregationItems.addAll(coinTradingPairs.where((coinTradingPair){
      return coinTradingPair.exchangeName == "CCCAGG";
    }));
    List<CoinTradingPair> nonAggregationItems = [];
    nonAggregationItems.addAll(coinTradingPairs.where((coinTradingPair){
      return coinTradingPair.exchangeName != "CCCAGG";
    }));

    this.socketThrottler.addQueuableItem(
        new CCTradeInfoItem(nonAggregationItems, callback)
    );

    this.socketThrottler.addQueuableItem(
        new CCTradeInfoAggItem(aggregationItems, callback)
    );
  }

  void subscribeToTicker24HourAndTradeInfo(List<CoinTradingPair> coinTradingPairs, ticker24HourCallback(Ticker24Hour ticker24Hour),
      tradeInfoCallback(TradeInfo tradeInfo)){
    this.socketThrottler.addQueuableItem(
        new CCTicker24HourTradeInfoAggItem(coinTradingPairs, ticker24HourCallback, tradeInfoCallback)
    );
  }
}