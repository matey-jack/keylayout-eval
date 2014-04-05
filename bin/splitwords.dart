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

print_chunkified_words(lines) {
  for (var i = 0, c = 0; c < 150 && i < lines.length; i++) {
    String result = layout_nit.chunkify(lines[i]);
    if (result.contains(Layout.finger_sep) || result.contains(Layout.hand_sep)) {
      c++;
      print(result);
    }
  }
}

const int NAME_PADDING = 13;
const int COST_PADDING = 10;
String cost_string(Layout layout, String s) {
  var d = s.length~/2 - layout.cost(s);
  if (d < 0) {
    return repeat(' ', COST_PADDING + d) + repeat('-', -d);
  }
  return repeat(' ', COST_PADDING) + repeat('+', d);
}

main() {
  const word_list = "/home/robert/keyboard-layouts/leicht/tipptraining/top10000de.txt";
  var file = new File(word_list);
  Future<String> finishedReading = file.readAsLines(encoding: LATIN1);
  finishedReading.then((lines) {
    var layouts = [layout_qwertz, layout_neo2, layout_nit, layout_leicht];
    StringBuffer header = new StringBuffer(repeat(' ', NAME_PADDING));
    for (var l in layouts) {
      header.write(padRight(l.name, 2*NAME_PADDING, ' '));  
    }
    print(header.toString());
    for (var i = 0; i < 150 && i < lines.length; i++) {
      String word = lines[i].toLowerCase();
      StringBuffer line = new StringBuffer(padLeft(word, NAME_PADDING, ' '));
      for (var l in layouts) {
        line.write(cost_string(layout_qwertz, word));  
      }
      print(line.toString());
    }
  });
}
