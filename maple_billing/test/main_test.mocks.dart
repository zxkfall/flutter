// Mocks generated by Mockito 5.4.2 from annotations
// in maple_billing/test/main_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:maple_billing/model/billing.dart' as _i2;
import 'package:maple_billing/repository/billing_repository.dart' as _i3;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeBilling_0 extends _i1.SmartFake implements _i2.Billing {
  _FakeBilling_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [BillingRepository].
///
/// See the documentation for Mockito's code generation for more information.
class MockBillingRepository extends _i1.Mock implements _i3.BillingRepository {
  @override
  _i4.Future<int> insertBilling(_i2.Billing? billing) => (super.noSuchMethod(
        Invocation.method(
          #insertBilling,
          [billing],
        ),
        returnValue: _i4.Future<int>.value(0),
        returnValueForMissingStub: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);

  @override
  _i4.Future<void> batchInsertBilling(List<_i2.Billing>? billings) =>
      (super.noSuchMethod(
        Invocation.method(
          #batchInsertBilling,
          [billings],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<void> deleteBilling(int? id) => (super.noSuchMethod(
        Invocation.method(
          #deleteBilling,
          [id],
        ),
        returnValue: _i4.Future<void>.value(),
        returnValueForMissingStub: _i4.Future<void>.value(),
      ) as _i4.Future<void>);

  @override
  _i4.Future<int> clearBilling() => (super.noSuchMethod(
        Invocation.method(
          #clearBilling,
          [],
        ),
        returnValue: _i4.Future<int>.value(0),
        returnValueForMissingStub: _i4.Future<int>.value(0),
      ) as _i4.Future<int>);

  @override
  _i4.Future<_i2.Billing> updateBilling(_i2.Billing? billing) =>
      (super.noSuchMethod(
        Invocation.method(
          #updateBilling,
          [billing],
        ),
        returnValue: _i4.Future<_i2.Billing>.value(_FakeBilling_0(
          this,
          Invocation.method(
            #updateBilling,
            [billing],
          ),
        )),
        returnValueForMissingStub: _i4.Future<_i2.Billing>.value(_FakeBilling_0(
          this,
          Invocation.method(
            #updateBilling,
            [billing],
          ),
        )),
      ) as _i4.Future<_i2.Billing>);

  @override
  _i4.Future<_i2.Billing> billing(int? id) => (super.noSuchMethod(
        Invocation.method(
          #billing,
          [id],
        ),
        returnValue: _i4.Future<_i2.Billing>.value(_FakeBilling_0(
          this,
          Invocation.method(
            #billing,
            [id],
          ),
        )),
        returnValueForMissingStub: _i4.Future<_i2.Billing>.value(_FakeBilling_0(
          this,
          Invocation.method(
            #billing,
            [id],
          ),
        )),
      ) as _i4.Future<_i2.Billing>);

  @override
  _i4.Future<List<_i2.Billing>> billings() => (super.noSuchMethod(
        Invocation.method(
          #billings,
          [],
        ),
        returnValue: _i4.Future<List<_i2.Billing>>.value(<_i2.Billing>[]),
        returnValueForMissingStub:
            _i4.Future<List<_i2.Billing>>.value(<_i2.Billing>[]),
      ) as _i4.Future<List<_i2.Billing>>);
}
