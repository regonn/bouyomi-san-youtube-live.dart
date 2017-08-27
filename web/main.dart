// Copyright (c) 2017, regonn. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'dart:async';
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis/youtube/v3.dart' as youtube;

DateTime lastMessagedAt = new DateTime.now();

void main() {
  InputElement apiKeyInput = querySelector('#api-key');
  InputElement channelIdInput = querySelector('#channel-id');
  ButtonElement setButton = querySelector('#set-button');

  displayOutput('APIキーとチャンネルを設定してください。');
  speak('起動しました。エーピーアイキーとチャンネルを設定してください。');

  setButton.onClick.listen((_) {
    var apiKey = apiKeyInput.value;
    var client = auth.clientViaApiKey(apiKey);
    var api = new youtube.YoutubeApi(client);
    api.search.list("id", channelId: channelIdInput.value, type: 'video', eventType: 'live').then((youtube.SearchListResponse response) {
      var liveVideoId = null;
      if (response.items != null) {
        liveVideoId = response.items.first.id.videoId;
        api.videos.list("liveStreamingDetails,snippet", id: liveVideoId).then((youtube.VideoListResponse videoResponse) {
          var liveChatId = null;
          if (videoResponse.items != null) {
            var video = videoResponse.items.first;
            liveChatId = video.liveStreamingDetails.activeLiveChatId;
            var title = video.snippet.title;
            speak('$title のチャンネルに設定されました');
            displayOutput(title);
            lastMessagedAt = new DateTime.now();
            const duration = const Duration(seconds:5);
            new Timer.periodic(duration, (Timer t) => speakNewMessages(api, liveChatId));
          }
        });
      }
    });
  });
}

void speakNewMessages(youtube.YoutubeApi api, String liveChatId) {
  api.liveChatMessages.list(liveChatId, 'snippet').then((youtube.LiveChatMessageListResponse messagesResponse) {
    if (messagesResponse.items != null) {
      var speakMessages = messagesResponse.items.where((item)=> item.snippet.publishedAt.isAfter(lastMessagedAt)).toList();
      for(youtube.LiveChatMessage message in speakMessages ){
        lastMessagedAt = message.snippet.publishedAt;
        print(lastMessagedAt);
        speak(message.snippet.displayMessage);
      }
    }
  });
}

void speak(String text) {
  var u = new SpeechSynthesisUtterance();
  u.text = text;
  u.lang = 'ja-JP';
  u.rate = 1.4;
  window.speechSynthesis.speak(u);
}

void displayOutput(String text) {
  querySelector('#output').text = text;
}
