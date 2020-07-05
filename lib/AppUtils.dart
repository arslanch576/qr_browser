import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AppUtils {
   
   static bool alreadyShown=false;
   static bool isError=false;
   
   static String getAppId() {
      if (Platform.isIOS) {
         return 'ca-app-pub-5623413520624304~1199991984';
      } else if (Platform.isAndroid) {
         return 'ca-app-pub-5623413520624304~4997682480';
      }
      return null;
   }

   static String getBannerAdUnitId() {
      if (Platform.isIOS) {
         return 'ca-app-pub-5623413520624304/5567687800';
      } else if (Platform.isAndroid) {
         return 'ca-app-pub-5623413520624304/7890598815';
      }
      return null;
   }
   
   static void handleEvent(
       AdmobAdEvent event, Map<String, dynamic> args, String adType) {
      switch (event) {
         case AdmobAdEvent.loaded:
            isError=false;
            //showToast('New Admob $adType Ad loaded!');
            break;
         case AdmobAdEvent.opened:
            //showToast('Admob $adType Ad opened!');
            break;
         case AdmobAdEvent.closed:
            //showToast('Admob $adType Ad closed!');
            break;
         case AdmobAdEvent.failedToLoad:
            if(!alreadyShown) {
               showToast('Admob $adType failed to load. ${args['errorCode']}');
               isError=true;
               alreadyShown=true;
            }
            break;
            break;
         default:
      }
   }
   
   static void showToast(String msg){
      Fluttertoast.showToast(
         msg: msg,
         toastLength: Toast.LENGTH_LONG,
         timeInSecForIosWeb: 1,
      );
   }
}