import 'package:quiver/strings.dart';

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

class Layout {
  String name;
  List<List<String>> finger_matrix;
  // rune --> finger
  Map<int, int> on_finger;
  // rune --> row
  Map<int, int> on_row;
  
  Layout(String this.name, List<List<String>> this.finger_matrix) {
    on_finger = make_finger_map(finger_matrix);
    on_row = make_row_map(finger_matrix);
  }
  
  bool finger_conflict(int a, int b) {
     return a != b && on_finger[a] == on_finger[b];  
  }
   
  bool same_hand(int a, int b) => 
      on_finger.containsKey(a) && on_finger.containsKey(b) 
      && ((on_finger[a] < 4) == (on_finger[b] < 4));
  
  bool row_conflict(int a, b) {
    return (on_row[a] == 0 && on_row[b] == 2)
        || (on_row[a] == 2 && on_row[b] == 0);  
  }
  
  static const finger_sep = '⋅';
  static const hand_sep = '-';
  String chunkify(String s) {
    var runes = s.runes;
    var prev = runes.first;
    String result = new String.fromCharCode(prev);
    for (var i = 1; i < runes.length; i++) {
      var rune = runes.elementAt(i);
      if (finger_conflict(prev, rune)) {
        result += finger_sep;
      } else if (same_hand(prev, rune) && row_conflict(prev, rune)) {
        result += hand_sep;
      }
      result += new String.fromCharCode(rune);
      prev = rune;
    }
    return result;
  }

  int single_cost(int rune) => (on_row[rune] == 1) ? 0 : 1;

  int bigram_cost(int a, int b) {
    int result = 0;
    result += finger_conflict(a, b) ? 1 : 0;
    result += (same_hand(a, b) && row_conflict(a, b) ? 1 : 0);
    result += (same_hand(a, b) && on_row[a] != 1 && on_row[a] == on_row[b]) ? -1 : 0;
    return result;
  }
  
  int cost(String s) {
    var runes = s.runes;
    var prev = runes.first;
    int result = single_cost(prev);
    for (var i = 1; i < runes.length; i++) {
      var rune = runes.elementAt(i);
      result += single_cost(rune);
      result += bigram_cost(prev, rune);
      prev = rune;
    }
    return result;
  }

  String cost_string(String s) {
    const int padding = 10;
    var d = s.length~/2 - cost(s);
    if (d < 0) {
      return repeat(' ', padding + d) + repeat('-', -d);
    }
    return repeat(' ', padding) + repeat('+', d);
  }
  
}