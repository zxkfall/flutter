# demo

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## install package
```bash
flutter pub get
```
## add package

```bash
flutter pub add <package_name>
```

for ios 17, if can not find developer mode, need to start app use xcode, then debug mode will appear

generate test steps
```bash
// before run test, run this command: flutter pub run build_runner build --delete-conflicting-outputs
// steps:
// 1. add @GenerateMocks
// 2. run command: flutter pub run build_runner build --delete-conflicting-outputs
// 3. import 'widget_test.mocks.dart';
// 4. add mockRepository
// 5. add when(mockRepository.billings()).thenAnswer((_) async {
// 6. add await tester.pumpWidget(const MyApp());
// 7. add await tester.pump();
// 8. add expect(find.text('fake income'), findsOneWidget);
```

fix checkDebugDuplicateClasses
```
FAILURE: Build failed with an exception.

* What went wrong:
Execution failed for task ':app:checkDebugDuplicateClasses'.
> A failure occurred while executing com.android.build.gradle.internal.tasks.CheckDuplicatesRunnable
   > Duplicate class kotlin.collections.jdk8.CollectionsJDK8Kt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.internal.jdk7.JDK7PlatformImplementations found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
     Duplicate class kotlin.internal.jdk7.JDK7PlatformImplementations$ReflectSdkVersion found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
     Duplicate class kotlin.internal.jdk8.JDK8PlatformImplementations found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.internal.jdk8.JDK8PlatformImplementations$ReflectSdkVersion found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.io.path.ExperimentalPathApi found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
     Duplicate class kotlin.io.path.PathRelativizer found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
     Duplicate class kotlin.io.path.PathsKt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
     Duplicate class kotlin.io.path.PathsKt__PathReadWriteKt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
     Duplicate class kotlin.io.path.PathsKt__PathUtilsKt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
     Duplicate class kotlin.jdk7.AutoCloseableKt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk7-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.7.10)
     Duplicate class kotlin.jvm.jdk8.JvmRepeatableKt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.jvm.optionals.OptionalsKt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.random.jdk8.PlatformThreadLocalRandom found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.streams.jdk8.StreamsKt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.streams.jdk8.StreamsKt$asSequence$$inlined$Sequence$1 found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.streams.jdk8.StreamsKt$asSequence$$inlined$Sequence$2 found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.streams.jdk8.StreamsKt$asSequence$$inlined$Sequence$3 found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.streams.jdk8.StreamsKt$asSequence$$inlined$Sequence$4 found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.text.jdk8.RegexExtensionsJDK8Kt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)
     Duplicate class kotlin.time.jdk8.DurationConversionsJDK8Kt found in modules jetified-kotlin-stdlib-1.8.10 (org.jetbrains.kotlin:kotlin-stdlib:1.8.10) and jetified-kotlin-stdlib-jdk8-1.7.10 (org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.7.10)

     Go to the documentation to learn how to <a href="d.android.com/r/tools/classpath-sync-errors">Fix dependency resolution errors</a>.

```
https://github.com/fluttercommunity/plus_plugins/issues/1673
just change kotlin ext version to 1.8.10

## app can not launch when exit debugging mode in IOS platform

```bash
flutter run --release
```

will install release version


## resources
https://plus.fluttercommunity.dev/

## palette generator block ui thread
related issue:
https://github.com/flutter/flutter/issues/10647
https://github.com/flutter/flutter/issues/122788

key reason is that palette generator is using dart:ui, which is not supported in isolate

maybe has two method to solve this issue:
1. make isolate support dart:ui
2. write a package to parse image color in isolate

## show log
```bash
flutter logs
```

## fix keyboard hide
```dart
FocusScope.of(context).requestFocus(FocusNode());
```

https://stackoverflow.com/questions/44991968/how-can-i-dismiss-the-on-screen-keyboard/56946311#56946311

## replace icon
replace `assets/icons/ic_launcher.png`
run command
```bash
flutter pub run flutter_launcher_icons
```

## change app name

```bash
 flutter pub run rename_app:main all="MapleBilling"
```

don't use it, just look which file changed and change it manually


Tasks:
1. [] bottom navigation bar can click with icon and text
2. [] change theme
3. [] add global translation
4. [] add global theme
5. [] add test
6. [] use icon to replace kind icon
7. [] add feedback email
8. [] IOS app icon has black background
9. [] add query page