import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart'; // 导入 synchronized 包

import 'billing.dart';

class BillingRepository {
  late final Database _db;
  bool _isDbInitialized = false;
  final _lock = Lock(); // 创建一个锁

  BillingRepository() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  Future<void> initDatabase() async {
    if (!_isDbInitialized) {
      // 使用锁来确保只有一个线程可以执行以下代码块
      await _lock.synchronized(() async {
        if (!_isDbInitialized) {
          _db = await openDatabase(
            join(await getDatabasesPath(), 'billing_database.db'),
            onCreate: (db, version) {
              return db.execute(
                'CREATE TABLE Billing (id INTEGER PRIMARY KEY, type INTEGER, amount INTEGER, date TEXT, description TEXT, payment TEXT)',
              );
            },
            version: 1,
          );
          _isDbInitialized = true;
        }
      });
    }
  }

  Future<Database> get db async {
    await initDatabase(); // 在调用 get db 时初始化
    return _db;
  }

  Future<void> insertBilling(Billing billing) async {
    (await db).insert(
      'Billing',
      billing.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Billing> updateBilling(Billing billing) async {
    (await db).update(
      'Billing',
      billing.toMap(),
      where: 'id = ?',
      whereArgs: [billing.id],
    );
    return billing;
  }

  Future<void> deleteBilling(int id) async {
    (await db).delete(
      'Billing',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Billing> billing(int id) async {
    final List<Map<String, dynamic>> maps = await (await db).query(
      'Billing',
      where: 'id = ?',
      whereArgs: [id],
    );
    return Billing(
      id: maps[0]['id'],
      type: maps[0]['type'] == 0 ? BillingType.income : BillingType.expense,
      amount: maps[0]['amount'],
      date: DateTime.parse(maps[0]['date']),
      description: maps[0]['description'],
      payment: maps[0]['payment'],
    );
  }

  Future<List<Billing>> billings() async {
    final List<Map<String, dynamic>> maps = await (await db).query('Billing');
    return List.generate(maps.length, (i) {
      return Billing(
        id: maps[i]['id'],
        type: maps[i]['type'] == 0 ? BillingType.income : BillingType.expense,
        amount: maps[i]['amount'],
        date: DateTime.parse(maps[i]['date']),
        description: maps[i]['description'],
        payment: maps[i]['payment'],
      );
    });
  }
}
