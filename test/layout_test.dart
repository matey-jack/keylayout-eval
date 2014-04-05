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
  // var on_finger = make_finger_map(fingers_nit);
  // var on_row = make_row_map(fingers_nit);
  var on_finger = make_on_finger(layout_nit);
  var on_row = make_on_row(layout_nit);

  test("row and finger mappings cover same letters", () {
    assert(on_row.keys.every((key) => on_finger.containsKey(key)));
    assert(on_finger.keys.every((key) => on_row.containsKey(key)));
  });
  
  test("correct finger mapping", () {
    expect(on_finger['a'.runes.single], equals(0), reason: 'a');
    expect(on_finger['c'.runes.single], equals(2), reason: 'c');
    expect(on_finger['o'.runes.single], equals(6), reason: 'o');
    expect(on_finger['ä'.runes.single], equals(7), reason: 'ä');
  });

  test("correct row mapping", () {
    expect(on_row['a'.runes.single], equals(1));
    expect(on_row['ü'.runes.single], equals(0));
  });      
  
  ////////////////////////// new layout format /////////////////////////////  
  test("layout definition qwertz", () {
    check_layout(layout_qwertz);
  });
  
  test("layout definition neo2", () {
    check_layout(layout_neo2);
  });
  
  test("layout definition leicht-nit", () {
    check_layout(layout_nit);
  });
  
  test("layout definition leicht-er", () {
    check_layout(layout_leicht);
  });
  
  
  ////////////////////////// costly logic /////////////////////////////
  var layout = new Layout("leicht-nit", fingers_nit);
  test("same hand", () {
    expect(layout.same_hand('c'.runes.single, 'o'.runes.single), equals(false));
    expect(layout.same_hand('ß'.runes.single, 'u'.runes.single), equals(false));
    
  });
  
  test("single cost", () {
    expect(layout.single_cost('p'.runes.single), equals(1));
    expect(layout.single_cost('a'.runes.single), equals(0));
    expect(layout.single_cost('u'.runes.single), equals(1));
  });
  
  test("bigram cost", () {
    expect(layout.bigram_cost('a'.runes.single, 'q'.runes.single), equals(1));
    expect(layout.bigram_cost('a'.runes.single, 's'.runes.single), equals(0));
    expect(layout.bigram_cost('e'.runes.single, 'b'.runes.single), equals(1));
    expect(layout.bigram_cost('s'.runes.single, 'e'.runes.single), equals(0));
    expect(layout.bigram_cost('q'.runes.single, 'm'.runes.single), equals(0));
    expect(layout.bigram_cost('u'.runes.single, 'm'.runes.single), equals(1));
    expect(layout.bigram_cost('e'.runes.single, 'r'.runes.single), equals(-1));
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