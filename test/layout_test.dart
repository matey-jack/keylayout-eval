import 'package:unittest/unittest.dart';
import '../lib/layout.dart';

void main() {
  var on_finger = layout_nit.on_finger;
  var on_row = layout_nit.on_row;

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
  
  ////////////////////////// costly logic /////////////////////////////
  test("same hand", () {
    expect(layout_nit.same_hand('c'.runes.single, 'o'.runes.single), equals(false));
    expect(layout_nit.same_hand('ß'.runes.single, 'u'.runes.single), equals(false));
    
  });
  
  test("single cost", () {
    expect(layout_nit.single_cost('p'.runes.single), 1);
    expect(layout_nit.single_cost('a'.runes.single), 0);
    expect(layout_nit.single_cost('g'.runes.single), 1);
    expect(layout_nit.single_cost('h'.runes.single), 1);
    expect(layout_nit.single_cost('n'.runes.single), 0);
    expect(layout_nit.single_cost('u'.runes.single), 1);
  });
  
  test("bigram cost", () {
    expect(layout_nit.bigram_cost('a'.runes.single, 'q'.runes.single), equals(1));
    expect(layout_nit.bigram_cost('a'.runes.single, 's'.runes.single), equals(0));
    expect(layout_nit.bigram_cost('e'.runes.single, 'b'.runes.single), equals(1));
    expect(layout_nit.bigram_cost('s'.runes.single, 'e'.runes.single), equals(0));
    expect(layout_nit.bigram_cost('q'.runes.single, 'm'.runes.single), equals(0));
    expect(layout_nit.bigram_cost('u'.runes.single, 'm'.runes.single), equals(1));
    expect(layout_nit.bigram_cost('e'.runes.single, 'r'.runes.single), equals(-1));
  });
    
  test("cost", () {
    expect(layout_nit.cost("das"), 0);
    expect(layout_nit.cost("und"), 1);
    expect(layout_nit.cost("der"), 2);
    expect(layout_nit.cost("per"), 2);
    expect(layout_nit.cost("aber"), 3);
    expect(layout_nit.cost("muß"), 4);
    expect(layout_nit.cost("moment"), 6);
  });
}