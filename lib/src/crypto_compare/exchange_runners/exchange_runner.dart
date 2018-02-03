import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/request_items.dart';
import 'package:crypto_exchange_runners/src/crypto_runner.dart';

abstract class CCCryptoExchangeRunner extends CryptoExchangeRunner {

  dynamic socketThrottler;
  dynamic httpThrottler;
  String proxyUrl;
  
  SocketItemState tradeItem = new SocketItemState();
  SocketItemState aggTradeItem = new SocketItemState();
  SocketItemState ticker24HourItem = new SocketItemState();
  SocketItemState aggTicker24HourItem = new SocketItemState();
  SocketItemState aggTicker24HourTradeInfoItem = new SocketItemState();
  
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

    if(this._getNonAggregationPairs(coinTradingPairs).isNotEmpty){
      if(this.ticker24HourItem.socketItem == null){
        this.ticker24HourItem.socketItem = new CCTicker24HourItem(this._getNonAggregationPairs(coinTradingPairs), callback);
        this.socketThrottler.addQueuableItem(
            this.ticker24HourItem.socketItem
        );
        this.ticker24HourItem.isQueued = true;
      } else {
        this._subscribeToSocketStream(this.ticker24HourItem, this._getNonAggregationPairs(coinTradingPairs), CCTicker24HourItem.SUBSCRIPTION_ID);
      }
    }
    if(this._getAggregationPairs(coinTradingPairs).isNotEmpty){
      if(this.aggTicker24HourItem.socketItem == null){
        this.aggTicker24HourItem.socketItem = new CCTicker24HourAggItem(this._getAggregationPairs(coinTradingPairs), callback);
        this.socketThrottler.addQueuableItem(
            this.aggTicker24HourItem.socketItem
        );
        this.aggTicker24HourItem.isQueued = true;
      } else {
        this._subscribeToSocketStream(this.aggTicker24HourItem, this._getAggregationPairs(coinTradingPairs), CCTicker24HourAggItem.SUBSCRIPTION_ID);
      }
    }
  }

  @override
  void subscribeToTradeInfo(List<CoinTradingPair> coinTradingPairs, callback(TradeInfo tradeInfo)) {
    if(this._getNonAggregationPairs(coinTradingPairs).isNotEmpty){
      if(this.tradeItem.socketItem == null){
        this.tradeItem.socketItem = new CCTradeInfoItem(this._getNonAggregationPairs(coinTradingPairs), callback);
        this.socketThrottler.addQueuableItem(
            this.tradeItem.socketItem
        );
        this.tradeItem.isQueued = true;
      } else {
        this._subscribeToSocketStream(this.tradeItem, this._getNonAggregationPairs(coinTradingPairs), CCTradeInfoItem.SUBSCRIPTION_ID);
      }
    }

    if(this._getAggregationPairs(coinTradingPairs).isNotEmpty){
      if(this.aggTradeItem.socketItem == null){
        this.aggTradeItem.socketItem = new CCTradeInfoAggItem(this._getAggregationPairs(coinTradingPairs), callback);
        this.socketThrottler.addQueuableItem(
            this.aggTradeItem.socketItem
        );
        this.aggTradeItem.isQueued = true;
      } else {
        this._subscribeToSocketStream(this.aggTradeItem, this._getAggregationPairs(coinTradingPairs), CCTradeInfoAggItem.SUBSCRIPTION_ID);
      }
    }
  }

  void subscribeToTicker24HourAndTradeInfo(List<CoinTradingPair> coinTradingPairs, ticker24HourCallback(Ticker24Hour ticker24Hour),
      tradeInfoCallback(TradeInfo tradeInfo)){

    if(coinTradingPairs.isNotEmpty){
      if(this.aggTicker24HourTradeInfoItem.socketItem == null){
        this.aggTicker24HourTradeInfoItem.socketItem = new CCTicker24HourTradeInfoAggItem(this._getAggregationPairs(coinTradingPairs), ticker24HourCallback, tradeInfoCallback);
        this.socketThrottler.addQueuableItem(
            this.aggTicker24HourTradeInfoItem.socketItem
        );
        this.aggTicker24HourTradeInfoItem.isQueued = true;
      } else {
        this._subscribeToSocketStream(this.aggTicker24HourTradeInfoItem, coinTradingPairs, CCTicker24HourTradeInfoAggItem.SUBSCRIPTION_ID);
      }
    }
  }

  void unsubscribeFromTradeInfo(List<CoinTradingPair> coinTradingPairs){
    if(this.aggTradeItem.socketItem != null){
      this._unsubscribeFromSocketStream(this.aggTradeItem, this._getAggregationPairs(coinTradingPairs), CCTradeInfoAggItem.SUBSCRIPTION_ID);

    }
    if(this.tradeItem.socketItem != null){
      this._unsubscribeFromSocketStream(this.tradeItem, this._getNonAggregationPairs(coinTradingPairs), CCTradeInfoItem.SUBSCRIPTION_ID);
    }
  }

  void unsubscribeFromTicker24Hour(List<CoinTradingPair> coinTradingPairs){
    if(this.aggTicker24HourItem.socketItem != null){
      this._unsubscribeFromSocketStream(this.aggTicker24HourItem, this._getAggregationPairs(coinTradingPairs), CCTicker24HourAggItem.SUBSCRIPTION_ID);

    }
    if(this.ticker24HourItem.socketItem != null){
      this._unsubscribeFromSocketStream(this.ticker24HourItem, this._getNonAggregationPairs(coinTradingPairs), CCTicker24HourItem.SUBSCRIPTION_ID);
    }
  }

  void unsubscribeFromTicker24HourAndTradeInfo(List<CoinTradingPair> coinTradingPairs){
    this._unsubscribeFromSocketStream(this.aggTicker24HourTradeInfoItem, coinTradingPairs, CCTicker24HourTradeInfoAggItem.SUBSCRIPTION_ID);
  }


  // HELPERS

  List<CoinTradingPair> _getAggregationPairs(List<CoinTradingPair> coinTradingPairs){
    List<CoinTradingPair> aggregationItems = [];
    aggregationItems.addAll(coinTradingPairs.where((coinTradingPair){
      return coinTradingPair.exchangeName == "CCCAGG";
    }));
    return aggregationItems;
  }

  List<CoinTradingPair> _getNonAggregationPairs(List<CoinTradingPair> coinTradingPairs) {
    List<CoinTradingPair> nonAggregationItems = [];
    nonAggregationItems.addAll(coinTradingPairs.where((coinTradingPair){
      return coinTradingPair.exchangeName != "CCCAGG";
    }));
    return nonAggregationItems;
  }

  void _subscribeToSocketStream(SocketItemState socketItemState, List<CoinTradingPair> coinTradingPairs, int subscriptionId){
    if(socketItemState.isQueued){
      socketItemState.socketItem.sendDataOverSocket(
          CCSocketItem.getSubscriptionMessage(coinTradingPairs, subscriptionId, true)
      );
      CoinTradingPair.saveListOfCoinTradingPairInList(coinTradingPairs, socketItemState.socketItem.coinTradingPairs);
    } else {
      CoinTradingPair.saveListOfCoinTradingPairInList(coinTradingPairs, socketItemState.socketItem.coinTradingPairs);
      this.socketThrottler.addQueuableItem(
          socketItemState.socketItem
      );
      socketItemState.isQueued = true;
    }
  }

  void _unsubscribeFromSocketStream(SocketItemState socketItemState, List<CoinTradingPair> coinTradingPairs, int subscriptionId){
    if(socketItemState.isQueued){
      socketItemState.socketItem.sendDataOverSocket(
          CCSocketItem.getSubscriptionMessage(coinTradingPairs, subscriptionId, false)
      );
    }
    coinTradingPairs.forEach((pair1){
      socketItemState.socketItem.coinTradingPairs.removeWhere((pair2){
        return CoinTradingPair.haveSameValue(pair1, pair2);
      });
    });
    if(socketItemState.socketItem.coinTradingPairs.isEmpty){
      socketThrottler.removeQueableItem(socketItemState.socketItem);
      socketItemState.isQueued = false;
    }
  }


}

class SocketItemState {
  CCSocketItem socketItem;
  bool isQueued = false;
}