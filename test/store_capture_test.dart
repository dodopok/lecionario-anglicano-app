@Tags(['capture'])
library;

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
// google_fonts looks for bundled fonts through this one variable. Pointing it
// at the files on disk is what keeps it from reaching for the network.
// ignore: implementation_imports
import 'package:google_fonts/src/google_fonts_base.dart' as google_fonts;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:lecionario_anglicano/core/theme/app_theme.dart';
import 'package:lecionario_anglicano/data/models/lectionary_models.dart';
import 'package:lecionario_anglicano/data/services/lectionary_api.dart';
import 'package:lecionario_anglicano/data/services/local_preferences.dart';
import 'package:lecionario_anglicano/presentation/app_controller.dart';
import 'package:lecionario_anglicano/presentation/app_copy.dart';
import 'package:lecionario_anglicano/presentation/app_shell.dart';
import 'package:lecionario_anglicano/presentation/widgets/home_sections.dart';

/// Renders the App Store screenshots from the real interface, with the real
/// fonts and icons, at the pixel sizes the store asks for.
///
/// The lectionary comes from responses captured from the production API, so
/// the images show what the app really serves. Driven by
/// tool/capture_store_screenshots.sh, which fetches those responses first.
///
///   FIXTURE_DIR=... FONT_DIR=... ICON_FONT=... CAPTURE_DIR=... \
///     flutter test test/store_capture_test.dart --tags capture
void main() {
  final fixtures = Directory(_env('FIXTURE_DIR'));
  final captures = Directory(_env('CAPTURE_DIR'))..createSync(recursive: true);

  setUpAll(() async {
    await initializeDateFormatting();
    await _loadFonts();
    HttpOverrides.global = _CoverImages(_covers(fixtures));
  });
  tearDownAll(() => HttpOverrides.global = null);

  for (final device in _devices) {
    for (final language in AppLanguage.values) {
      testWidgets('${device.name} ${language.code}', (tester) async {
        final source = _CapturedApi(fixtures, language);

        tester.view.physicalSize = device.pixels;
        tester.view.devicePixelRatio = device.pixelRatio;
        addTearDown(tester.view.reset);

        SharedPreferences.setMockInitialValues({
          'app_language': language.code,
        });
        final controller = AppController(
          api: source,
          localPreferences: LocalPreferences(
            await SharedPreferences.getInstance(),
          ),
        );
        addTearDown(controller.dispose);
        await controller.initialize();

        final copy = AppCopy(language);
        var shot = 0;
        Future<void> capture(String name) async {
          await tester.pumpAndSettle();
          await _settleImages(tester);
          await expectLater(
            find.byType(MaterialApp),
            matchesGoldenFile(
              '${captures.path}/${device.name}-${language.code}-'
              '${shot.toString().padLeft(2, '0')}-$name.png',
            ),
          );
          shot++;
        }

        await tester.pumpWidget(
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) => MaterialApp(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              locale: language.locale,
              localizationsDelegates: GlobalMaterialLocalizations.delegates,
              supportedLocales: AppLanguage.values.map((l) => l.locale),
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(padding: device.insets),
                child: child!,
              ),
              home: AppShell(controller: controller),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // 1. Choosing a prayer book, with the covers the API serves.
        await capture('choose');

        await tester.tap(find.text(device.book[language]!));
        await tester.pumpAndSettle();
        await tester.tap(find.text(copy.continueLabel));
        await tester.pumpAndSettle();

        // 2. Today, and the month it belongs to.
        await capture('home');

        // 3. The day itself. On a phone that is a sheet; on a tablet the
        //    readings are already beside the month, so open one of them.
        if (device.opensDaySheet) {
          await tester.tap(find.byType(DailyHero));
          await tester.pumpAndSettle();
          await capture('day');
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
        } else {
          await tester.tap(find.byType(ReadingsCard));
          await tester.pumpAndSettle();
          if (find.byKey(const ValueKey('reading-sheet')).evaluate().isEmpty) {
            // Tap the first reference rather than the card itself.
            final references = find.descendant(
              of: find.byType(ReadingsCard),
              matching: find.byType(InkWell),
            );
            await tester.tap(references.first);
            await tester.pumpAndSettle();
          }
          await capture('reading');
          await tester.tapAt(const Offset(10, 10));
          await tester.pumpAndSettle();
        }

        // 4. Preferences.
        await tester.tap(find.byIcon(Icons.tune_rounded));
        await tester.pumpAndSettle();
        await capture('settings');
      });
    }
  }
}

typedef _Device = ({
  String name,
  Size pixels,
  double pixelRatio,
  EdgeInsets insets,
  bool opensDaySheet,
  Map<AppLanguage, String> book,
});

/// One entry per slot App Store Connect offers. Which iPhone slot a listing
/// shows depends on the listing, and a 6.9" image is rejected outright by a
/// 6.5" slot, so both are rendered.
const _devices = <_Device>[
  (
    // 6.5": iPhone 11/XS Max through 14 Plus.
    name: 'iphone65',
    pixels: Size(1284, 2778),
    pixelRatio: 3,
    insets: EdgeInsets.only(top: 47, bottom: 34),
    opensDaySheet: true,
    book: _books,
  ),
  (
    // 6.9": iPhone 16 Pro Max and kin, where the island takes the top.
    name: 'iphone69',
    pixels: Size(1290, 2796),
    pixelRatio: 3,
    insets: EdgeInsets.only(top: 59, bottom: 34),
    opensDaySheet: true,
    book: _books,
  ),
  (
    // 13": iPad Pro.
    name: 'ipad13',
    pixels: Size(2064, 2752),
    pixelRatio: 2,
    insets: EdgeInsets.only(top: 24, bottom: 20),
    opensDaySheet: false,
    book: _books,
  ),
];

const _books = {
  AppLanguage.pt: 'IEAB - 2015',
  AppLanguage.en: 'ACNA - 2019',
  AppLanguage.es: 'ACNA - 2019',
};

String _env(String name) {
  final value = Platform.environment[name];
  if (value == null || value.isEmpty) {
    throw StateError('$name is not set — run tool/render_store_screenshots.sh');
  }
  return value;
}

/// The families the app asks google_fonts for, and the file each one lives in.
const _families = {'CormorantGaramond': 'cg.ttf', 'SourceSans3': 'ss.ttf'};

/// How google_fonts names a family's styles: `Family_variant` for the loaded
/// font, `Family-Style` for the file it looks for.
const _variants = {
  'regular': 'Regular',
  'italic': 'Italic',
  '100': 'Thin',
  '200': 'ExtraLight',
  '300': 'Light',
  '500': 'Medium',
  '600': 'SemiBold',
  '700': 'Bold',
  '800': 'ExtraBold',
  '900': 'Black',
  '100italic': 'ThinItalic',
  '200italic': 'ExtraLightItalic',
  '300italic': 'LightItalic',
  '500italic': 'MediumItalic',
  '600italic': 'SemiBoldItalic',
  '700italic': 'BoldItalic',
  '800italic': 'ExtraBoldItalic',
  '900italic': 'BlackItalic',
};

Future<void> _loadFonts() async {
  final fontDir = _env('FONT_DIR');

  // Registered up front, so the very first frame is drawn in the real
  // typefaces rather than the fallback.
  for (final family in _families.entries) {
    final bytes = await File('$fontDir/${family.value}').readAsBytes();
    for (final variant in _variants.keys) {
      await (FontLoader('${family.key}_$variant')
            ..addFont(Future.value(ByteData.sublistView(bytes))))
          .load();
    }
  }

  // Without this the Material icons draw as empty boxes.
  final icons = await File(_env('ICON_FONT')).readAsBytes();
  await (FontLoader('MaterialIcons')
        ..addFont(Future.value(ByteData.sublistView(icons))))
      .load();

  // google_fonts does its own loading regardless, and a test cannot reach
  // fonts.gstatic.com. Hand it the same files as bundled assets instead.
  google_fonts.assetManifest = _FontManifest();
  GoogleFonts.config.allowRuntimeFetching = false;
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (message) async {
        final key = utf8.decode(
          Uint8List.sublistView(message!),
        );
        final file = _families[key.split('/').last.split('-').first];
        if (file == null) return null;
        return ByteData.sublistView(
          await File('$fontDir/$file').readAsBytes(),
        );
      });
}

/// Presents the two font files as one asset per style, which is how
/// google_fonts expects a bundled family to look.
class _FontManifest implements AssetManifest {
  @override
  List<String> listAssets() => [
    for (final family in _families.keys)
      for (final style in _variants.values) 'fonts/$family-$style.ttf',
  ];

  @override
  List<AssetMetadata> getAssetVariants(String key) => const [];
}

/// Image.network resolves off the frame loop, so pumpAndSettle returns
/// perfectly happy with a tree whose pictures have not arrived — and the
/// golden catches the covers missing, differently on each run. Waiting for
/// each one, and refusing any that failed, is what makes the capture
/// repeatable.
Future<void> _settleImages(WidgetTester tester) async {
  final failures = <Object>[];
  await tester.runAsync(() async {
    for (final element in find.byType(Image).evaluate()) {
      await precacheImage(
        (element.widget as Image).image,
        element,
        onError: (error, _) => failures.add(error),
      );
    }
  });
  if (failures.isNotEmpty) {
    throw StateError('an image never loaded: ${failures.first}');
  }
  await tester.pumpAndSettle();
}

Map<String, Uint8List> _covers(Directory fixtures) {
  final covers = <String, Uint8List>{};
  final folder = Directory('${fixtures.path}/covers');
  if (!folder.existsSync()) return covers;
  for (final file in folder.listSync().whereType<File>()) {
    covers[file.uri.pathSegments.last] = file.readAsBytesSync();
  }
  return covers;
}

/// Serves the downloaded covers to Image.network. A test cannot reach the
/// network, and the client the test binding installs in its place answers
/// every request with a transparent pixel — which would put empty frames
/// where the prayer books' covers belong.
class _CoverImages extends HttpOverrides {
  _CoverImages(this.covers);

  final Map<String, Uint8List> covers;

  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      _CoverClient(covers);
}

class _CoverClient implements HttpClient {
  _CoverClient(this.covers);

  final Map<String, Uint8List> covers;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => openUrl('GET', url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async {
    final bytes = covers[url.pathSegments.last];
    if (bytes == null) throw StateError('no cover captured for $url');
    return _CoverRequest(url, bytes);
  }

  @override
  bool autoUncompress = true;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CoverRequest implements HttpClientRequest {
  _CoverRequest(this.uri, this.bytes);

  @override
  final Uri uri;
  final Uint8List bytes;

  @override
  final HttpHeaders headers = _CoverHeaders();

  @override
  Future<HttpClientResponse> close() async => _CoverResponse(bytes);

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CoverHeaders implements HttpHeaders {
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _CoverResponse implements HttpClientResponse {
  _CoverResponse(this.bytes);

  final Uint8List bytes;

  @override
  int get statusCode => HttpStatus.ok;

  @override
  int get contentLength => bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) => Stream<List<int>>.value(bytes).listen(
    onData,
    onError: onError,
    onDone: onDone,
    cancelOnError: cancelOnError,
  );

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// The API, replaying responses captured from production.
class _CapturedApi implements LectionaryDataSource {
  _CapturedApi(this.fixtures, this.language);

  final Directory fixtures;
  final AppLanguage language;

  dynamic _read(String name) =>
      jsonDecode(File('${fixtures.path}/$name.json').readAsStringSync());

  /// A list that came back empty is a fixture fetched with the wrong query,
  /// not an empty lectionary. Left alone it renders a screenshot missing
  /// whatever that list feeds, which is the kind of thing nobody spots until
  /// it is on the store.
  List<Map<String, dynamic>> _readList(String name) {
    final payload = _read(name);
    final values = payload is Map ? payload['data'] : payload;
    final entries = (values as List)
        .whereType<Map>()
        .map((value) => Map<String, dynamic>.from(value))
        .toList();
    if (entries.isEmpty) {
      throw StateError('$name.json is empty — refetch the fixtures');
    }
    return entries;
  }

  @override
  Future<List<PrayerBook>> getPrayerBooks() async =>
      _readList('prayer_books').map(PrayerBook.fromJson).toList();

  @override
  Future<List<ReadingTypeOption>> getReadingTypeOptions(String code) async =>
      const [];

  @override
  Future<List<BibleVersion>> getBibleVersions({String? language}) async =>
      _readList('bibles-${this.language.code}')
          .map(BibleVersion.fromJson)
          .where((version) => version.code.isNotEmpty)
          .toList();

  @override
  Future<List<CalendarDay>> getCalendarMonth(
    DateTime month,
    String code, {
    String? readingType,
    String? bibleVersion,
  }) async =>
      _readList('month-${language.code}').map(CalendarDay.fromJson).toList();

  @override
  Future<LectionaryDay> getDay(
    DateTime date,
    String code, {
    String? readingType,
    String? bibleVersion,
  }) async {
    final payload = _read('day-${language.code}');
    return LectionaryDay.fromJson(Map<String, dynamic>.from(payload as Map));
  }

  @override
  void dispose() {}
}
