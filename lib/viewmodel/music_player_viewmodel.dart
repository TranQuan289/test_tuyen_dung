import 'dart:convert';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:music_app/model/lyric_model.dart';
import 'package:music_app/viewmodel/base_view_model.dart';
import 'package:http/http.dart' as http;
import 'package:xml/xml.dart' as xml;

const String beat = "https://storage.googleapis.com/ikara-storage/tmp/beat.mp3";
const String lyric =
    "https://storage.googleapis.com/ikara-storage/ikara/lyrics.xml";

class MusicPlayerViewModel extends BaseViewModel {
  late AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void onInitView(BuildContext context) {
    super.onInitView(context);
    _audioPlayer = AudioPlayer();

    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      notifyListeners();
    });
    _audioPlayer.onDurationChanged.first.then((duration) {
      _totalDuration = duration.inMilliseconds;
      caculatorRemainingMinutes(_totalDuration, _currentTime);
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((position) {
      _currentTime = position.inMilliseconds;
      _progressValue = (_currentTime / _totalDuration);
      int minutes = (_currentTime / 60000).floor();
      int seconds = ((_currentTime % 60000) / 1000).floor();
      _formattedTime = '$minutes:${seconds.toString().padLeft(2, '0')}';
      caculatorRemainingMinutes(_totalDuration, _currentTime);
      notifyListeners();
    });
    loadXmlData();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  int _currentTime = 0;

  int get currentTime => _currentTime;

  String _formattedTime = '0:00';
  String get formattedTime => _formattedTime;

  int _totalDuration = 0;

  String _remainingTime = '0:00';
  String get remainingTime => _remainingTime;

  double _progressValue = 0.0;
  double get progressValue => _progressValue;

  List<Lyric> lyrics = [];

  void loadXmlData() async {
    try {
      final response = await http.get(Uri.parse(lyric));

      if (response.statusCode == 200) {
        final xmlString = utf8.decode(response.bodyBytes);
        final document = xml.XmlDocument.parse(xmlString);

        List<Lyric> parsedLyrics = [];

        for (var param in document.findAllElements('param')) {
          List<LyricItem> lyricItems = [];

          for (var item in param.findAllElements('i')) {
            String va = item.getAttribute('va') ?? '0.0';
            String text = item.innerText;
            lyricItems.add(LyricItem(va: va, text: text, colors: Colors.black));
          }

          String s = param.getAttribute('s') ?? '0';
          parsedLyrics.add(Lyric(s: s, items: lyricItems));
        }

        lyrics = parsedLyrics;
        await _audioPlayer.setSource(UrlSource(beat));

        notifyListeners();
      }
    } catch (e) {
      return;
    }
  }

  void play() async {
    await _audioPlayer.play(UrlSource(beat));
    notifyListeners();
  }

  void pause() async {
    await _audioPlayer.pause();
    notifyListeners();
  }

  void seek(double value) {
    int seekTime = (_totalDuration * value).round();
    _audioPlayer.seek(Duration(milliseconds: seekTime));
    notifyListeners();
  }

  void caculatorRemainingMinutes(int totalDuration, int currentTime) {
    int remainingSeconds = ((totalDuration - currentTime) / 1000).floor();
    int remainingMinutes = (remainingSeconds / 60).floor();
    remainingSeconds %= 60;
    _remainingTime =
        '$remainingMinutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
