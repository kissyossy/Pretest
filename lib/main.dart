import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_analytics/observer.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:pretest/model.dart';
import 'package:vibration/vibration.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  FirebaseAnalytics analytics = FirebaseAnalytics();

  @override
  Widget build(BuildContext context) => MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => model())
    ],
      child: MaterialApp(
    theme: ThemeData(
      brightness: Brightness.light,
    ),
    darkTheme: ThemeData(
      brightness: Brightness.dark,
    ),
    home: MyHomePage(),
    navigatorObservers: [
      FirebaseAnalyticsObserver(analytics: analytics),
    ],
    debugShowCheckedModeBanner: false,
  ));
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTapDown: generateRipplePointer,
        child: Scaffold(
          // body: Stack(children: ripplePointerList),
            body: Consumer<model>(
                  builder: (context, model, _) {
                    model.getSnapshot();
                    return Stack(children: model.ripplePointerList);
                // if (snapshot.hasData) {
                //   print(snapshot.data.docs[0]);
                //   double x = snapshot.data.docs[0].get('x');
                //   double y = snapshot.data.docs[0].get('y');
                //   generateRipplePointer0(x, y);
                //   return Stack(children: ripplePointerList);
                // } else {
                //   return Container();
                // }
              },
            )));
  }

  List<RipplePointer> ripplePointerList = <RipplePointer>[];

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
    setState(() {
      ripplePointerList.add(ripplePointer);
    });
    await Future<void>.delayed(duration);
    setState(() {
      ripplePointerList.removeAt(0);
    });
  }

  Future<void> generateRipplePointer(TapDownDetails details) async {
    Map<String, dynamic> data = <String, dynamic>{};
    data['x'] = details.globalPosition.dx;
    data['y'] = details.globalPosition.dy;
    data['time'] = Timestamp.now();
    FirebaseFirestore.instance.collection('point').add(data);
    // const duration = const Duration(milliseconds: 2500);
    // Vibration.vibrate(
    //   pattern: [0, 2500],
    //   // intensities: [128, 255, 64, 255],
    // );
    // final ripplePointer = RipplePointer(
    //   key: UniqueKey(),
    //   offset: details.globalPosition,
    //   duration: duration,
    // );
    // setState(() {
    //   ripplePointerList.add(ripplePointer);
    // });
    // await Future<void>.delayed(duration);
    // setState(() {
    //   ripplePointerList.removeAt(0);
    // });
  }
}

class RipplePointer extends StatefulWidget {
  const RipplePointer({Key key, @required this.offset, @required this.duration})
      : super(key: key);
  final Offset offset;
  final Duration duration;

  @override
  _RipplePointerState createState() => _RipplePointerState();
}

class _RipplePointerState extends State<RipplePointer>
    with SingleTickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RipplePainter(controller: controller, offset: widget.offset),
    );
  }

  AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    controller.forward();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}

class RipplePainter extends CustomPainter {
  RipplePainter({@required this.controller, @required this.offset})
      : super(repaint: controller);
  final Offset offset;
  final Animation<double> controller;

  @override
  void paint(Canvas canvas, Size size) {
    final circleValue = Tween<double>(begin: 10, end: 80) //円のスタート半径と終了半径
        .animate(
      controller.drive(
        CurveTween(
          curve: Curves.easeOutExpo,
        ),
      ),
    )
        .value;
    final widthValue = Tween<double>(begin: 20, end: 1)
        .animate(
      controller.drive(
        CurveTween(
          curve: Curves.easeInOut,
        ),
      ),
    )
        .value;
    final opacityValue = Tween<double>(begin: .5, end: 0)
        .animate(
      controller.drive(
        CurveTween(
          curve: Curves.easeInOut,
        ),
      ),
    )
        .value;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..color = Colors.lightBlue.withOpacity(opacityValue)
      ..strokeWidth = widthValue;
    canvas.drawCircle(offset, circleValue, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}