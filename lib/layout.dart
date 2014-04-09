import 'package:unittest/unittest.dart';
import 'package:quiver/strings.dart';

var fingers = [0, 1, 2, 3, 3, 4, 4, 5, 6, 7, 7];

var layout_qwertz = new Layout("qwertz",
    ["qwert zuiopü",
     "asdfg hjklöä",
     "yxcvb nm,.ß",
     ]);
var layout_neo2 = new Layout("Neo 2",
    ["xvlcw khgfqß",
     "uiaeo snrtdy",
     "üöäpz bm,.j",
     ]);
var layout_nit = new Layout("leicht-nit",
    ["qwerö zkuopü",
    "asdfg hniltä",
    "yxcvb jm,.-",
    ]);
var layout_leicht = new Layout("leicht-er",
    ["qwöfd zkuopü",
     "aserg hniltä",
     "yxcvb jm,.-",
    ]);
var layout_bj = new Layout("leicht-er-bj",
    ["qwöfd zkuopü",
     "aserg hniltä",
     "yxcvj bm,.-",
    ]);
var layout_kfzd = new Layout("leicht-er-kfzd",
    ["qwökf zduopü",
     "aserg hniltä",
     "yxcvb jm,.-",
    ]);
var layout_opt = new Layout("AdNW/Neo-optimal",
    ["kuü.ä vgcljf",
     "hieao dtrnsß",
     "xyö,q bpwmz",
     ]);

final layouts = [layout_qwertz, layout_neo2, layout_nit, layout_leicht, layout_opt];

class Layout {
  String name;
  List<String> layout_2d;
  // rune --> finger
  Map<int, int> on_finger = {};
  // rune --> row
  Map<int, int> on_row = {};
  Map<int, bool> base_position = {};
  
  Layout(String this.name, List<String> this.layout_2d) {
    check_layout(layout_2d);
    // on_finger = make_on_finger(layout_2d);
    // on_row = make_on_row(layout_2d);
    make_maps(layout_2d);
  }
  
  static const BASE_POSITIONS = const [0, 1, 2, 3, 6, 7, 8, 9];  
  make_maps(List<String> layout) {
    for (var row = 0; row < 3; row++) {
      String line = layout[row].replaceAll(' ', ''); 
      for (var col = 0; col < line.length; col++) {
        var rune = line.runes.elementAt(col);
        on_row[rune] = row;
        on_finger[rune] = fingers[col];
        base_position[rune] = BASE_POSITIONS.contains(col);
      }
   };
  }
  
  void check_layout(List<String> layout) {
    layout.forEach((line) => expect(line[5], ' '));
    expect(layout[0].length, 12, reason:name + ':' + layout[0]);
    expect(layout[1].length, 12, reason:name + ':' + layout[1]);
    expect(layout[2].length, 11, reason:name + ':' + layout[2]);
    String letters = (layout[0] + layout[1] + layout[2]).replaceAll(' ', '');
    var lts = new Set.from(letters.runes);
    var exp_lts = new Set.from("äöüß,.".runes);
    for (var i = 'a'.runes.single; i <= 'z'.runes.single; i++) {
      exp_lts.add(i);
    }
    exp_lts.forEach((rune) => 
        expect(lts, contains(rune), 
            reason: name + ':' + new String.fromCharCode(rune)
        ));
  }
  
  String adnw_format() {
    String flat_layout = layout_2d.join().replaceAll(' ', '');
    var nobreakspace = new String.fromCharCode(0xa0);
    String spaceless_name = name.replaceAll(' ', nobreakspace);
    return "$flat_layout    $spaceless_name";
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

  int single_cost(int rune) => (on_row[rune] == 1 && base_position[rune]) ? 0 : 1;

  int bigram_cost(int a, int b) 
    => finger_conflict_cost(a, b) + row_conflict_cost(a, b) - same_row_cost_rebate(a, b);

  int same_row_cost_rebate(int a, int b) => (same_hand(a, b) && on_row[a] != 1 && on_row[a] == on_row[b]) ? 1 : 0;

  int row_conflict_cost(int a, int b) => (same_hand(a, b) && row_conflict(a, b) ? 1 : 0);

  int finger_conflict_cost(int a, int b) => finger_conflict(a, b) ? 1 : 0;
  
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
}

class Cost {
  int single_cost = 0;  
  int row_rebate = 0;
  int finger_conflicts = 0;
  int row_conflicts = 0;
  
  int get global_cost => single_cost - row_rebate + row_conflicts + finger_conflicts;
  
  String toString() {
    var buffer = new StringBuffer();
    writeln(String label, String thing) {
      buffer.writeln(label + padLeft(thing, 10, ' '));
    }
    writeln("Finger moves:           ", "$single_cost");
    writeln("-- rebate for same row: ", "$row_rebate");
    writeln("Finger conflicts:       ", "$finger_conflicts");
    writeln("Row conflicts:          ", "$row_conflicts");
    buffer.writeln(repeat('-', 24+10));
    writeln("Total cost:             ", "$global_cost");
    return buffer.toString();
  }
  
  void add_single_cost(single_freq, Layout layout) {
    for (String line in single_freq) {
      if (line.length==0)
        continue;
      var fields = line.split(' '); 
      int n = int.parse(fields[0]);
      String letter = fields[1].toLowerCase();
      int rune = letter.runes.single;
      if (layout.on_finger[rune] == null) {
        // print("Ignoring letter '$letter'.");
      }
      single_cost += n * layout.single_cost(rune);
    }
  }

  void add_bigram_cost(bigram_freq, Layout layout) {
    for (String line in bigram_freq) {
      if (line.length==0)
        continue;
      var fields = line.split(' '); 
      int n = int.parse(fields[0]);
      String letters = fields[1].toLowerCase();
      int a = letters.runes.first;
      int b = letters.runes.last;
      if (layout.on_finger[a] == null || layout.on_finger[b] == null ) {
        // print("Ignoring bigram '$letters'.");
      }
      row_rebate += n * layout.same_row_cost_rebate(a, b);
      finger_conflicts += n * layout.finger_conflict_cost(a, b);
      row_conflicts += n * layout.row_conflict_cost(a, b);
    }
  }


}