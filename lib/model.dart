import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';

import 'main.dart';

class model extends ChangeNotifier {
  List<RipplePointer> ripplePointerList = <RipplePointer>[];
  bool isEnd = false;
  void getSnapshot() async {
    if(!isEnd) {
      FirebaseFirestore.instance
          .collection('point')
          .orderBy('time', descending: true)
          .limit(1)
          .snapshots()
          .listen((data) async {
        double x = data.docs[0].get('x');
        double y = data.docs[0].get('y');
        print(x);
        generateRipplePointer0(x, y);
      });
      isEnd = true;
    }
  }
  Future<void> generateRipplePointer0(double x, double y) async {
    const duration = const Duration(milliseconds: 2500);
    // Vibration.vibrate(
    //   pattern: [1500, 1000],
    //   intensities: [60,10],
    // );
    try {
      if (Platform.isIOS) {
        Vibration.vibrate(
          pattern: [0, 500, 0, 500, 0, 500, 0, 500, 0, 500],
          intensities: [100, 80, 60, 40, 20],
        );
      } else if (Platform.isAndroid) {
        Vibration.vibrate(
          pattern: [500, 500, 500, 500, 500],
          intensities: [100, 80, 60, 40, 20],
        );
      }
    }
    catch(e){
      //This is Web.
      Vibration.vibrate(
        pattern: [500, 500, 500, 500, 500],
        intensities: [100, 80, 60, 40, 20],
      );
    }
    final ripplePointer = RipplePointer(
      key: UniqueKey(),
      offset: Offset(x, y),
      duration: duration,
    );
      ripplePointerList.add(ripplePointer);
      notifyListeners();
    await Future<void>.delayed(duration);
      ripplePointerList.removeAt(0);
      notifyListeners();
  }
}


