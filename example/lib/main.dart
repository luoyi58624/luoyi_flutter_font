import 'package:flutter/material.dart';
import 'package:example/large_text.dart';
import 'package:luoyi_flutter_font/luoyi_flutter_font.dart';

/// 简易状态管理，保存当前选择的字体
final ValueNotifier<String?> fontFamily = ValueNotifier<String?>(null);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterFont.initFont(FlutterFontPreset.notoSansSC);
  fontFamily.value = FlutterFont.fontFamily;
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: fontFamily,
      builder: (context, value, child) {
        return MaterialApp(
          theme: ThemeData(
            fontFamily: value,
            fontFamilyFallback: FlutterFont.fontFamilyFallback,
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
          home: const HomePage(),
        );
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = false;

  int count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: ValueListenableBuilder(
          valueListenable: fontFamily,
          builder: (context, value, child) {
            return Text('动态字体 - ${value ?? '系统字体'}');
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    count++;
                  });
                },
                child: Text('count: $count'),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () {
                        FlutterFont.loadFont();
                        fontFamily.value = FlutterFont.fontFamily;
                      },
                child: const Text('加载系统字体'),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        await FlutterFont.loadFont(
                            FlutterFontPreset.initialFont);
                        fontFamily.value = FlutterFont.fontFamily;
                      },
                child: const Text('加载初始化字体'),
              ),
              const SizedBox(height: 8),
              const Text(
                '正常: $_simpleText',
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                ),
              ),
              const Text(
                '中等: $_simpleText',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Text(
                '加粗: $_simpleText',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...FontWeight.values.map(
                (e) => Text(
                  '$e: $_simpleText',
                  style: TextStyle(
                    fontWeight: e,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              ...FontWeight.values.map(
                (e) => ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => LargeTextPage(fontWeight: e)));
                  },
                  child: Text('${e.value} 大文本页面'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const String _simpleText = 'Hello，你好呀，按钮，工具，启动，组件';
