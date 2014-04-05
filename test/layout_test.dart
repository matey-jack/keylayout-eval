import 'package:unittest/unittest.dart';
import '../lib/layout.dart';

void main() {
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
  var on_finger = make_finger_map(fingers_nit);
  var on_row = make_row_map(fingers_nit);

  test("row and finger mappings cover same letters", () {
    assert(on_row.keys.every((key) => on_finger.containsKey(key)));
    assert(on_finger.keys.every((key) => on_row.containsKey(key)));
  });
  
  test("correct finger mapping", () {
    expect(on_finger['a'.runes.first], equals(0));
    expect(on_finger['c'.runes.first], equals(2));
    expect(on_finger['o'.runes.first], equals(6));
    expect(on_finger['ä'.runes.first], equals(7));
  });

  test("correct row mapping", () {
    expect(on_row['a'.runes.first], equals(1));
    expect(on_row['ü'.runes.first], equals(0));
  });      
  
  var layout = new Layout("leicht-nit", fingers_nit);
  test("same hand", () {
    expect(layout.same_hand('c'.runes.first, 'o'.runes.first), equals(false));
    expect(layout.same_hand('ß'.runes.first, 'u'.runes.first), equals(false));
    
  });
  
  test("single cost", () {
    expect(layout.single_cost('p'.runes.first), equals(1));
    expect(layout.single_cost('a'.runes.first), equals(0));
    expect(layout.single_cost('u'.runes.first), equals(1));
  });
  
  test("bigram cost", () {
    expect(layout.bigram_cost('a'.runes.first, 'q'.runes.first), equals(1));
    expect(layout.bigram_cost('a'.runes.first, 's'.runes.first), equals(0));
    expect(layout.bigram_cost('e'.runes.first, 'b'.runes.first), equals(1));
    expect(layout.bigram_cost('s'.runes.first, 'e'.runes.first), equals(0));
    expect(layout.bigram_cost('q'.runes.first, 'm'.runes.first), equals(0));
    expect(layout.bigram_cost('u'.runes.first, 'm'.runes.first), equals(1));
    expect(layout.bigram_cost('e'.runes.first, 'r'.runes.first), equals(-1));
  });
    
  test("cost", () {
    expect(layout.cost("das"), 0);
    expect(layout.cost("und"), 1);
    expect(layout.cost("der"), 2);
    expect(layout.cost("per"), 2);
    expect(layout.cost("aber"), 3);
    expect(layout.cost("muß"), 4);
    expect(layout.cost("moment"), 6);
  });
}