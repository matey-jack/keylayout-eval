keylayout-eval
==============

A simple evaluator for computer keyboard layouts. Measures typing effort for most frequent words and most frequent n-grams.

This metric is much simpler than what currently fashionable tools like Oxelyzer measure, and it is mostly geared towards 
[casual keyboard layouts](https://docs.google.com/document/d/1qcFVYG0w7PxDxiYedztqaLKmeJxAAcuZtsRCUZLkuGk/edit?usp=sharing), 
meaning those that change only a few keys compared to the QWERTY layout.

In particular, we measure:
 - how easy a key is to hit (only the 8 or 9 actual finger resting keys get a bonus, others are treated the same). The program supports 9 base key positions to account for the advantage that is giving.
 - how easy bigrams are to type: 
   - no bonus for two-handed bigrams (as Dvorak recommended them under the term "hand alternation"), but 
   - big malus for single-finger bigrams which are the most annoying and flow-breaking part in any key layout, and 
   - malus for single-hand bigrams where keys are more than one row apart. This reflects that usually your center of hand moves a little towards the row that you are hitting, so that you can't aim for both upper and lower row in quick succession. Note that this indirectly recreates a numeric advantage for hand alternation without having to measure the latter explicitly... simpler logic and more true to reality
   - small bonus for bigrams on the same hand same row -- this includes what other layouts call "rolls", but is more generic.

Purpose of this tool is not to give a definite answer on which layout is better, but just to:
 - create a short list of layouts by excluding variants that are worse on all the collected metrics
 - find possible improvements in a layout
 - give some very rough estimate for layouts that try to change as little keys (compared to qwerty) as possible, where they fall between "as bad as qwerty" and "as good as the best layout which changes all key assignments without reservations" 

This is made with Dart before version 1 and now there is even Dart 2 with a much changed ecosystem on how to build Dart apps and run them in the Browser.

The charts don't work with the current version of the Dart stack, but the unit tests still pass, 
so all the calculation-code is working, 
and thus it should be easy to get the command-line part in the bin/ directory working again!


