import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'dart:io';

import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/model/scan_result.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qrbrowser/HistoryItem.dart';
import 'package:flutter/services.dart';
import 'package:qrbrowser/HistoryPage.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AppUtils.dart';
import 'HistoryProvider.dart';
import 'generate.dart';


class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  
  HistoryProvider historyProvider;
  String barcode = "";
  AdmobBanner admobBanner;
  
  void addNewItem() {
    scan();
  }
  
  Future scan() async {
    try {
      ScanResult barcode = await BarcodeScanner.scan();
      this.barcode = barcode.rawContent;
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        Fluttertoast.showToast(
          msg: 'The user did not grant the camera permission!',
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
        );
        return;
      } else {
        Fluttertoast.showToast(
          msg: 'Unknown error: $e',
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
        );
        return;
      }
    } on FormatException {
      return;
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Unknown error: $e',
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
      );
      return;
    }
    if (await canLaunch(this.barcode)) {
      String URL = this.barcode;
      List<String> s_URL = URL.split("//");
      String s1 = s_URL[1];
      List<String> s2 = s1.split("/");
      String hostname = s2[0];
      if (historyProvider == null)
        historyProvider = await HistoryProvider().open();
      await this.historyProvider.insert(new HistoryItem(hostname, barcode));
      await launch(this.barcode);
      } else {
      Fluttertoast.showToast(
        msg: 'This is not a valid URL and cannot be opened',
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('QR Browser'),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Card(
                    color: Colors.black,
                    child: InkWell(
                      onTap: addNewItem,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'images/qr.png',
                              width: 60,
                              height: 60,
                              color: Colors.white,
                            ),
                            Text("     Scan  QR", style: TextStyle(fontSize: 20),)
                          ],
                        ),
                      ),
                    ),
                  ),
  
                  Card(
                    color: Colors.black,
                    child: InkWell(
                      onTap: (){Navigator.push(
                          context, MaterialPageRoute(builder: (c) => GenerateScreen()));},
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'images/gen_qr.png',
                              width: 60,
                              height: 60,
                              color: Colors.white,
                            ),
                            Text("    Create QR", style: TextStyle(fontSize: 20),)
                          ],
                        ),
                      ),
                    ),
                  ),
  
                  Card(
                    color: Colors.black,
                    child: InkWell(
                      onTap: (){
                        Navigator.push(
                            context, MaterialPageRoute(builder: (c) => HistoryPage()));
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Image.asset(
                              'images/history.png',
                              width: 60,
                              height: 60,
                              color: Colors.white,
                            ),
                            Text("    QR History", style: TextStyle(fontSize: 20),)
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        show ?
            AdmobBanner(
              adUnitId: AppUtils.getBannerAdUnitId(),
              adSize: AdmobBannerSize.BANNER,
              listener:
                  (AdmobAdEvent event, Map<String, dynamic> args) {
                AppUtils.handleEvent(event, args, 'Banner');
              },
            ):Container(height: 0,),
          ],
        ),
      ),//
    );
  }

  bool show = true;
  @override
  void initState() {
    super.initState();
    show = true;
    print('************************ initState ************************');
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void deactivate() {
    super.deactivate();
    //this method not called when user press android back button or quit
    print('************************ deactivate ************************');
  }

  @override
  void dispose() {
    super.dispose();
  
    WidgetsBinding.instance.removeObserver(this);
  
    //this method not called when user press android back button or quit
    print('************************ dispose ************************');
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    //print inactive and paused when quit
  
    print(" ************************ ");
    print(state);
    if (state == AppLifecycleState.inactive) {
      setState(() {
        show = false;
        print("setstate : show = " + show.toString());
      });
    }
    else if (state == AppLifecycleState.resumed)
    {
      setState(() {show = true;});
    }
    print(" ************************ ");
    // maestro.gSm.gsmAds.controller.dispose();
    // Clinvoke.disposeAdmob_flutter();
  
    // exit(0);
  
  }
}
