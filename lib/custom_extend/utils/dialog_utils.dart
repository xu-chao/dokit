import 'package:dokit/custom_extend/widget/title_tips_dialog.dart';
import 'package:flutter/material.dart';

/// @Author junhao.xiong
/// @Date 2023/2/20 13:21
/// @Description弹框
class DialogUtils {
  ///标题提示弹框
  static Dialog showTipsDialog(BuildContext context,
      {Key? key,
      isCancel = true,
      isSingleButton = false,
      title,
      content,
      onButClick, //val 参数true:取消按钮回调（左侧）; false:确定按钮回调（右侧）
      btnSureText,
      btnCancelText}) {
    Dialog dialog = TitleTipsDialog(
        key: key,
        isCancel: isCancel,
        title: title,
        content: content,
        isSingleButton: isSingleButton,
        btnSureText: btnSureText,
        btnCancelText: btnCancelText,
        onButClick: onButClick);
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return dialog;
        });
    return dialog;
  }

  ///底部弹框
  static showBottomSheetDialog(BuildContext context, Widget widget) {
    showModalBottomSheet(
        useRootNavigator: true,
        enableDrag: true,
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return widget;
        });
  }
}




