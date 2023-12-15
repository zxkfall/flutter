import 'package:decimal/decimal.dart';
import 'package:maple_billing/model/billing.dart';
import 'package:maple_billing/repository/billing_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('PathProvider full implementation', () {
    setUpAll(() {
      PathProviderPlatform.instance = FakePathProviderPlatform();
      sqfliteFfiInit();
      databaseFactory = databaseFactoryFfi;
    });

    test('Test billings method', () async {
      final repository = SqlBillingRepository();
      await repository.clearBilling();
      var billing1 = Billing(
        id: 1,
        type: BillingType.expense,
        amount: Decimal.parse('100.00'),
        date: DateTime.now(),
        description: 'test',
        kind: BillingKind.fruit,
      );
      var billing2 = Billing(
        id: 2,
        type: BillingType.income,
        amount: Decimal.parse('200.00'),
        date: DateTime.now(),
        description: 'test2',
        kind: BillingKind.fruit,
      );
      await repository.batchInsertBilling([
        billing1,
        billing2,
      ]);
      final billings = await repository.billings();
      expect(billings.length, 2);
      assertBilling(billings[0], billing1);
      assertBilling(billings[1], billing2);
    });

    test('Test billing method', () async {
      final repository = SqlBillingRepository();
      await repository.clearBilling();
      var billing = Billing(
        id: 1,
        type: BillingType.expense,
        amount: Decimal.parse('100.00'),
        date: DateTime.now(),
        description: 'test',
        kind: BillingKind.fruit,
      );
      await repository.insertBilling(billing);
      final res = await repository.billing(1);
      assertBilling(res, billing);
    });

    test('Test insert method', () async {
      final repository = SqlBillingRepository();
      await repository.clearBilling();
      var billing = Billing(
        id: 1,
        type: BillingType.expense,
        amount: Decimal.parse('100.00'),
        date: DateTime.now(),
        description: 'test',
        kind: BillingKind.fruit,
      );
      await repository.insertBilling(billing);
      final res = await repository.billing(1);
      assertBilling(res, billing);
    });

    test('Test update method', () async {
      final repository = SqlBillingRepository();
      await repository.clearBilling();
      var billing = Billing(
        id: 1,
        type: BillingType.expense,
        amount: Decimal.parse('100.00'),
        date: DateTime.now(),
        description: 'test',
        kind: BillingKind.fruit,
      );
      await repository.insertBilling(billing);
      var updateBilling = Billing(
        id: 1,
        type: BillingType.income,
        amount: Decimal.parse('200.00'),
        date: DateTime.now(),
        description: 'test2',
        kind: BillingKind.fruit,
      );
      await repository.updateBilling(updateBilling);
      final res = await repository.billing(1);
      assertBilling(res, updateBilling);
    });

    test('Test delete method', () async {
      final repository = SqlBillingRepository();
      await repository.clearBilling();
      var billing = Billing(
        id: 1,
        type: BillingType.expense,
        amount: Decimal.parse('100.00'),
        date: DateTime.now(),
        description: 'test',
        kind: BillingKind.fruit,
      );
      await repository.insertBilling(billing);
      await repository.deleteBilling(1);
      final res = await repository.billings();
      expect(res.length, 0);
    });

    test('Test clear method', () async {
      final repository = SqlBillingRepository();
      await repository.clearBilling();
      var billing = Billing(
        id: 1,
        type: BillingType.expense,
        amount: Decimal.parse('100.00'),
        date: DateTime.now(),
        description: 'test',
        kind: BillingKind.fruit,
      );
      await repository.insertBilling(billing);
      await repository.clearBilling();
      final res = await repository.billings();
      expect(res.length, 0);
    });
  });
}

void assertBilling(Billing res, Billing expectBilling) {
  expect(res.id, expectBilling.id);
  expect(res.type, expectBilling.type);
  expect(res.amount, expectBilling.amount);
  expect(res.date, expectBilling.date);
  expect(res.description, expectBilling.description);
  expect(res.kind, expectBilling.kind);
}

const String kTemporaryPath = 'temporaryPath';
const String kApplicationSupportPath = 'applicationSupportPath';
const String kDownloadsPath = 'downloadsPath';
const String kLibraryPath = 'libraryPath';
const String kApplicationDocumentsPath = 'applicationDocumentsPath';
const String kExternalCachePath = 'externalCachePath';
const String kExternalStoragePath = 'externalStoragePath';

class FakePathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return kTemporaryPath;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return kApplicationSupportPath;
  }

  @override
  Future<String?> getLibraryPath() async {
    return kLibraryPath;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return kApplicationDocumentsPath;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return kExternalStoragePath;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return <String>[kExternalCachePath];
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return <String>[kExternalStoragePath];
  }

  @override
  Future<String?> getDownloadsPath() async {
    return kDownloadsPath;
  }
}

class AllNullFakePathProviderPlatform extends Fake with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getTemporaryPath() async {
    return null;
  }

  @override
  Future<String?> getApplicationSupportPath() async {
    return null;
  }

  @override
  Future<String?> getLibraryPath() async {
    return null;
  }

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return null;
  }

  @override
  Future<String?> getExternalStoragePath() async {
    return null;
  }

  @override
  Future<List<String>?> getExternalCachePaths() async {
    return null;
  }

  @override
  Future<List<String>?> getExternalStoragePaths({
    StorageDirectory? type,
  }) async {
    return null;
  }

  @override
  Future<String?> getDownloadsPath() async {
    return null;
  }
}
