import 'dart:io';

import 'package:dokit/custom_extend/dokit_controller.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/dialog_utils.dart';

/// @Author junhao.xiong
/// @Date 2023/4/24 17:16
/// @Description 设置代理布局
class ProxySettingWidget extends StatelessWidget {
  ProxySettingWidget({this.title});

  TextEditingController? ipController;
  TextEditingController? portController;
  String? title;

  @override
  StatelessElement createElement() {
    ipController = TextEditingController();
    if (DoKitController.ip.isNotEmpty) {
      ipController?.text = DoKitController.ip;
    }
    portController = TextEditingController();
    if (DoKitController.port.isNotEmpty) {
      portController?.text = DoKitController.port;
    }
    return super.createElement();
  }

  @override
  Widget build(BuildContext context) {
    return Column(mainAxisSize: MainAxisSize.min, children: [
      title?.isNotEmpty == true
          ? Container(
              height: 50,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: Color(0xfff6f6f7),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12)),
              ),
              child: Text(title!,
                  style: const TextStyle(
                      fontFamily: 'PingFang SC',
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.none)),
            )
          : SizedBox(),
      Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _inputWidget('IP地址:',
                hintText: 'Ip：192.128.1.1', controller: ipController),
            SizedBox(height: 5),
            _inputWidget('端口号:',
                hintText: 'Port：8888', controller: portController),
            SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: _buttonWidget(context, '清除', isLeftButton: true)),
              SizedBox(width: 10),
              Flexible(child: _buttonWidget(context, '保存'))
            ])
          ]))
    ]);
  }

  ///输入框布局
  Widget _inputWidget(String? title,
      {String? hintText, TextEditingController? controller}) {
    return Row(children: [
      Text(title ?? '',
          style: const TextStyle(
              fontFamily: 'PingFang SC', color: Colors.black, fontSize: 16)),
      SizedBox(width: 5),
      Flexible(
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 5),
              decoration: BoxDecoration(
                  border: Border.all(color: Colors.black45, width: 1)),
              alignment: Alignment.center,
              height: 55,
              width: double.infinity,
              child: TextField(
                  controller: controller,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                      hintText: hintText, border: InputBorder.none),
                  maxLines: 1)))
    ]);
  }

  ///按钮布局 isLeftButton 是不是点击左边的按钮
  Widget _buttonWidget(BuildContext context, String butText,
      {bool isLeftButton = false}) {
    return InkWell(
        onTap: () {
          var ip = ipController?.text;
          var port = portController?.text;

          ///点击清除按钮，并且输入框为空，直接关闭代理弹框。
          if (isLeftButton &&
              ip?.isEmpty == true &&
              port?.isEmpty == true &&
              DoKitController.ip.isEmpty &&
              DoKitController.port.isEmpty) {
            Navigator.pop(context);
            return;
          }

          ///保存按钮提示
          if (!isLeftButton &&
              (ip == null || ip.isEmpty || port == null || port.isEmpty)) {
            Fluttertoast.showToast(msg: 'IP和端口号不能为空');
            return;
          }

          String content;
          if (isLeftButton) {
            content = '清除代理设置需要重启应用，确定清除？';
          } else {
            content = '设置代理需要重启应用，确定设置？';
          }
          DialogUtils.showTipsDialog(context, title: '提示', content: content,
              onButClick: (isCancel) async {
            if (!isCancel) {
              var sp = await SharedPreferences.getInstance();
              if (isLeftButton) {
                await sp.remove('ip');
                await sp.remove('port');
              } else {
                await sp.setString('ip', ip!);
                await sp.setString('port', port!);
              }
              Navigator.pop(context);
              exit(0);
            }
          });
        },
        child: Container(
            height: 50,
            decoration: BoxDecoration(
                color: Color(0xFF32bcf9),
                borderRadius: BorderRadius.all(Radius.circular(8))),
            alignment: Alignment.center,
            child: Text(butText,
                style: const TextStyle(
                    fontFamily: 'PingFang SC',
                    color: Colors.white,
                    fontSize: 18))));
  }
}
