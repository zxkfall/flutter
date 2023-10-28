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