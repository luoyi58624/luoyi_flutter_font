优化flutter中文字体渲染问题，动态从资产包、网络加载字体，此库仅作用于全局字体，如果你需要应用局部字体请使用google_fonts

### 安装依赖

```
flutter pub add luoyi_flutter_font
```

### 添加中文字体文件

```yaml
flutter:
  fonts:
    - family: NotoSansSC
      fonts:
        - asset: packages/luoyi_flutter_font/fonts/NotoSansSC/700.ttf
        - asset: packages/luoyi_flutter_font/fonts/NotoSansSC/500.ttf
```

### 初始化默认字体

```dart
import 'package:flutter/material.dart';
import 'package:luoyi_flutter_font/luoyi_flutter_font.dart';
import 'package:flutter_obs/flutter_obs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // 初始化字体
  await FlutterFont.initFont(FontPreset.notoSansSC);
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        // 设置字族名
        fontFamily: FlutterFont.fontFamily,
      ),
      home: const HomePage(),
    );
  }
}
```

### 加载动态字体

- 注意你需要使用状态管理来更新 App 的 fontFamily，字体加载成功后会返回一个bool值，
- 将 FlutterFont.fontFamily 应用到当前状态即可。

```dart
void test() {
  // 加载系统字体，实际上就是指定fontFamily = ''
  FlutterFont.loadFont(FontPreset.systemFont);

  // 加载项目初始化的字体
  FlutterFont.loadFont(FontPreset.initialFont);

  // 加载资产包中的字体，不要定义 fontUrl 和 fontWeights
  FlutterFont.loadFont(FontModel(
    fontFamily: 'my_font',
  ));

  // 加载在线字体，如果是客户端，加载成功后会缓存到本地
  FlutterFont.loadFont(FontModel(
    fontFamily: 'LongCang',
    fontUrl: 'https://fonts.gstatic.com/s/a/f626a05f45d156332017025fc68902a92f57f51ac57bb4a79097ee7bb1a97352.ttf',
  ));

  // 加载多种字重在线字体
  FlutterFont.loadFont(FontModel(
    fontFamily: 'NotoSansSC',
    fontWeights: {
      400: 'https://fonts.gstatic.com/s/a/eacedb2999b6cd30457f3820f277842f0dfbb28152a246fca8161779a8945425.ttf',
      500: 'https://fonts.gstatic.com/s/a/5383032c8e54fc5fa09773ce16483f64d9cdb7d1f8e87073a556051eb60f8529.ttf',
      700: 'https://fonts.gstatic.com/s/a/a7a29b6d611205bb39b9a1a5c2be5a48416fbcbcfd7e6de98976e73ecb48720b.ttf',
    },
  ));
}
```


