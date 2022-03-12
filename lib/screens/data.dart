import 'package:flutter/material.dart';

class Data extends ChangeNotifier {
  int _counter = 0;
  List assignedList = [];

  void setCount(int count) {
    _counter = count;
    notifyListeners();
  }

  int getcounter() => _counter;

  void addList(List addedList){
    for(int i=0;i<addedList.length;i++){
      assignedList.add(addedList[i]);
    }
    notifyListeners();
  }

  List getList() => assignedList;

}