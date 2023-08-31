import 'package:flutter/material.dart';

/// @Author junhao.xiong
/// @Date 2023/4/24 17:19
/// @Description 通用提示弹框
class TitleTipsDialog extends Dialog {
  bool isCancel = true; //是否可以点击空白处和按返回按钮取消
  bool isSingleButton = false; //是不是显示一个按钮
  String? title;
  String? content;
  String? btnSureText; //确认按钮文本
  String? btnCancelText; //取消按钮文本

  Function(bool isLeftButton)? onButClick; //按钮点击时间

  TitleTipsDialog(
      {super.key,
      this.isCancel = true,
      this.title,
      this.content,
      this.isSingleButton = false,
      this.btnCancelText,
      this.btnSureText,
      this.onButClick});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        body: WillPopScope(
            onWillPop: () async {
              return isCancel;
            },
            child: InkWell(
                onTap: () {
                  if (isCancel) {
                    Navigator.pop(context);
                  }
                },
                child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20),
                    alignment: Alignment.center,
                    child: Container(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        decoration: const ShapeDecoration(
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(8.0)))),
                        child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Text(title ?? '',
                                  style: TextStyle(
                                      fontSize: 17, color: Colors.black)),
                              SizedBox(height: 20),
                              Container(
                                  padding: EdgeInsets.only(
                                      left: 15, right: 15, bottom: 20),
                                  child: Text(content ?? '',
                                      style: TextStyle(
                                          fontSize: 15, color: Colors.black))),
                              Divider(color: Color(0xFF333333), height: 1),
                              SizedBox(height: 10),

                              ///单个按钮和双按钮显示判断布局
                              isSingleButton
                                  ? _buttonWidget(context, btnSureText ?? '')
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                          Flexible(
                                              child: _buttonWidget(context,
                                                  btnCancelText ?? '取消',
                                                  isLeftButton: true)),
                                          Container(
                                              width: 1,
                                              height: 30,
                                              color: Color(0xFF999999)),
                                          Flexible(
                                              child: _buttonWidget(
                                                  context, btnSureText ?? '确定'))
                                        ])
                            ]))))));
  }

  ///按钮布局 isLeftButton 是不是点击左边的按钮
  Widget _buttonWidget(BuildContext context, String butText,
      {bool isLeftButton = false}) {
    return InkWell(
        onTap: () {
          Navigator.pop(context);
          if (onButClick != null) {
            onButClick!(isLeftButton);
          }
        },
        child: Container(
            height: 30,
            alignment: Alignment.center,
            child: Text(butText,
                style: TextStyle(fontSize: 15, color: Color(0xFF32bcf9)))));
  }
}
