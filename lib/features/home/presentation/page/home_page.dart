import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  AudioPlayer player = AudioPlayer();

  @override
  Widget build(BuildContext context) {
    Future.delayed(Durations.short4).then((value) {
      player.play(AssetSource("audio/success.mp3"));
    });
    return Column(
      children: [
      ],
    );
  }
}
