library chart;
// https://bitbucket.org/ips/chart.dart/src/aa73b37658cf642170e933a534109509c02d4c7b/example/web/chart.dart?at=default
import 'dart:html';
//import 'dart:io';
//import 'dart:convert';
import 'package:chart/chart.dart';
import '../lib/layout.dart';


void main() {
  const String language = "deutsch";
  HttpRequest.getString("../resources/$language-t.txt.2")
      .then((bigrams_string) {
          HttpRequest.getString("../resources/$language-t.txt.1")
           .then((singles_string) {
             var single_freq = singles_string.split("\n");
             var bigram_freq = bigrams_string.split("\n");
             Iterable<Cost> costs = layouts.map((l) {
               Cost cost = new Cost();
               cost.add_single_cost(single_freq, l);
               cost.add_bigram_cost(bigram_freq, l);
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
             container.style.height ='400px';
             container.style.width =  '100%';
             document.body.children.add(container);
             chart.show(container);
           });
      });
 
}