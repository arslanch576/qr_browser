import 'package:flutter/material.dart';
import 'package:drag_select_grid_view/drag_select_grid_view.dart';

class SelectionAppBar extends StatelessWidget implements PreferredSizeWidget {
  const SelectionAppBar({
    Key key,
    this.title,
    this.onEditCalled,
    this.onDeleteCalled,
    this.onGridSelectionChanged,
    this.onCreateQrSelected,
    this.mode,
    this.selection = Selection.empty,
  })  : assert(selection != null),
        super(key: key);

  final Widget title;
  final String mode;
  final Function onEditCalled;
  final Function onDeleteCalled;
  final Function onGridSelectionChanged;
  final Function onCreateQrSelected;
  final Selection selection;

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: kThemeAnimationDuration,
      child: selection.isSelecting
          ? AppBar(
              key: const Key('selecting'),
              titleSpacing: 0,
              leading: const CloseButton(),
              title: Text('${selection.amount} selected'),
              actions: <Widget>[
                selection.amount == 1
                    ? FlatButton(
                        child: Text(
                          "Edit",
                          style: TextStyle(fontSize: 17, color: Colors.white),
                        ),
                        onPressed: onEditCalled,
                      )
                    : Padding(
                        padding: const EdgeInsets.all(0),
                      ),
                FlatButton(
                  child: Text(
                    "Delete",
                    style: TextStyle(fontSize: 17, color: Colors.white),
                  ),
                  onPressed: onDeleteCalled,
                ),
              ],
            )
          : AppBar(
              key: const Key('not-selecting'),
              title: title,
              actions: <Widget>[
                 //FlatButton(child: Text("Create QR", style: TextStyle(color: Colors.white, fontSize: 18),), onPressed: onCreateQrSelected,),
                GestureDetector(
                  onTap: onGridSelectionChanged,
                  child: Icon(
                    mode.startsWith("grid")
                        ? Icons.apps
                        : Icons.format_list_bulleted,
                    size: 35,
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 20),
                ),
              ],
            ),
    );
  }
}
