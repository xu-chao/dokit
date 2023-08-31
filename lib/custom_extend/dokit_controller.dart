import 'dart:convert';
import 'dart:io';
import 'package:dokit/custom_extend/widget/bottom_popup.dart';
import 'package:dokit/custom_extend/utils/dialog_utils.dart';
import 'package:dokit/custom_extend/widget/list_widget.dart';
import 'package:dokit/custom_extend/widget/proxy_setting_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dokit.dart';
import '../ui/dokit_btn.dart';
import 'bean/url_bean.dart';

/// @Author junhao.xiong
/// @Date 2023/4/21 15:25
/// @Description 自定义业务扩展的Controller
class DoKitController {
  static final String _group = '业务开发';
  static final String _group_desc = '业务类的扩展功能';
  static final String sp_url_key = 'URL_KEY';

  ///代理的Ip和端口
  static String ip = '';
  static String port = '';

  ///全局的_context，此context建议是和应用生命周期相同，避免内测泄漏。
  static BuildContext? _context;

  ///保存的Url Map
  static final Map<String, UrlBean> _realUrlMap = {};

  ///用户切换Url等操作的Map
  static final Map<String, UrlBean> _tempUrlMap = {};

  ///环境切换弹框的globalKey，更新UI使用。
  static GlobalKey<ListState>? _globalKey;

  ///外部传入context
  static void setBuildContext(BuildContext? context) {
    _context = context;
  }

  ///提供给外部的获取Url方法
  ///index：默认0，设置了多组服务地址的情况，按照initUrlSwitch()方法传入的urlList下标返回指定Url。
  static dynamic getUrl({int index = 0}) {
    if (_realUrlMap.isEmpty || _realUrlMap.length <= index) {
      print('获取Url下标越界！_realUrlMap.length：${_realUrlMap.length}');
      return '';
    }
    var bean = _realUrlMap['$index'];
    return bean?.selectedUrl ?? '';
  }

  ///创建扩展业务group和group子菜单选项
  static void buildBizKit(String name, {String? group, String? desc, Function? action}) {
    DoKit.i.buildBizKit(name: name, group: group ?? _group, desc: desc ?? _group_desc, action: action);
  }

  ///关闭dokit主界面
  static void closeDebugPage() {
    final state = DoKitBtn.doKitBtnKey.currentState;
    state?.closeDebugPage();
  }

  ///添加设置代理选项
  static Future<void> setProxy({String name = '设置代理'}) async {
    var sp = await SharedPreferences.getInstance();
    ip = sp.getString('ip') ?? '';
    port = sp.getString('port') ?? '';
    print('setProxy 代理 ip $ip port $port');
    buildBizKit(name, action: () {
      if (_context == null) {
        Fluttertoast.showToast(msg: 'BuildContext 未实例化！');
        return;
      }
      closeDebugPage();
      DialogUtils.showBottomSheetDialog(_context!, BottomPopup(child: ProxySettingWidget(title: name)));
    });
  }

  ///添加环境切换选项，支持多组url环境,针对应用对接多个服务后端的情况
  static Future<void> initUrlSwitch(List<UrlBean> urlList, {String name = '环境切换'}) async {
    if (urlList.isEmpty) {
      await Fluttertoast.showToast(msg: '环境列表为空');
      return;
    }
    await _initUrlMap(urlList);
    buildBizKit(name, action: () async {
      if (_context == null) {
        await Fluttertoast.showToast(msg: 'BuildContext 未实例化！');
        return;
      }
      await _initUrlMap(urlList);
      closeDebugPage();
      _showUrlDialog(name, urlList);
    });
  }

  ///切换环境底部弹框
  static void _showUrlDialog(String name, List<UrlBean> urlList) {
    _globalKey = GlobalKey();
    DialogUtils.showBottomSheetDialog(
        _context!,
        BottomPopup(
            child: ListWidget<UrlBean>(
                key: _globalKey,
                title: name,
                itemWidgetBuilder: (BuildContext context, int index) {
                  var bean = _tempUrlMap['$index'];
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    bean?.desc?.isNotEmpty == true
                        ? Container(
                            margin: EdgeInsets.only(top: 10),
                            alignment: Alignment.center,
                            child: Text('${bean?.desc}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)))
                        : SizedBox(),
                    _urlWidget(bean?.selectedUrl == bean?.productUrl, '正式：', bean?.productUrl, bean),
                    _urlWidget(
                        bean?.stage2Url != null && bean?.selectedUrl == bean?.stage2Url, '预发2：', bean?.stage2Url, bean),
                    _urlWidget(
                        bean?.stageUrl != null && bean?.selectedUrl == bean?.stageUrl, '预发1：', bean?.stageUrl, bean),
                    _urlWidget(bean?.uatUrl != null && bean?.selectedUrl == bean?.uatUrl,
                        '${bean?.stage2Url != null || bean?.stageUrl != null ? 'UAT：' : '预发：'}', bean?.uatUrl, bean),
                    _urlWidget(bean?.qaUrl != null && bean?.selectedUrl == bean?.qaUrl, '测试：', bean?.qaUrl, bean),
                    _customUrlWidget(bean?.selectedUrl == bean?.customUrl, '自定义：', bean)
                  ]);
                },
                list: urlList,
                onSureClick: () {
                  var selectUrlIsEmpty = false;
                  _tempUrlMap.forEach((key, value) {
                    if (value.selectedUrl == null || value.selectedUrl?.isEmpty == true) {
                      selectUrlIsEmpty = true;
                      return;
                    }
                  });
                  if (selectUrlIsEmpty) {
                    Fluttertoast.showToast(msg: 'Url不能设置为空');
                    return;
                  }
                  DialogUtils.showTipsDialog(_context!, title: '提示', content: '切换环境将重启应用，确定切换？',
                      onButClick: (isLeftButton) async {
                    if (!isLeftButton) {
                      await _saveUrlMap();
                      Navigator.pop(_context!);
                      exit(0);
                    }
                  });
                })));
  }

  ///Url横向布局
  static Widget _urlWidget(bool isChecked, String urlName, String? url, UrlBean? bean) {
    return Visibility(
      visible: url != null && url.isNotEmpty,
      child: Row(children: [
        SizedBox(width: 10),
        Checkbox(
            value: isChecked,
            onChanged: (b) {
              if (url == null || url.isEmpty) {
                Fluttertoast.showToast(msg: '未配置此环境！');
                return;
              }
              _globalKey?.currentState?.setState(() {
                print('_urlWidget  url $url');
                bean?.selectedUrl = url;
              });
            }),
        Text(urlName, style: TextStyle(fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis),
        Flexible(
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SelectableText(url ?? '', style: TextStyle(fontSize: 16), onTap: () {
                  ///点击Url文字事件
                  if (url == null || url.isEmpty) {
                    Fluttertoast.showToast(msg: '未配置此环境！');
                    return;
                  }
                  _globalKey?.currentState?.setState(() {
                    print('_urlWidget onTap url $url');
                    bean?.selectedUrl = url;
                  });
                }))),
        SizedBox(width: 10)
      ]),
    );
  }

  ///自定义Url横向布局
  static Widget _customUrlWidget(bool isChecked, String urlName, UrlBean? bean) {
    var controller = TextEditingController();
    controller.text = bean?.customUrl ?? '';
    return Row(children: [
      SizedBox(width: 10),
      Checkbox(
          value: isChecked,
          onChanged: (b) {
            if (bean?.customUrl == null || bean?.customUrl?.isEmpty == true) {
              Fluttertoast.showToast(msg: '请先输入自定义Url');
              return;
            }
            _globalKey?.currentState?.setState(() {
              print('_customUrlWidget  url ${bean?.customUrl}');
              bean?.selectedUrl = bean.customUrl;
            });
          }),
      Text(urlName, style: TextStyle(fontSize: 16)),
      Flexible(
          child: Container(
              alignment: Alignment.center,
              height: 50,
              width: double.infinity,
              child: TextField(
                  controller: controller,
                  style: TextStyle(fontSize: 16),
                  decoration: InputDecoration(hintText: '例：http//192.168.1.1/', border: InputBorder.none),
                  maxLines: 1,
                  onChanged: (value) {
                    print('_customUrlWidget isChecked $isChecked value $value');
                    bean?.customUrl = value;
                    if (isChecked) {
                      bean?.selectedUrl = value;
                    }
                  }))),
      SizedBox(width: 10)
    ]);
  }

  ///保存jsonMap到本地
  static Future<void> _saveUrlMap() async {
    ///点击确定切换，将临时的Map数据赋值给_realUrlMap，并保存到本地
    _realUrlMap.clear();
    _realUrlMap.addAll(_tempUrlMap);
    var jsonMap = json.encode(_realUrlMap);
    var value = await SharedPreferences.getInstance();
    var isSave = await value.setString(sp_url_key, jsonMap);
    print('_saveUrlMap isSave $isSave jsonMap $jsonMap ');
  }

  ///加载本地记录的Url数据
  static Future<void> _initUrlMap(List<UrlBean> urlList) async {
    ///_selectUrlMap为空，优先加载本地保存数据。
    if (_realUrlMap.isEmpty) {
      var value = await SharedPreferences.getInstance();
      var jsonMap = value.getString(sp_url_key);
      print('_initSelectUrlMap jsonMap $jsonMap');
      if (jsonMap?.isNotEmpty == true) {
        Map<String, dynamic> map = json.decode(jsonMap!);
        map.forEach((key, value) {
          _realUrlMap[key] = UrlBean.fromJson(value);
        });
      }
    }

    ///本地保存数据为空，加载默认数据.
    ///本地保存的map和urlList长度不一致，表示外部传递数据有变动，重新赋值。
    if (_realUrlMap.isEmpty || _realUrlMap.length != urlList.length) {
      for (var i = 0; i < urlList.length; i++) {
        var bean = urlList[i];

        ///赋值默认的customUrl
        if (bean.selectedUrl == null || bean.selectedUrl?.isEmpty == true) {
          if (bean.qaUrl?.isNotEmpty == true) {
            bean.selectedUrl = bean.qaUrl;
          } else if (bean.uatUrl?.isNotEmpty == true) {
            bean.selectedUrl = bean.uatUrl;
          } else if (bean.stageUrl?.isNotEmpty == true) {
            bean.selectedUrl = bean.stageUrl;
          } else if (bean.stage2Url?.isNotEmpty == true) {
            bean.selectedUrl = bean.stage2Url;
          } else if (bean.productUrl?.isNotEmpty == true) {
            bean.selectedUrl = bean.productUrl;
          } else if (bean.customUrl?.isNotEmpty == true) {
            bean.selectedUrl = bean.customUrl;
          }
        }
        _realUrlMap['$i'] = bean;
      }
    }

    ///将数据copy给_tempSelectUrlMap，使用selectUrlTempMap进行切换操作。
    _tempUrlMap.clear();
    _realUrlMap.forEach((key, value) {
      _tempUrlMap[key] = UrlBean.copy(value);
    });
    print('_initUrlMap _realUrlMap $_realUrlMap\n_tempUrlMap $_tempUrlMap');
  }
}
