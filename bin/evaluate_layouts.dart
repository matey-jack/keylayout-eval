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
    return padLeft(repeat('-', -d), COST_PADDING, ' ') + repeat(' ', COST_PADDING);
  }
  return repeat(' ', COST_PADDING) + padRight(repeat('+', d), COST_PADDING, ' ');
}

main_word_cost() {
  var file = new File("../resources/top10000de.txt");
  Future<String> finishedReading = file.readAsLines(encoding: LATIN1);
  finishedReading.then((lines) {
    StringBuffer header = new StringBuffer(repeat(' ', NAME_PADDING));
    for (var l in layouts) {
      header.write(center(l.name, 2*COST_PADDING, ' '));  
    }
    print(header.toString());
    for (var i = 0; i < 150 && i < lines.length; i++) {
      String word = lines[i].toLowerCase();
      StringBuffer line = new StringBuffer(padLeft(word, NAME_PADDING, ' '));
      for (var l in layouts) {
        line.write(cost_string(l, word));  
      }
      print(line.toString());
    }
  });
}

main_eval() {
  const String language = "deutsch";
  var bigram_freq = new File("../resources/$language-t.txt.2").readAsLinesSync(encoding: LATIN1);
  var single_freq = new File("../resources/$language-t.txt.1").readAsLinesSync(encoding: LATIN1);
  List<Cost> costs = layouts.map((l) {
    Cost cost = new Cost();
    cost.add_single_cost(single_freq, l);
    cost.add_bigram_cost(bigram_freq, l);
    return cost;
  }).toList();
  for (var i = 0; i < layouts.length; i++) {
    print(center(" ${layouts[i].name} ",  24+10, '='));
    print(costs[i]);
    print('');
  }
}

main() {
  const String language = "deutsch";
  var bigram_freq = new File("../resources/$language-t.txt.2").readAsLinesSync(encoding: LATIN1);
  List<List<String>> conflictsPerLayout = layouts.map((Layout l) =>
      bigram_freq.where((line) => has_conflict(l, line)).take(20)
  ).toList();
  const COL_WIDTH = 15; 
  print(layouts.map((Layout l) => padRight(l.name, COL_WIDTH, ' ')).join(''));
  for (var i = 0; i < conflictsPerLayout[0].length; i++) {
    print(conflictsPerLayout.map((Iterable<String> conflicts) => 
        padRight(conflicts.elementAt(i), COL_WIDTH, ' ')).join(''));
  }
}

bool has_conflict(Layout l, String line) {
  var fields = line.split(' '); 
  String letters = fields[1].toLowerCase();
  int a = letters.runes.first;
  int b = letters.runes.last;
  return (l.finger_conflict(a, b) || (l.same_hand(a, b) && l.row_conflict(a, b)));
}

