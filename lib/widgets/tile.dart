import 'package:flutter/material.dart';
import 'package:test_app/models/note.dart';

class Tile extends StatelessWidget {
  final NoteState state;
  final double height;
  final VoidCallback onTap;

  const Tile({
    super.key,
    required this.height,
    required this.state,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => onTap(),
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          color: _getColor(),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Color _getColor() {
    switch (state) {
      case NoteState.ready:
        return Colors.black;
      case NoteState.missed:
        return Colors.red;
      case NoteState.tapped:
        return Colors.transparent;
    }
  }
}