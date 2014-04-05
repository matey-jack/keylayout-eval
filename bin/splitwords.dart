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

main() {
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
        print(padLeft(word, 13, ' ') + ' ' + layout_qwertz.cost_string(word));
    }
  });
}
