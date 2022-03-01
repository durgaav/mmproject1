import 'package:flutter/material.dart';

class Data extends ChangeNotifier {
  int _counter = 0;

  void setCount(int count) {
    _counter = count;
    notifyListeners();
  }

  int getcounter() => _counter;

  void incrementCounter() {
    _counter++;
    notifyListeners();
  }

  void reset(){
    _counter = 0;
  }
}