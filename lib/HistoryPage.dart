import 'dart:io';

import 'package:admob_flutter/admob_flutter.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:barcode_scan/model/scan_result.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qrbrowser/AppUtils.dart';
import 'package:qrbrowser/EditHistoryItem.dart';
import 'package:qrbrowser/HistoryItem.dart';
import 'package:qrbrowser/scan.dart';
import 'package:qrbrowser/selectableItem.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import 'HistoryProvider.dart';
import 'SelectionAppbar.dart';
import 'generate.dart';

class HistoryPage extends StatefulWidget {
  HistoryPage({Key key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final controller = DragSelectGridViewController();
  List<HistoryItem> historyItems = new List();
  String mode = "grid";
  HistoryProvider historyProvider;
  String barcode = "";

  bool isListMode() {
    return !mode.startsWith("grid");
  }

  Future<void> getHistoryItemsFromDatabase() async {
    if (historyProvider == null)
      historyProvider = await HistoryProvider().open();
    List<HistoryItem> items = await historyProvider.getAllHistoryItems();
    if (items.length == 0)
      for (HistoryItem hi in getDefaultHistoryItems())
        await historyProvider.insert(hi);
    items = await historyProvider.getAllHistoryItems();
    int i = 0;
    for (HistoryItem hi in items) {
      if (hi.name.startsWith("Add")) break;
      i++;
    }
    HistoryItem hi = items[i];
    items.removeAt(i);
    items.add(hi);
    historyItems.clear();

    setState(() {
      historyItems.addAll(items);
    });
  }

  deleteHistoryItem(HistoryItem historyItem) async {
    await (await HistoryProvider().open()).delete(historyItem);
  }

  saveModePref(String mode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString('mode', mode);
  }

  Future<String> getMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('mode') == null ? "grid" : prefs.getString('mode');
  }

  List<HistoryItem> getDefaultHistoryItems() {
    List<HistoryItem> historyItems = new List();
    historyItems.add(HistoryItem("Add", "Add new item"));
    historyItems.add(HistoryItem("Google", "http://www.google.com"));
    historyItems.add(HistoryItem("Youtube", "http://www.youtube.com"));
    historyItems.add(HistoryItem("Gmail", "http://www.gmail.com"));
    historyItems.add(HistoryItem("Facebook", "http://www.facebook.com"));
    historyItems.add(HistoryItem("Twitter", "http://www.twitter.com"));
    historyItems.add(HistoryItem("Instagram", "http://www.instagram.com"));
    historyItems.add(HistoryItem("Snapchat", "http://www.snapchat.com"));
    historyItems.add(HistoryItem("Yahoo", "http://www.yahoo.com"));
    historyItems.add(HistoryItem("Bing", "http://www.bing.com"));
    return historyItems;
  }

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
    String URL = this.barcode;
    List<String> s_URL = URL.split("//");
    String s1 = s_URL[1];
    List<String> s2 = s1.split("/");
    String hostname = s2[0].replaceAll("www.", "replace");
    await this.historyProvider.insert(new HistoryItem(hostname, barcode));
    //await launch(this.barcode);
    getHistoryItemsFromDatabase();
    Fluttertoast.showToast(
      msg: 'Added',
      toastLength: Toast.LENGTH_LONG,
      timeInSecForIosWeb: 1,
    );
  }

  @override
  void initState() {
    super.initState();
    controller.addListener(scheduleRebuild);
    getHistoryItemsFromDatabase();
    getMode().then((v) {
      setState(() {
        mode = v;
      });
    });
  }

  @override
  void dispose() {
    controller.removeListener(scheduleRebuild);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
//    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//      keywords: <String>['flutterio', 'beautiful apps'],
//      testDevices: <String>["4A217A63745788610CA1AF332A1A18E2"], // Android emulators are considered test devices
//    );
    return Scaffold(
      appBar: SelectionAppBar(
        selection: controller.selection,
        title: const Text('QR Browser'),
        mode: mode,
        onEditCalled: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (c) => EditHistoryItem(historyItems[
                      controller.selection.selectedIndexes.first]))).then((v) {
            getHistoryItemsFromDatabase();
            controller.clear();
          });
        },
        onCreateQrSelected: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (c) => GenerateScreen()));
        },
        onDeleteCalled: () async {
          int i = 0;
          for (HistoryItem historyItem in historyItems) {
            if (controller.selection.selectedIndexes.contains(i) &&
                i != historyItems.length - 1)
              await deleteHistoryItem(historyItem);
            i++;
          }
          controller.clear();
          await getHistoryItemsFromDatabase();
        },
        onGridSelectionChanged: () {
          setState(() {
            if (mode.startsWith("grid"))
              mode = "list";
            else
              mode = "grid";
          });
          saveModePref(mode);
        },
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          children: <Widget>[
            Expanded(
              child: DragSelectGridView(
                gridController: controller,
                padding: const EdgeInsets.all(8),
                itemCount: historyItems.length,
                itemBuilder: (context, index, selected) {
                  return SelectableItem(
                    index: index,
                    color: Colors.grey,
                    selected: selected,
                    controller: controller,
                    isListMode: isListMode(),
                    addCalled: addNewItem,
                    historyItem: historyItems[index],
                  );
                },
                gridDelegate: isListMode()
                    ? SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 1,
                        childAspectRatio: 3.9,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      )
                    : SliverGridDelegateWithMaxCrossAxisExtent(
                        maxCrossAxisExtent: 150,
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
              ),
            ),
            !AppUtils.isError?
            AdmobBanner(
              adUnitId: AppUtils.getBannerAdUnitId(),
              adSize: AdmobBannerSize.BANNER,
              listener: (AdmobAdEvent event, Map<String, dynamic> args) {
                AppUtils.handleEvent(event, args, 'Banner');
              },
            ):
            Container(
              height: 0,
            ),
          ],
        ),
      ),
//      floatingActionButton: FloatingActionButton.extended(
//        onPressed: addNewItem,
//        backgroundColor: Colors.black,
//        label: Text(
//          "Scan QR",
//          style: TextStyle(color: Colors.white),
//        ),
//        icon: new Image.asset(
//          'images/qr.png',
//          width: 30,
//          height: 30,
//          color: Colors.white,
//        ),
//      ),
    );
  }

  void scheduleRebuild() => setState(() {});
}
