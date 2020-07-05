import 'dart:io';

import 'package:drag_select_grid_view/drag_select_grid_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:qrbrowser/HistoryItem.dart';
import 'package:url_launcher/url_launcher.dart';

class SelectableItem extends StatefulWidget {
   const SelectableItem({
      Key key,
      @required this.index,
      @required this.color,
      @required this.selected,
      @required this.controller,
      @required this.addCalled,
      @required this.historyItem,
      @required this.isListMode,
   }) : super(key: key);
   
   final int index;
   final MaterialColor color;
   final DragSelectGridViewController controller;
   final bool selected;
   final Function addCalled;
   final HistoryItem historyItem;
   final bool isListMode;
   
   @override
   _SelectableItemState createState() => _SelectableItemState();
}

class _SelectableItemState extends State<SelectableItem>
    with SingleTickerProviderStateMixin {
   AnimationController _controller;
   Animation<double> _scaleAnimation;
   
   @override
   void initState() {
      super.initState();
      
      _controller = AnimationController(
         value: widget.selected ? 1 : 0,
         duration: kThemeChangeDuration,
         vsync: this,
      );
      
      _scaleAnimation = Tween<double>(begin: 1, end: 0.8).animate(
         CurvedAnimation(
            parent: _controller,
            curve: Curves.ease,
         ),
      );
   }
   
   @override
   void didUpdateWidget(SelectableItem oldWidget) {
      super.didUpdateWidget(oldWidget);
      if (oldWidget.selected != widget.selected) {
         if (widget.selected) {
            _controller.forward();
         } else {
            _controller.reverse();
         }
      }
   }
   
   @override
   void dispose() {
      _controller.dispose();
      super.dispose();
   }
   
   @override
   Widget build(BuildContext context) {
      return AnimatedBuilder(
         animation: _scaleAnimation,
         builder: (context, child) {
            return Container(
               child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: DecoratedBox(
                     child: child,
                     decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: calculateColor(),
                     ),
                  ),
               ),
            );
         },
         child: Material(
            color: Colors.transparent,
            child: InkWell(
               onTap: !widget.controller.selection.isSelecting
                   ? () async {
                  if (widget.historyItem.name.startsWith("Add")) {
                     widget.addCalled();
                     return;
                  }
                  if (await canLaunch(widget.historyItem.url)) {
                     await launch(widget.historyItem.url);
                  } else {
                     Fluttertoast.showToast(
                        msg: 'This is not a valid URL and cannot be opened',
                        toastLength: Toast.LENGTH_LONG,
                        timeInSecForIosWeb: 1,
                     );
                  }
               }
                   : null,
               child: widget.isListMode
                   ? Container(
                  alignment: Alignment.center,
                  child: Row(
                      children: <Widget>[
                      Container(
                      height: 80,
                      width: 80,
                      margin: const EdgeInsets.only(top: 10),
                      child: widget.historyItem.filePath!=null&&!widget
                          .historyItem.filePath.startsWith("-") ?
                  Image.file(
                     File(widget.historyItem.filePath), fit: BoxFit.cover,
                     height: 80,
                     width: 80,)
                      :
                  Card(
                     color: Colors.grey.shade300,
                     elevation: 0,
                     shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                     ),
                     child: Center(
                        child: Text(
                           widget.historyItem.name.startsWith("Add")
                               ? "+"
                               : widget.historyItem.name[0].toUpperCase(),
                           style: TextStyle(
                               color: Colors.white, fontSize: 30),
                        ),
                     ),
                  ),
               ),
               Container(
                  width: 10,
               ),
               Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                     Text(
                        widget.historyItem.name,
                        textAlign: TextAlign.center,
                        style:
                        TextStyle(fontSize: 18, color: Colors.black),
                        maxLines: 1,
                     ),
                     Text(
                        widget.historyItem.url,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 18, color: Colors.grey.shade500),
                        maxLines: 1,
                     ),
                  ],
               ),
               ],
            ),
         )
             : Container(
         alignment: Alignment.center,
         child: Column(
            children: <Widget>[
               Container(
                  height: 80,
                  width: 80,
                  margin: const EdgeInsets.only(top: 10),
                  child: widget.historyItem.filePath != null &&
                      !widget.historyItem.filePath.startsWith("-") ?
                  Image.file(
                     File(widget.historyItem.filePath), fit: BoxFit.cover,
                     height: 80,
                     width: 80,)
                      :
                  Card(
                     color: Colors.grey.shade300,
                     elevation: 0,
                     shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                     ),
                     child: Center(
                        child: Text(
                           widget.historyItem.name.startsWith("Add")
                               ? "+"
                               : widget.historyItem.name[0].toUpperCase(),
                           style: TextStyle(
                               color: Colors.white, fontSize: 30),
                        ),
                     ),
                  ),
               ),
               Text(
                  widget.historyItem.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, color: Colors.black),
                  maxLines: 2,
               ),
            ],
         ),
      ),)
      ,
      )
      );
   }
   
   Color calculateColor() {
      return Color.lerp(
         Colors.white,
         Colors.grey.shade400,
         _controller.value,
      );
   }
}
