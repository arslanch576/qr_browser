
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qrbrowser/HistoryItem.dart';

import 'HistoryProvider.dart';

class EditHistoryItem extends StatefulWidget {
   
   HistoryItem historyItem;
   @override
   State<StatefulWidget> createState() => EditHistoryItemState();

   EditHistoryItem(this.historyItem);
}

class EditHistoryItemState extends State<EditHistoryItem> {
   
   GlobalKey globalKey = new GlobalKey();
   String _dataString;
   final picker = ImagePicker();
   File _image;
   final TextEditingController _textController = TextEditingController();
   HistoryProvider historyProvider;

  String _inputErrorText;


   @override
  void initState() {
      super.initState();
      _dataString=widget.historyItem.name;
      if(!widget.historyItem.filePath.startsWith("-"))
         _image=File(widget.historyItem.filePath);
  }

   Future<void> updateHistoryItem() async {
      if (historyProvider == null)
         historyProvider = await HistoryProvider().open();
         await historyProvider.update(widget.historyItem);
      
   }

  @override
   Widget build(BuildContext context) {
      return Scaffold(
         resizeToAvoidBottomInset: false,
         appBar: AppBar(
            title: Text('Edit History Item'),
            actions: <Widget>[
//               IconButton(
//                  icon: Icon(Icons.file_download),
//                  onPressed: _captureAndSharePng,
//               )
            ],
         ),
         body: _contentWidget(),
      );
   }
   
   Future<void> _captureAndSharePng() async {
      
      File file;
      bool isOk=false;
      try {
         if(_image!=null) {
            RenderRepaintBoundary boundary =
            globalKey.currentContext.findRenderObject();
            var image = await boundary.toImage();
            ByteData byteData = await image.toByteData(
                format: ImageByteFormat.png);
            Uint8List pngBytes = byteData.buffer.asUint8List();
   
            final tempDir = await getApplicationDocumentsDirectory();
            file = await new File('${tempDir.path}/${new DateTime.now()
                .millisecondsSinceEpoch}.png').create();
            await file.writeAsBytes(pngBytes);
            isOk = true;
            log("itsok"+_image.path);
         }
        
      } catch (e) {
         log("error"+e.toString());
      }
      
      widget.historyItem.name=_textController.text;
      widget.historyItem.filePath=isOk?file.path:"-";
      
      await updateHistoryItem();
      
      Fluttertoast.showToast(
         msg: 'Updated',
         toastLength: Toast.LENGTH_LONG,
         timeInSecForIosWeb: 1,
      );
      
      Navigator.pop(context);
      
   }
   
   Future getImage() async {
      //.split("com.app.qrbrowser/")[1]
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
         _image = File(pickedFile.path);
      });
      log("picked"+_image.path);
   }
   
   _contentWidget() {
      _textController.text=_dataString;
      _textController.selection = TextSelection.fromPosition(TextPosition(offset: _textController.text.length));

      //_image=widget.historyItem.filePath==null?null:File(widget.historyItem.filePath);
      final bodyHeight = MediaQuery.of(context).size.height -
          MediaQuery.of(context).viewInsets.bottom;
      return Container(
         color: const Color(0xFFFFFFFF),
         child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            
            children: <Widget>[
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: TextField(
                    controller: _textController,
                    onSubmitted: (value){
                       _dataString = _textController.text;
                       _inputErrorText = null;
                    },
   
                    style: TextStyle(color: Colors.black),
                    decoration: InputDecoration(
                       hintText: "Enter name",
                       errorText: _inputErrorText,
                       enabledBorder:  UnderlineInputBorder(borderSide: BorderSide(
                           color: Colors.black
                       ),borderRadius: BorderRadius.all(Radius.circular(3)))
                       ,
                    ),
                 ),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: RaisedButton(child: Text("Change Icon"),onPressed: getImage,color: Colors.black,),
               ),
               Padding(
                 padding: const EdgeInsets.all(8.0),
      
                 child:
                     _image==null?
                         Padding(
                            padding: EdgeInsets.all(50),
                         )
                         :
                     RepaintBoundary(
                        key: globalKey,
                       child: Image.file(
                           _image,
                          width: 100,
                          height: 100,
                       ),
                     ),
               )  ,
               Padding(
                 padding: const EdgeInsets.all(8.0),
                 child: RaisedButton(child: Text("Save", style: TextStyle(color: Colors.white),),onPressed:  _captureAndSharePng,color: Colors.black,),
               ),
            ],
         ),
      );
   }
   
}
