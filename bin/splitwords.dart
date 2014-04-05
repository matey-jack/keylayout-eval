import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:quiver/strings.dart';
import '../lib/layout.dart';

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

sum(Iterable<int> list) {
  return list.fold(0, (prev, element) => prev + element);
}

count(List<List<String>> matrix) {
  return sum(matrix.map((list) => 
      sum(list.map((str) => str.length))
      ));
}


main() {
  assert(count(fingers_nit) == 32);
  assert(count(fingers_er) == 32);
  var layout = new Layout("leicht-nit", fingers_nit);
  
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
        print(padLeft(word, 13, ' ') + ' ' + layout.cost_string(word));
    }
  });
}
