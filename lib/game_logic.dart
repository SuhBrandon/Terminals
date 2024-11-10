import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameLogic extends ChangeNotifier {
  final audioPlayer = AudioPlayer();
  final TickerProvider vsync;
  late AnimationController _controller;
  final List<List<bool>> _tiles =
      List.generate(4, (_) => List.filled(4, false));
  int points = 0;
  int highScore = 0;
  bool isPlaying = false;
  Timer? _gameTimer;
  double tileSpeed = 2000; // milliseconds for tiles to fall

  GameLogic(this.vsync) {
    _controller = AnimationController(
      vsync: vsync,
      duration: Duration(milliseconds: tileSpeed.toInt()),
    );
    _loadHighScore();
    _setupAudio();
  }

  Future<void> _setupAudio() async {
    await audioPlayer.setSource(AssetSource('assets/audio/a.wav'));
    await audioPlayer.setReleaseMode(ReleaseMode.loop);
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    highScore = prefs.getInt('highScore') ?? 0;
    notifyListeners();
  }

  Future<void> _saveHighScore() async {
    if (points > highScore) {
      highScore = points;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('highScore', highScore);
      notifyListeners();
    }
  }

  void start() async {
    if (isPlaying) return;
    isPlaying = true;
    points = 0;
    _resetTiles();
    _generateNewRow();
    _startGameLoop();
    await audioPlayer.resume();
    notifyListeners();
  }

  void _resetTiles() {
    for (var line in _tiles) {
      line.fillRange(0, 4, false);
    }
  }

  void _startGameLoop() {
    _gameTimer =
        Timer.periodic(Duration(milliseconds: tileSpeed.toInt()), (timer) {
      _generateNewRow();
    });
    _controller.repeat();
  }

  void _generateNewRow() {
    // Check if bottom row was missed
    for (int line = 0; line < 4; line++) {
      if (_tiles[line][0]) {
        _gameOver();
        return;
      }
    }

    // Move existing tiles down
    for (int line = 0; line < 4; line++) {
      for (int i = 0; i < 3; i++) {
        _tiles[line][i] = _tiles[line][i + 1];
      }
    }

    // Generate new tile at the top
    int randomLine = Random().nextInt(4);
    for (int line = 0; line < 4; line++) {
      _tiles[line][3] = line == randomLine;
    }

    // Increase speed as score increases
    if (points > 0 && points % 10 == 0) {
      tileSpeed = max(500, tileSpeed * 0.95);
      _controller.duration = Duration(milliseconds: tileSpeed.toInt());
    }

    notifyListeners();
  }

  Widget buildLine(int lineIndex) {
    return Expanded(
      child: Column(
        children: List.generate(4, (index) => _buildTile(lineIndex, index)),
      ),
    );
  }

  Widget _buildTile(int lineIndex, int tileIndex) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _onTileTap(lineIndex, tileIndex),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          margin: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            color: _tiles[lineIndex][tileIndex]
                ? Colors.black
                : Colors.transparent,
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void _onTileTap(int lineIndex, int tileIndex) {
    if (!isPlaying || !_tiles[lineIndex][tileIndex]) {
      _gameOver();
      return;
    }

    points++;
    _tiles[lineIndex][tileIndex] = false;
    notifyListeners();
  }

  Future<void> _gameOver() async {
    isPlaying = false;
    _gameTimer?.cancel();
    _controller.stop();
    await audioPlayer.pause();
    await _saveHighScore();
    notifyListeners();
  }

  @override
  void dispose() {
    _controller.dispose();
    _gameTimer?.cancel();
    audioPlayer.dispose();
    super.dispose();
  }
}
