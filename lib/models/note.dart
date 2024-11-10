class Note {
  final int orderNumber;
  final int line;
  NoteState state;

  Note(this.orderNumber, this.line, {this.state = NoteState.ready});
}

enum NoteState { ready, tapped, missed }