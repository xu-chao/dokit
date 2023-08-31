import 'package:flutter/material.dart';

/// @Author junhao.xiong
/// @Date 2023/4/24 17:20
/// @Description 底部通用列表弹框
class ListWidget<T> extends StatefulWidget {
  List<T>? list;
  Function(T vaule, int index)? onItemClick;
  Function()? onSureClick;
  IndexedWidgetBuilder itemWidgetBuilder;
  String? title;

  ListWidget(
      {super.key,
      required this.itemWidgetBuilder,
      required this.list,
      this.onItemClick,
      this.onSureClick,
      this.title});

  @override
  State<StatefulWidget> createState() {
    return ListState();
  }
}

class ListState extends State<ListWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
        constraints: BoxConstraints(maxHeight: 450),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          widget.title?.isNotEmpty == true
              ? Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Color(0xfff6f6f7),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12)),
                  ),
                  child: Text(widget.title!,
                      style: const TextStyle(
                          fontFamily: 'PingFang SC',
                          color: Colors.black,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.none)),
                )
              : const SizedBox(),
          Flexible(
              child: Container(
                  color: Colors.white,
                  padding: EdgeInsets.zero,
                  child: ListView.separated(
                      padding: EdgeInsets.zero,
                      itemBuilder: (BuildContext context, int index) {
                        return InkWell(
                            onTap: () {
                              if (widget.onItemClick != null) {
                                widget.onItemClick!(widget.list![index], index);
                              }
                            },
                            child: widget.itemWidgetBuilder(context, index));
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Container(height: 1, color: Color(0xFF777C82));
                      },
                      itemCount: widget.list?.length ?? 0))),
          InkWell(
              onTap: () {
                if (widget.onSureClick != null) {
                  widget.onSureClick!();
                }
              },
              child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  color: Color(0xFF32bcf9),
                  child: Text(widget.title!,
                      style: const TextStyle(
                          fontFamily: 'PingFang SC',
                          color: Colors.white,
                          fontSize: 18))))
        ]));
  }
}
