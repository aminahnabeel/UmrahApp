import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class PlayAudioIcon extends StatefulWidget {
  final String assetPath;
  const PlayAudioIcon({super.key, required this.assetPath});

  @override
  State<PlayAudioIcon> createState() => _PlayAudioIconState();
}

class _PlayAudioIconState extends State<PlayAudioIcon> {
  late final AudioPlayer _player;
  bool _isPlaying = false;

  @override
  void initState() {
    super.initState();
    _player = AudioPlayer();
    _player.onPlayerStateChanged.listen((PlayerState state) {
      setState(() {
        _isPlaying = state == PlayerState.playing;
      });
    });
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void _toggleAudio() async {
    if (_isPlaying) {
      await _player.pause();
    } else {
      // Remove 'assets/' prefix for AssetSource (original logic)
      String asset = widget.assetPath.replaceFirst('assets/', '');
      await _player.play(AssetSource(asset));
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(_isPlaying ? Icons.pause : Icons.volume_up),
      onPressed: _toggleAudio,
    );
  }
}
