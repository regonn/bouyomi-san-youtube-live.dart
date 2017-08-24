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

  querySelector('#output').text = 'Your Dart app is running.';

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
            speak(video.snippet.title);
            lastMessagedAt = new DateTime.now();
            const oneSec = const Duration(seconds:5);
            new Timer.periodic(oneSec, (Timer t) => speakNewMessage(api, liveChatId));
          }
        });
      }
    });
  });
}

void speakNewMessage(youtube.YoutubeApi api, String liveChatId) {
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
  u.pitch = 0.8;
  window.speechSynthesis.speak(u);
}
