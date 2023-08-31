import 'package:flutter/material.dart';

///解决软键盘弹出
class BottomPopup extends StatelessWidget {
  final Widget child;

  const BottomPopup({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var edgeInsets = MediaQuery.of(context).viewInsets;
    print('BottomPopup edgeInsets $edgeInsets');

    ///解决软键盘弹出，遮挡输入框问题.动态设置Container的margin，将布局顶在输入法之上。
    return SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(children: [child, Container(margin: edgeInsets)]));
  }
}
