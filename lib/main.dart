import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:qrbrowser/AppUtils.dart';
import 'package:qrbrowser/HistoryPage.dart';
import 'package:qrbrowser/generate.dart';
import 'package:qrbrowser/scan.dart';

import 'HomePage.dart';

void main() {
   runApp(QRBrowserApp());
   Admob.initialize(AppUtils.getAppId());
}

class QRBrowserApp extends StatelessWidget {
   @override
   Widget build(BuildContext context) {
//      MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//         keywords: <String>['flutterio', 'beautiful apps'],
//         testDevices: <String>["4A217A63745788610CA1AF332A1A18E2"], // Android emulators are considered test devices
//      );
      return MaterialApp(
         title: 'QR Browser',
         theme: ThemeData(
             primarySwatch: Colors.grey,
             accentColor: Colors.black,
             brightness: Brightness.dark,
             hintColor: Colors.grey,
             textTheme: TextTheme(caption: TextStyle(color: Colors.black)),
             appBarTheme: AppBarTheme(color: Colors.black,
                 textTheme: TextTheme(
                     title: TextStyle(color: Colors.white, fontSize: 20)),
                 iconTheme: IconThemeData(color: Colors.white))
         ),
         home: HomePage(),
      );
   }
}





