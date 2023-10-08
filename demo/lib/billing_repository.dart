import 'dart:developer';

import 'package:decimal/decimal.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart'; // 导入 synchronized 包

import 'billing.dart';

abstract class BillingRepository {

  Future<void> insertBilling(Billing billing);

  Future<void> deleteBilling(int id);

  Future<Billing> updateBilling(Billing billing);

  Future<Billing> billing(int id);

  Future<List<Billing>> billings();
}

class SqlBillingRepository implements BillingRepository {
  Database? _db;
  final _lock = Lock(); // 创建一个锁

  SqlBillingRepository() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  Future<Database?> _initDatabase() async {
    if (_db == null) {
      await _lock.synchronized(() async {
        _db ??= await openDatabase(
          join(await getDatabasesPath(), 'billing_database.db'),
          onCreate: (db, version) {
            return db.execute(
              'CREATE TABLE Billing (id INTEGER PRIMARY KEY, type INTEGER, amount INTEGER, date TEXT, description TEXT, kind INTEGER)',
            );
          },
          onUpgrade: (db, oldVersion, newVersion) async {
            if (oldVersion < 2) {
              // 1. 重命名现有的表
              await db.execute('ALTER TABLE Billing RENAME TO BillingTemp');

              // 2. 创建新的表，包含 kind 列
              await db.execute(
                'CREATE TABLE Billing (id INTEGER PRIMARY KEY, type INTEGER, amount TEXT, date TEXT, description TEXT, kind INTEGER)',
              );

              // 3. 将数据从临时表复制到新表
              await db.execute(
                'INSERT INTO Billing (id, type, amount, date, description, kind) SELECT id, type, amount, date, description, CAST(kind AS INTEGER) FROM BillingTemp',
              );

              // 4. 删除临时表
              await db.execute('DROP TABLE BillingTemp');
            }
          },
          version: 2, // 增加数据库版本号
        );
      });
    }

    return _db;
  }

  Future<Database> get _session async {
    final database = await _initDatabase();
    if (database != null) {
      return database;
    } else {
      // 返回一个默认的 Database 对象，或者抛出异常
      throw Exception('Database initialization failed');
    }
  }

  @override
  Future<void> insertBilling(Billing billing) async {
    (await _session).insert(
      'Billing',
      billing.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<Billing> updateBilling(Billing billing) async {
    (await _session).update(
      'Billing',
      billing.toMap(),
      where: 'id = ?',
      whereArgs: [billing.id],
    );
    return billing;
  }

  @override
  Future<void> deleteBilling(int id) async {
    (await _session).delete(
      'Billing',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<Billing> billing(int id) async {
    final List<Map<String, dynamic>> maps = await (await _session).query(
      'Billing',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Billing(
      id: maps[0]['id'],
      type: maps[0]['type'] == 0 ? BillingType.income : BillingType.expense,
      amount: Decimal.parse(maps[0]['amount'].toString()),
      date: DateTime.parse(maps[0]['date']),
      description: maps[0]['description'],
      kind:  maps[0]['kind'] >= 0 && maps[0]['kind'] < BillingKind.values.length
          ? BillingKind.values[maps[0]['kind']]
          : BillingKind.other,
    );
  }

  @override
  Future<List<Billing>> billings() async {
    final List<Map<String, dynamic>> maps = await (await _session).query('Billing');
    return List.generate(maps.length, (i) {
      log('${maps[i]['kind']} ${BillingKind.values[maps[i]['kind']]}');
      return Billing(
        id: maps[i]['id'],
        type: maps[i]['type'] == 0 ? BillingType.income : BillingType.expense,
        amount: Decimal.parse(maps[i]['amount'].toString()),
        date: DateTime.parse(maps[i]['date']),
        description: maps[i]['description'],
        kind: maps[i]['kind'] >= 0 && maps[i]['kind'] < BillingKind.values.length
            ? BillingKind.values[maps[i]['kind']]
            : BillingKind.other,
      );
    });
  }
}
