import 'package:flutter/material.dart';
import 'package:music_app/viewmodel/music_player_viewmodel.dart';
import 'package:provider/provider.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MusicPlayerViewModel musicPlayerViewModel;

  @override
  void initState() {
    super.initState();
    musicPlayerViewModel = MusicPlayerViewModel();
    musicPlayerViewModel.onInitView(context);
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: musicPlayerViewModel,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Music app'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Consumer<MusicPlayerViewModel>(
                    builder: (_, music, __) => ListView.builder(
                      physics: const ClampingScrollPhysics(),
                      itemCount: music.lyrics.length,
                      itemBuilder: (context, index) {
                        var section = music.lyrics[index];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            for (var item in section.items)
                              AnimatedDefaultTextStyle(
                                duration: const Duration(milliseconds: 1000),
                                style: TextStyle(
                                  color: double.parse(item.va.trim()) <
                                          (music.currentTime / 1000)
                                      ? Colors.red
                                      : Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                                child: Text(item.text),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<MusicPlayerViewModel>(
                          builder: (_, music, __) => Text(
                            music.formattedTime.toString(),
                          ),
                        ),
                        Consumer<MusicPlayerViewModel>(
                          builder: (_, music, __) => Text(
                            music.remainingTime.toString(),
                          ),
                        ),
                      ],
                    ),
                    Consumer<MusicPlayerViewModel>(
                      builder: (_, music, __) => Slider(
                        value: music.progressValue,
                        onChanged: (value) {
                          music.seek(value);
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Consumer<MusicPlayerViewModel>(
                          builder: (_, music, __) => IconButton(
                            icon: music.isPlaying
                                ? const Icon(Icons.pause)
                                : const Icon(Icons.play_arrow),
                            onPressed:
                                music.isPlaying ? music.pause : music.play,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
