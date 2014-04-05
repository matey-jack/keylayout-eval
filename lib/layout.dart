import 'package:quiver/strings.dart';
import 'package:unittest/unittest.dart';

var fingers = [0, 1, 2, 3, 3, 4, 4, 5, 6, 7, 7];

var layout_qwertz = new Layout("qwertz",
    ["qwert zuiopü",
     "asdfg hjklöä",
     "yxcvb nm,.ß",
    ]);
var layout_neo2 = ["xvlcw khgfqß",
                   "uiaeo snrtdy",
                   "üöäpz bm,.j",
                   ];
var layout_nit = ["qwerß zkuopü",
                  "asdfg hniltä",
                  "yxcvb jm,.ö",
                  ];
var layout_leicht = ["qwßfd zkuopü",
                     "aserg hniltä",
                     "yxcvb jm,.ö",
                     ];

Map<int, int> make_on_row(List<String> layout) {
  var result = {};
  for (var i = 0; i < 3; i++) {
    String line = layout[i].replaceAll(' ', ''); 
    line.runes.forEach((r) => result[r] = i);
  };
  return result;
}

Map<int, int> make_on_finger(List<String> layout) {
  var result = {};
  layout.forEach((f_line) {
      var line = f_line.replaceAll(' ', ''); 
      for (var i = 0; i < line.length; i++) {
        result[line.runes.elementAt(i)] = fingers[i];
      }
  });
  return result;
}

bool check_row(String row, int len) {
  return false;
}

void check_layout(List<String> layout) {
  layout.forEach((line) => expect(line[5], ' '));
  expect(layout[0].length, 12, reason:layout[0]);
  expect(layout[1].length, 12, reason:layout[1]);
  expect(layout[2].length, 11, reason:layout[2]);
  String letters = (layout[0] + layout[1] + layout[2]).replaceAll(' ', '');
  var lts = new Set.from(letters.runes);
  var exp_lts = new Set.from("äöüß,.".runes);
  for (var i = 'a'.runes.single; i <= 'z'.runes.single; i++) {
    exp_lts.add(i);
  }
  exp_lts.forEach((rune) => expect(lts, contains(rune), reason: new String.fromCharCode(rune)));
}

class Layout {
  String name;
  List<String> layout_2d;
  // rune --> finger
  Map<int, int> on_finger;
  // rune --> row
  Map<int, int> on_row;
  
  Layout(String this.name, List<String> this.layout_2d) {
    on_finger = make_on_finger(layout_2d);
    on_row = make_on_row(layout_2d);
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