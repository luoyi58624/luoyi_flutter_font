flutter --version
flutter pub get
# shellcheck disable=SC2164
cd ./example
flutter build web --web-renderer=canvaskit --pwa-strategy none --base-href /luoyi_flutter_font/
