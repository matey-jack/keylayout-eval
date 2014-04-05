class Layout {
  String name;
  List<List<String>> layout;
  // rune --> finger
  Map<int, int> on_finger;
  // rune --> row
  Map<int, int> on_row;
  
  Layout(String this.name, List<List<String>> this.layout) {
    on_finger = make_finger_map(layout);
    on_row = make_row_map(layout);
  }
  
  Map<int, int> make_finger_map(List<List<String>> finger_matrix) {
    var result = {};
    for (var i = 0; i < finger_matrix.length; i++) {
      finger_matrix[i].forEach((str) =>
          str.runes.forEach((r) => result[r] = i));
    }
    return result;
  }

  Map<int, int> make_row_map(List<List<String>> finger_matrix) {
    var result = {};
    finger_matrix.forEach((list) {
          for (var i = 0; i < 3; i++) {
          list[i].runes.forEach((r) => result[r] = i);
    }});
    return result;
  }
}