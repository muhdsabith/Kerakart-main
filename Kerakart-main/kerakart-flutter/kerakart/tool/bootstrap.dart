import 'dart:io';

Future<void> main() async {
  if (!File('pubspec.yaml').existsSync()) {
    stderr.writeln('Run this command from the kerakart project folder.');
    exit(1);
  }
  final flutter = Platform.isWindows ? 'flutter.bat' : 'flutter';
  final process = await Process.start(
    flutter,
    [
      'create',
      '--platforms=android,web',
      '--org=com.kerakart',
      '--project-name=kerakart',
      '--no-pub',
      '.',
    ],
    mode: ProcessStartMode.inheritStdio,
    runInShell: Platform.isWindows,
  );
  final code = await process.exitCode;
  if (code != 0) exit(code);
  final generatedTest = File('test/widget_test.dart');
  if (generatedTest.existsSync()) generatedTest.deleteSync();
  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (manifest.existsSync()) {
    var text = manifest.readAsStringSync();
    text = text
        .replaceAll('android:label="kerakart"', 'android:label="KeraBasket"')
        .replaceAll('android:label="Kerakart"', 'android:label="KeraBasket"')
        .replaceAll('@mipmap/ic_launcher', '@drawable/kerabasket_icon')
        .replaceAll('@drawable/kerakart_icon', '@drawable/kerabasket_icon');
    manifest.writeAsStringSync(text);
  }
  final icon = File('android/app/src/main/res/drawable/kerabasket_icon.png');
  icon.parent.createSync(recursive: true);
  File('assets/images/kerabasket_logo.png').copySync(icon.path);
  final web = File('web/index.html');
  if (web.existsSync()) {
    web.writeAsStringSync(
      web
          .readAsStringSync()
          .replaceAll('<title>kerakart</title>', '<title>KeraBasket</title>')
          .replaceAll(
            'A new Flutter project.',
            'KeraBasket — everyday, elevated.',
          ),
    );
  }
  stdout.writeln('KeraBasket platforms are ready. Next: flutter pub get');
}
