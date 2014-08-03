import 'package:unittest/unittest.dart';
import 'package:quiver/strings.dart';

List<int> fingers_narrow = [0, 1, 2, 3, 3, 4, 4, 5, 6, 7, 7];

List<List<int>> fingers_wide = [[0, 1, 2, 3, 3, 3, 4, 4, 5, 6, 7, 7], [0, 1, 2, 3, 3, 3, 4, 4, 5, 6, 7, 7], [0, 1, 2, 3, 3, 4, 4, 4, 5, 6, 8],// 8 is the thumb key
];

var layout_qwertz = new Layout("qwertz", fingers_narrow, ["qwert zuiopü", "asdfg hjklöä", "yxcvb nm,.-",]);
var layout_colemak = new Layout("colemak", fingers_narrow, ["qwfpg jluyüö", "arstd hneioä", "zxcvb km,.-",]);
var layout_minimak8 = new Layout("minimak 8", fingers_narrow, ["qwdrk zuilpü", "astfg hneoöä", "yxcvb jm,.-",]);
var layout_neo2 = new Layout("Neo 2", fingers_narrow, ["xvlcw khgfqß", "uiaeo snrtdy", "üöäpz bm,.j",]);
var layout_nit = new Layout("leicht-nit", fingers_narrow, ["qwerö zkuopü", "asdfg hniltä", "yxcvb jm,.-",]);
var layout_leicht = new Layout("leicht-et", fingers_narrow, ["qwödf zkuopü", "asetg hnilrä", "yxcvb jm,.-",]);
var layout_opt = new Layout("AdNW/Neo-optimal", fingers_narrow, ["kuü.ä vgcljf", "hieao dtrnsß", "xyö,q bpwmz",]);
var layout_nit_breit = new Layout("nit breit", fingers_wide, ["qwerö+ zkuopü", "asdfg' hniltä", "yxcvb- jm,._",]);
var layout_breit = new Layout("breit mit Daumen-e", fingers_wide, ["qwbfö+ zkuopü", "asdrg' hniltä", "yxcv_- jm,.e",]);

final layouts = [layout_qwertz, layout_neo2, layout_nit, layout_leicht, layout_opt, layout_colemak, layout_minimak8, 
                 layout_nit_breit, layout_breit];

class Layout {
  // constructor arguments
  String name;
  List fingers;
  List<String> layout_2d;

  // rune --> finger
  Map<int, int> on_finger = {};
  // rune --> row
  Map<int, int> on_row = {};
  Map<int, bool> base_position = {};

  Layout(String this.name, List this.fingers, List<String> this.layout_2d) {
    check_layout(fingers, layout_2d);
    make_maps(layout_2d);
  }

  int get_finger(int row, int col) {
    if (fingers[0] is int) {
      return fingers[col];
    } else {
      assert(fingers[0][0] is int);
      return fingers[row][col];
    }
  }

  String get_hand(int finger) {
    return finger < 5 ? "left" : "right";
  }

  static const BASE_POSITIONS = const [0, 1, 2, 3, 6, 7, 8, 9];
  make_maps(List<String> layout) {
    for (var row = 0; row < 3; row++) {
      String line = layout[row].replaceAll(' ', '');
      for (var col = 0; col < line.length; col++) {
        var rune = line.runes.elementAt(col);
        on_row[rune] = row;
        on_finger[rune] = get_finger(row, col);
        base_position[rune] = BASE_POSITIONS.contains(col);
      }
    }
    ;
  }

  void check_layout(List fingers, List<String> layout) {
    if (fingers == fingers_narrow) {
      layout.forEach((line) => expect(line[5], ' '));
      expect(layout[0].length, 12, reason: name + ':' + layout[0]);
      expect(layout[1].length, 12, reason: name + ':' + layout[1]);
      expect(layout[2].length, 11, reason: name + ':' + layout[2]);
    } else {
      expect(layout.length, 3);
      layout.forEach((line) => expect(line[6], ' '));
      for (int i = 0; i < layout.length; i++) {
        expect(layout[i].length, fingers[i].length + 1, reason: "$name: line $i");
      }
    }
    String letters = (layout[0] + layout[1] + layout[2]).replaceAll(' ', '');
    var lts = new Set.from(letters.runes);
    var exp_lts = new Set.from("äöü,.".runes); // don't check for ß or -
    for (var i = 'a'.runes.single; i <= 'z'.runes.single; i++) {
      exp_lts.add(i);
    }
    exp_lts.forEach((rune) => expect(lts, contains(rune), reason: name + ':' + new String.fromCharCode(rune)));
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

  bool same_hand(int a, int b) => on_finger.containsKey(a) && on_finger.containsKey(b) && ((on_finger[a] < 4) == (on_finger[b] < 4));

  bool row_conflict(int a, b) {
    return (on_row[a] == 0 && on_row[b] == 2) || (on_row[a] == 2 && on_row[b] == 0);
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

  int bigram_cost(int a, int b) => finger_conflict_cost(a, b) + row_conflict_cost(a, b) - same_row_cost_rebate(a, b);

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

class Frequency {
  String line;
  int letter, latter;
  int count;

  Frequency(String this.line) {
    var fields = line.split(' ');
    count = int.parse(fields[0]);
    String letters = fields[1].toLowerCase();
    if (letters == "") {
      letter = " ".runes.single;
    } else {
      letter = letters.runes.first;
      latter = letters.runes.last;
    }
  }

  String toString() {
    return line;
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
    buffer.writeln(repeat('-', 24 + 10));
    writeln("Total cost:             ", "$global_cost");
    return buffer.toString();
  }

  void add_single_cost(single_freq, Layout layout) {
    for (Frequency f in single_freq) {
      if (layout.on_finger[f.letter] == null) {
        // print("Ignoring letter '$letter'.");
      }
      single_cost += f.count * layout.single_cost(f.letter);
    }
  }

  void add_bigram_cost(bigram_freq, Layout layout) {
    for (Frequency f in bigram_freq) {
      if (layout.on_finger[f.letter] == null || layout.on_finger[f.latter] == null) {
        // print("Ignoring bigram '$letters'.");
      }
      row_rebate += f.count * layout.same_row_cost_rebate(f.letter, f.latter);
      finger_conflicts += f.count * layout.finger_conflict_cost(f.letter, f.latter);
      row_conflicts += f.count * layout.row_conflict_cost(f.letter, f.latter);
    }
  }


}
