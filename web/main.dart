// Copyright (c) 2017, regonn. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:html';
import 'package:googleapis_auth/auth_browser.dart' as auth;
import 'package:googleapis/youtube/v3.dart' as youtube;

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
            var u = new SpeechSynthesisUtterance();
            u.text = video.snippet.title;
            u.lang = 'ja-JP';
            u.rate = 1.2;
            window.speechSynthesis.speak(u);
          }
        });
      }
    });
  });
}
