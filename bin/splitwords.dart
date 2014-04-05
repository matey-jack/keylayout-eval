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

String cost_string(Layout layout, String s) {
  const int padding = 10;
  var d = s.length~/2 - layout.cost(s);
  if (d < 0) {
    return repeat(' ', padding + d) + repeat('-', -d);
  }
  return repeat(' ', padding) + repeat('+', d);
}

main() {
  const word_list = "/home/robert/keyboard-layouts/leicht/tipptraining/top10000de.txt";
  var file = new File(word_list);
  Future<String> finishedReading = file.readAsLines(encoding: LATIN1);
  finishedReading.then((lines) {
    
    for (var i = 0; i < 150 && i < lines.length; i++) {
      var word = lines[i].toLowerCase();
      print(padLeft(word, 13, ' ') + ' ' + cost_string(layout_qwertz, word));
    }
  });
}
