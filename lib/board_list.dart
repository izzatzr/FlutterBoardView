import 'package:boardview/board_item.dart';
import 'package:boardview/boardview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

typedef void OnDropList(int? listIndex, int? oldListIndex);
typedef void OnTapList(int? listIndex);
typedef void OnStartDragList(int? listIndex);

class BoardList extends StatefulWidget {
  final Widget? header;
  final Widget? footer;
  final List<BoardItem>? items;
  final Color? backgroundColor;
  final Color? headerBackgroundColor;
  final BoardViewState? boardView;
  final OnDropList? onDropList;
  final OnTapList? onTapList;
  final OnStartDragList? onStartDragList;
  final bool draggable;

  const BoardList({
    Key? key,
    this.header,
    this.items,
    this.footer,
    this.backgroundColor,
    this.headerBackgroundColor,
    this.boardView,
    this.draggable = true,
    this.index,
    this.onDropList,
    this.onTapList,
    this.onStartDragList,
  }) : super(key: key);

  final int? index;

  @override
  State<StatefulWidget> createState() {
    return BoardListState();
  }
}

class BoardListState extends State<BoardList>
    with AutomaticKeepAliveClientMixin {
  List<BoardItemState> itemStates = [];
  ScrollController boardListController = ScrollController();

  void onDropList(int? listIndex) {
    if (widget.onDropList != null)
      widget.onDropList!(listIndex, widget.boardView!.startListIndex);
    widget.boardView!.draggedListIndex = null;
    if (widget.boardView!.mounted) widget.boardView!.setState(() {});
  }

  void _startDrag(Widget item, BuildContext context) {
    if (widget.boardView != null && widget.draggable) {
      if (widget.onStartDragList != null) widget.onStartDragList!(widget.index);
      widget.boardView!
        ..startListIndex = widget.index
        ..height = context.size!.height
        ..draggedListIndex = widget.index!
        ..draggedItemIndex = null
        ..draggedItem = item
        ..onDropList = onDropList
        ..run();
      if (widget.boardView!.mounted) widget.boardView!.setState(() {});
    }
  }

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<Widget> listWidgets = [];
    if (widget.header != null)
      listWidgets.add(GestureDetector(
          onTap: () {
            if (widget.onTapList != null) widget.onTapList!(widget.index);
          },
          onTapDown: (otd) {
            if (widget.draggable) {
              RenderBox object = context.findRenderObject() as RenderBox;
              Offset pos = object.localToGlobal(Offset.zero);
              widget.boardView!
                ..initialX = pos.dx
                ..initialY = pos.dy
                ..rightListX = pos.dx + object.size.width
                ..leftListX = pos.dx;
            }
          },
          onLongPress: () {
            if (!widget.boardView!.widget.isSelecting && widget.draggable)
              _startDrag(widget, context);
          },
          onTapCancel: () {},
          child: Container(
              color: widget.headerBackgroundColor, child: widget.header!)));

    if (widget.items != null)
      listWidgets.add(ListView.builder(
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          controller: boardListController,
          itemCount: widget.items!.length,
          itemBuilder: (ctx, index) {
            var current = widget.items![index];

            if (current.boardList == null ||
                current.index != index ||
                current.boardList!.widget.index != widget.index ||
                current.boardList != this)
              current = BoardItem(
                  boardList: this,
                  item: current.item,
                  draggable: current.draggable,
                  index: index,
                  onDropItem: current.onDropItem,
                  onTapItem: current.onTapItem,
                  onDragItem: current.onDragItem,
                  onStartDragItem: current.onStartDragItem);

            return widget.boardView!.draggedItemIndex == index &&
                    widget.boardView!.draggedListIndex == widget.index
                ? Opacity(opacity: 0.0, child: current)
                : current;
          }));

    if (widget.footer != null) listWidgets.add(widget.footer!);

    Color? backgroundColor = Color.fromARGB(255, 255, 255, 255);

    if (widget.backgroundColor != null)
      backgroundColor = widget.backgroundColor;

    if (widget.boardView!.listStates.length > widget.index!)
      widget.boardView!.listStates.removeAt(widget.index!);

    widget.boardView!.listStates.insert(widget.index!, this);

    return Container(
        decoration: BoxDecoration(color: backgroundColor),
        child: Wrap(children: listWidgets));
  }
}
