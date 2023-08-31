/// @Author junhao.xiong
/// @Date 2023/4/21 15:43
/// @Description TODO
class UrlBean {
  UrlBean(
      {this.productUrl,
      this.desc,
      this.stage2Url,
      this.stageUrl,
      this.uatUrl,
      this.qaUrl,
      this.customUrl,
      this.selectedUrl});

  factory UrlBean.fromJson(dynamic json) => UrlBean(
      productUrl: json?['productUrl'],
      desc: json?['desc'],
      stage2Url: json?['stage2Url'],
      stageUrl: json?['stageUrl'],
      uatUrl: json?['uatUrl'],
      qaUrl: json?['qaUrl'],
      customUrl: json?['customUrl'],
      selectedUrl: json?['selectedUrl']);

  factory UrlBean.copy(UrlBean? bean) => UrlBean(
      productUrl: bean?.productUrl,
      desc: bean?.desc,
      stageUrl: bean?.stageUrl,
      stage2Url: bean?.stage2Url,
      uatUrl: bean?.uatUrl,
      qaUrl: bean?.qaUrl,
      customUrl: bean?.customUrl,
      selectedUrl: bean?.selectedUrl);

  Map<dynamic, dynamic> toJson() => {
        'productUrl': productUrl,
        'desc': desc,
        'stage2Url': stage2Url,
        'stageUrl': stageUrl,
        'uatUrl': uatUrl,
        'qaUrl': qaUrl,
        'customUrl': customUrl,
        'selectedUrl': selectedUrl
      };

  ///环境描述,可以为空
  String? desc;

  ///正式环境
  String? productUrl;
  ///预发2环境
  String? stage2Url;

  ///预发环境
  String? stageUrl;

  ///UAT环境
  String? uatUrl;

  ///测试环境
  String? qaUrl;

  ///自定义环境，可以不传，保存用户手动输入的地址。
  String? customUrl;

  ///当前选中的Url，可以不传，默认赋值。
  String? selectedUrl;

  @override
  String toString() {
    return 'UrlBean{desc: $desc, productUrl: $productUrl, stageUrl: $stageUrl,  stage2Url: $stage2Url, uatUrl: $uatUrl,qaUrl: $qaUrl, customUrl: $customUrl, selectedUrl: $selectedUrl}';
  }
}
