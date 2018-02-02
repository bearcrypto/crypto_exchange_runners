import 'dart:convert';
import 'package:crypto_exchange_model/crypto_exchange_model.dart';
import 'package:crypto_exchange_runners/src/crypto_compare/crypto_compare.dart';
import 'package:request_throttler/request_items.dart';

class CCNewsItem extends CallbackHttpRequestItem {

  CCNewsItem(Function callback(List<News> newsStories))
      : super.oneTimeRequest(const Duration(milliseconds: 250), callback);

  @override
  List<HttpEndPoint> getApiEndPoints() {
    return [new HttpEndPoint("${CCHelpers.MIN_API_BASE_URL}data/news/")];
  }

  @override
  void parseReceivedData(String receivedData, HttpEndPoint dataSource) {
    Map newsStoriesMap = JSON.decode('{ "Data" : ${receivedData.toString()}}');
    List<News> newsStories = new List<News>();
    newsStoriesMap["Data"].forEach((newsStory){
      newsStories.add(
          new News(
              newsStory["title"],
              newsStory["url"],
              newsStory["imageurl"],
              newsStory["source"],
              newsStory["tags"].split("|"),
              new DateTime.fromMillisecondsSinceEpoch(newsStory["published_on"]),
              newsStory["body"],
              newsStory["lang"]
          )
      );
    });
    this.callback(newsStories);
  }
}