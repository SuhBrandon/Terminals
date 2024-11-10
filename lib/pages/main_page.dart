import 'package:flutter/material.dart';
import 'package:test_app/game_logic.dart';
import 'package:test_app/widgets/line_divider.dart';
import 'package:provider/provider.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with SingleTickerProviderStateMixin {
  late GameLogic gameLogic;

  @override
  void initState() {
    super.initState();
    gameLogic = GameLogic(this);
  }

  @override
  void dispose() {
    gameLogic.dispose();
    super.dispose();
  }

  Widget _buildScore() {
    return Consumer<GameLogic>(
      builder: (context, game, _) => Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Score: ${game.points}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            Text(
              'High Score: ${game.highScore}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: gameLogic,
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/background.jpg',
              fit: BoxFit.cover,
            ),
            SafeArea(
              child: Column(
                children: [
                  _buildScore(),
                  Expanded(
                    child: Row(
                      children: [
                        gameLogic.buildLine(0),
                        const LineDivider(),
                        gameLogic.buildLine(1),
                        const LineDivider(),
                        gameLogic.buildLine(2),
                        const LineDivider(),
                        gameLogic.buildLine(3),
                      ],
                    ),
                  ),
                  Consumer<GameLogic>(
                    builder: (context, game, _) => Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                        onPressed: game.isPlaying ? null : game.start,
                        child: Text(
                          game.isPlaying ? 'PLAYING' : 'START GAME',
                          style: TextStyle(
                            fontSize: 20,
                            color: game.isPlaying ? Colors.grey : Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LineDivider extends StatelessWidget {
  const LineDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      color: Colors.white.withOpacity(0.2),
    );
  }
}