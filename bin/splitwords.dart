import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:quiver/strings.dart';

print_lines(List<String> lines, int num_lines) {
  for (int i = 0; i < lines.length && i < num_lines; i++) {
    print(lines[i]);
  }
}

var fingers = [0, 1, 2, 3, 3, 4, 4, 5, 6, 7, 7];

var layout_qwertz = ["qwert zuiopü",
                     "asdfg hjklöä",
                     "yxcvb nm,.-",
                     ];
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

bool has_all_letters(List<String> layout) {
  return false;
}
// first version only with finger conflicts, no hand conflicts
var fingers_nit = [
  ['q', 'a', 'y'],
  ['w', 's', 'x'],
  ['e', 'd', 'c'], 
  ['rß', 'fg', 'vb'],
  ['zk', 'hn', 'jm'],
  ['u', 'i', ','],
  ['o', 'l', '.'],
  ['pü', 'tä', 'ö'],
 ];
var fingers_er = [
  ['q', 'a', 'y'],
  ['w', 's', 'x'],
  ['ß', 'e', 'c'], 
  ['fd', 'rg', 'vb'],
  ['zk', 'hn', 'jm'],
  ['u', 'i', ','],
  ['o', 'l', '.'],
  ['pü', 'tä', 'ö'],
 ];
const finger_sep = '⋅';
const hand_sep = '-';

sum(Iterable<int> list) {
  return list.fold(0, (prev, element) => prev + element);
}

count(List<List<String>> matrix) {
  return sum(matrix.map((list) => 
      sum(list.map((str) => str.length))
      ));
}

// rune --> finger
Map<int, int> make_finger_map(List<List<String>> finger_matrix) {
  var result = {};
  for (var i = 0; i < finger_matrix.length; i++) {
    finger_matrix[i].forEach((str) =>
        str.runes.forEach((r) => result[r] = i));
  }
  return result;
}

// rune --> row
Map<int, int> make_row_map(List<List<String>> finger_matrix) {
  var result = {};
  finger_matrix.forEach((list) {
        for (var i = 0; i < 3; i++) {
        list[i].runes.forEach((r) => result[r] = i);
  }});
  return result;
}

checkEq(a, b) {
  if (a != b) {  
    print("$a != $b");
    assert(false);
  }
}

main() {
  assert(count(fingers_nit) == 32);
  assert(count(fingers_er) == 32);

  var on_finger = make_finger_map(fingers_nit);
  assert(on_finger['a'.runes.first] == 0);
  assert(on_finger['c'.runes.first] == 2);
  assert(on_finger['o'.runes.first] == 6);
  assert(on_finger['ä'.runes.first] == 7);

  bool finger_conflict(int a, int b) {
    return a != b && on_finger[a] == on_finger[b];  
  }
  
  var on_row = make_row_map(fingers_nit);
  assert(on_row.keys.every((key) => on_finger.containsKey(key)));
  assert(on_row['a'.runes.first] == 1);
  assert(on_row['ü'.runes.first] == 0);

  bool same_hand(int a, int b) => 
      on_finger.containsKey(a) && on_finger.containsKey(b) 
      && ((on_finger[a] < 4) == (on_finger[b] < 4));
  assert(!same_hand('c'.runes.first, 'o'.runes.first));
  assert(!same_hand('ß'.runes.first, 'u'.runes.first));
  
  bool row_conflict(int a, b) {
    return (on_row[a] == 0 && on_row[b] == 2)
        || (on_row[a] == 2 && on_row[b] == 0);  
  }

  check_letter(int a) {
    if (!on_row.containsKey(a)) {
      print("***** unknown letter: $a");
    }
  }
  
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
  assert(single_cost('p'.runes.first) == 1);
  assert(single_cost('a'.runes.first) == 0);
  assert(single_cost('u'.runes.first) == 1);
  
  int bigram_cost(int a, int b) {
    int result = 0;
    result += finger_conflict(a, b) ? 1 : 0;
    result += (same_hand(a, b) && row_conflict(a, b) ? 1 : 0);
    result += (same_hand(a, b) && on_row[a] != 1 && on_row[a] == on_row[b]) ? -1 : 0;
    return result;
  }
  assert(bigram_cost('a'.runes.first, 'q'.runes.first) == 1);
  assert(bigram_cost('a'.runes.first, 's'.runes.first) == 0);
  assert(bigram_cost('e'.runes.first, 'b'.runes.first) == 1);
  assert(bigram_cost('s'.runes.first, 'e'.runes.first) == 0);
  assert(bigram_cost('q'.runes.first, 'm'.runes.first) == 0);
  assert(bigram_cost('u'.runes.first, 'm'.runes.first) == 1);
  assert(bigram_cost('e'.runes.first, 'r'.runes.first) == -1);
      
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
  checkEq(cost("das"), 0);
  checkEq(cost("und"), 1);
  checkEq(cost("der"), 2);
  checkEq(cost("per"), 2);
  checkEq(cost("aber"), 3);
  checkEq(cost("muß"), 4);
  checkEq(cost("moment"), 6);
  
  String cost_string(String s) {
    const int padding = 10;
    var d = s.length~/2 - cost(s);
    if (d < 0) {
      return repeat(' ', padding + d) + repeat('-', -d);
    }
    return repeat(' ', padding) + repeat('+', d);
  }
  
  const word_list = "/home/robert/keyboard-layouts/leicht/tipptraining/top10000de.txt";
  var file = new File(word_list);
  Future<String> finishedReading = file.readAsLines(encoding: LATIN1);
  finishedReading.then((lines) {
    for (var i = 0, c = 0; c < 150 && i < lines.length; i++) {
      // String result = chunkify(lines[i]);
      // if (result.contains(finger_sep) || result.contains(hand_sep)) {
        c++;
      //  print(result);
      // }
        var word = lines[i].toLowerCase();
        print(padLeft(word, 13, ' ') + ' ' + cost_string(word));
    }
  });
}
