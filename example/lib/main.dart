import 'package:flutter/material.dart';
import 'package:example/large_text.dart';
import 'package:flutter_obs/flutter_obs.dart';
import 'package:luoyi_flutter_font/luoyi_flutter_font.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterFont.initFont(FontPreset.notoSansSC);
  runApp(const _App());
}

class _App extends StatelessWidget {
  const _App();

  @override
  Widget build(BuildContext context) {
    return ObsBuilder(builder: (context) {
      return MaterialApp(
        theme: ThemeData(
          fontFamily: FlutterFont.fontFamily,
          fontFamilyFallback: FlutterFont.fontFamilyFallback,
          materialTapTargetSize: MaterialTapTargetSize.padded,
        ),
        home: const HomePage(),
      );
    });
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
        title: ObsBuilder(builder: (context) {
          return Text('动态字体 - ${FlutterFont.fontFamily ?? '系统字体'}');
        }),
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
                      },
                child: const Text('加载系统字体'),
              ),
              ElevatedButton(
                onPressed: loading
                    ? null
                    : () async {
                        await FlutterFont.loadFont(FontPreset.initialFont);
                        print(FlutterFont.fontFamily);
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
                  '${e.value}: $_simpleText',
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
