import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

import 'AppUtils.dart';

class GenerateScreen extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => GenerateScreenState();
}

class GenerateScreenState extends State<GenerateScreen> {
  static const double _topSectionTopPadding = 20.0;
  static const double _topSectionBottomPadding = 20.0;
  static const double _topSectionHeight = 50.0;

  GlobalKey globalKey = new GlobalKey();
  String _dataString = "";
  String _inputErrorText;
  final picker = ImagePicker();
  File _image;
  ImageProvider imageProvider;
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
//    MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
//      keywords: <String>['flutterio', 'beautiful apps'],
//      testDevices: <String>["4A217A63745788610CA1AF332A1A18E2"], // Android emulators are considered test devices
//    );
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text('Generate QR Code'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: _captureAndSharePng,
          )
        ],
      ),
      body: _contentWidget(),
    );
  }

  Future<void> _captureAndSharePng() async {
    if(_textController.text.isEmpty)
      {
        Fluttertoast.showToast(
          msg: 'Please enter QR code and hit generate button',
          toastLength: Toast.LENGTH_LONG,
          timeInSecForIosWeb: 1,
        );
        return;
      }
    try {
      RenderRepaintBoundary boundary =
          globalKey.currentContext.findRenderObject();
      var image = await boundary.toImage();
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await new File('${tempDir.path}/${new DateTime.now().millisecondsSinceEpoch}.png').create();
      await file.writeAsBytes(pngBytes);

      await GallerySaver.saveImage(file.path, albumName: "QR Browser");

      Fluttertoast.showToast(
        msg: 'QR code saved to gallery',
        toastLength: Toast.LENGTH_LONG,
        timeInSecForIosWeb: 1,
      );

//      final channel = const MethodChannel('channel:me.alfian.share/share');
//      channel.invokeMethod('shareFile', 'image.png');
    } catch (e) {
      print(e.toString());
    }
  }

  Future getImage() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);
  
    setState(() {
      _image = File(pickedFile.path);
    });
  }

  _contentWidget() {
    _textController.text = _dataString;
    final bodyHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewInsets.bottom;
    return Container(
      color: const Color(0xFFFFFFFF),
      child: Column(
        children: <Widget>[
          AdmobBanner(
            adUnitId: AppUtils.getBannerAdUnitId(),
            adSize: AdmobBannerSize.BANNER,
            listener:
                (AdmobAdEvent event, Map<String, dynamic> args) {
              AppUtils.handleEvent(event, args, 'Banner');
            },
          ),
          Expanded(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(
                    top: _topSectionTopPadding,
                    left: 20.0,
                    right: 10.0,
                    bottom: _topSectionBottomPadding,
                  ),
                  child: Container(
                    height: _topSectionHeight,
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: _textController,
                            onSubmitted: (value){
                              _dataString = _textController.text;
                              _inputErrorText = null;
                            },
                            style: TextStyle(color: Colors.black),
                            
                            decoration: InputDecoration(
                              hintText: "Enter text/URL",
                              errorText: _inputErrorText,
                              enabledBorder:  UnderlineInputBorder(borderSide: BorderSide(
                                  color: Colors.black
                              ),borderRadius: BorderRadius.all(Radius.circular(3)))
                                ,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: RaisedButton(
                            child: Text("SUBMIT", style: TextStyle(color: Colors.white),),
                            onPressed: () {
                              setState(() {
                                _dataString = _textController.text;
                                _inputErrorText = null;
                              });
                            },color: Colors.black,
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                RaisedButton(child: Text("Select Center Icon", style: TextStyle(color: Colors.white),),onPressed: getImage,color: Colors.black,),
                Expanded(
                  child: Center(
                    child: RepaintBoundary(
                      key: globalKey,
                      child: QrImage(
                        data: _dataString,
                        size: 0.5 * bodyHeight,
                        gapless: false,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        embeddedImage: _image==null?null:FileImage(_image),
                        embeddedImageStyle: QrEmbeddedImageStyle(
                          size: Size(50, 50),
                        ),
//                  onError: (ex) {
//                    print("[QR] ERROR - $ex");
//                    setState((){
//                      _inputErrorText = "Error! Maybe your input value is too long?";
//                    });
//                  },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
