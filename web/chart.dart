library chart;
// https://bitbucket.org/ips/chart.dart/src/aa73b37658cf642170e933a534109509c02d4c7b/example/web/chart.dart?at=default
import 'dart:html';
//import 'dart:io';
//import 'dart:convert';
import 'package:chart/chart.dart';
import '../lib/layout.dart';


void main() {
  //show_diagram("deutsch");
  show_diagram("englisch");
}

void show_diagram(String language) {
  List<Frequency> parseFrequencies(String data) {
    return data.split("\n").map((l) => new Frequency(l)).toList();
  }
  HttpRequest.getString("../resources/$language-t.txt.2")
      .then((bigrams_string) {
          HttpRequest.getString("../resources/$language-t.txt.1")
           .then((singles_string) {
             List<Frequency> singles = parseFrequencies(singles_string);
             List<Frequency> bigrams = parseFrequencies(bigrams_string);
             Iterable<Cost> costs = layouts.map((l) {
               Cost cost = new Cost();
               cost.add_single_cost(singles, l);
               cost.add_bigram_cost(bigrams, l);
               return cost;
             });       
             
             Bar chart = new Bar({
               'labels' : layouts.map((l) => l.name).toList(),
               'datasets' : [
                 { 
                   'fillColor' : "rgba(255,0,0,1)",
                   'strokeColor' : "rgba(0,0,0,0)",
                   'data' : costs.map((c) => c.finger_conflicts).toList(),
                 },
                 {
                   'fillColor' : "rgba(0,0,255,1)",
                   'strokeColor' : "rgba(0,0,0,0)",
                   'data' : costs.map((c) => c.row_conflicts).toList(),
                 }]
             }, {
               'scaleOverride' : true, 
               'scaleMinValue' : 0.0, 
               'scaleMaxValue' : 100000.0, 
               'titleText' : 'costs'     
            });
             
             
             DivElement container = new DivElement();
             // TODO: add heading...
             container.style.height ='400px';
             container.style.width =  '100%';
             document.body.children.add(container);
             chart.show(container);
           });
      });
}