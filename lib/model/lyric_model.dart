import 'package:flutter/material.dart';

class Lyric {
  String s;
  List<LyricItem> items;

  Lyric({required this.s, required this.items});
}

class LyricItem {
  String va;
  String text;
  Color colors;

  LyricItem({required this.va, required this.text, required this.colors});
}
