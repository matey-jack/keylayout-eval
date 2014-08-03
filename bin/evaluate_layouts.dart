import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:quiver/strings.dart';
import '../lib/layout.dart';

const COL_WIDTH = 15;

print_lines(List<String> lines, int num_lines) {
  for (int i = 0; i < lines.length && i < num_lines; i++) {
    print(lines[i]);
  }
}

print_chunkified_words(lines) {
  for (var i = 0,
      c = 0; c < 150 && i < lines.length; i++) {
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
  var d = s.length ~/ 2 - layout.cost(s);
  if (d < 0) {
    return padLeft(repeat('-', -d), COST_PADDING, ' ') + repeat(' ', COST_PADDING);
  }
  return repeat(' ', COST_PADDING) + padRight(repeat('+', d), COST_PADDING, ' ');
}

// separate main function for analysis by words
main_word_cost() {
  var file = new File("../resources/top10000de.txt");
  Future<String> finishedReading = file.readAsLines(encoding: LATIN1);
  finishedReading.then((lines) {
    StringBuffer header = new StringBuffer(repeat(' ', NAME_PADDING));
    for (var l in layouts) {
      header.write(center(l.name, 2 * COST_PADDING, ' '));
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

eval_cost(String lang, List<Frequency> single, List<Frequency> bigram) {
  List<Cost> costs = layouts.map((l) {
    Cost cost = new Cost();
    cost.add_single_cost(single, l);
    cost.add_bigram_cost(bigram, l);
    return cost;
  }).toList();
  for (var i = 0; i < layouts.length; i++) {
    print(center(" ${layouts[i].name} ", 24 + 10, '='));
    print(costs[i]);
    print('');
  }
}

main() {
  main_lang("deutsch");
  main_lang("englisch");
}

main_lang(String lang) {
  print(repeat("=", 20) + lang + repeat("=", 20));
  print("");
  
  var singles = read_Ngrams(lang, 1);
  var bigrams = read_Ngrams(lang, 2);
  eval_hands(lang, singles);
  // eval_cost(lang, singles, bigrams);
  // eval_conflicts(lang, bigrams);
}

List<Frequency> read_Ngrams(String lang, int n) {
  List<String> lines = new File("../resources/$lang-t.txt.$n").readAsLinesSync(encoding: LATIN1);
  return lines.where((l) => l.isNotEmpty).map((l) => new Frequency(l)).toList();
}

eval_hands(String language, List<Frequency> freq) {
  List<double> left_hand_ratio = layouts.map((l) => calc_left_hand_ratio(l, freq)).toList();

  print("left hand ratios");
  print(layouts.map((Layout l) => padRight(l.name, COL_WIDTH, ' ')).join(''));
  print(left_hand_ratio.map((ratio) => 
      padRight("${ratio.round()}%", COL_WIDTH, ' ')
      ).join('')); 
  print("");
}

double calc_left_hand_ratio(Layout l, List<Frequency> freq) {
  int left = 0, all = 0;
  for (Frequency f in freq) {
    int finger = l.on_finger[f.letter];
    if (finger != null) {
      if (l.get_hand(finger) == "left") {
        left += f.count;
      }
      all += f.count;
    }
  }
  return left * 100 / all;
}

void eval_conflicts(String lang, List<Frequency> bigrams) {
  List<List<String>> conflictsPerLayout = layouts.map((Layout l) => bigrams.where((line) => has_conflict(l, line)).take(20)).toList();

  print(layouts.map((Layout l) => padRight(l.name, COL_WIDTH, ' ')).join(''));
  for (var i = 0; i < conflictsPerLayout[0].length; i++) {
    print(conflictsPerLayout.map((Iterable<String> conflicts) => 
        padRight(conflicts.elementAt(i).toString(), COL_WIDTH, ' ')
        ).join(''));
  }
  print("");
}

bool has_conflict(Layout l, Frequency f) {
  return (l.finger_conflict(f.letter, f.latter) || (l.same_hand(f.letter, f.latter) && l.row_conflict(f.letter, f.latter)));
}
