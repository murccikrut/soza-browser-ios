# Soza Browser iOS 0.1

Минимальная рабочая версия Soza Browser для iPhone на SwiftUI + WebKit.

## Уже работает
- открытие сайтов через WKWebView;
- адресная строка;
- Google-поиск, если введён не URL;
- назад / вперёд;
- обновить / остановить загрузку;
- несколько вкладок;
- переключатель и закрытие вкладок;
- жест «назад/вперёд» внутри WebView;
- ссылки с target=_blank открываются в текущей вкладке;
- HTTP-сайты разрешены для web-контента.

## Запуск в Xcode
1. Открой `SozaBrowser.xcodeproj`.
2. Выбери target `SozaBrowser` → `Signing & Capabilities`.
3. В `Team` выбери свой Apple Account / Personal Team.
4. Если Xcode жалуется на Bundle Identifier, замени `com.soza.browser` на уникальный, например `com.<твоё-имя>.sozabrowser`.
5. Выбери iPhone или iOS Simulator и нажми Run.

Проект не использует платные API и внешние зависимости.
