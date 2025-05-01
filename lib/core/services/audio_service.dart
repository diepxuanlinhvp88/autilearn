import 'package:audioplayers/audioplayers.dart';

class AudioService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMuted = false;

  bool get isMuted => _isMuted;

  Future<void> playCorrectSound() async {
    if (!_isMuted) {
      await _audioPlayer.play(AssetSource('audio/correct.mp3'));
    }
  }

  Future<void> playWrongSound() async {
    if (!_isMuted) {
      await _audioPlayer.play(AssetSource('audio/wrong.mp3'));
    }
  }

  Future<void> playSuccessSound() async {
    if (!_isMuted) {
      await _audioPlayer.play(AssetSource('audio/success.mp3'));
    }
  }

  Future<void> playClickSound() async {
    if (!_isMuted) {
      await _audioPlayer.play(AssetSource('audio/click.mp3'));
    }
  }

  void toggleMute() {
    _isMuted = !_isMuted;
  }

  void setMute(bool mute) {
    _isMuted = mute;
  }

  Future<void> dispose() async {
    await _audioPlayer.dispose();
  }
}
