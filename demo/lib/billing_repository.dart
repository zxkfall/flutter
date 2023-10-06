import 'package:sqflite/sqflite.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:synchronized/synchronized.dart'; // 导入 synchronized 包

import 'billing.dart';

class BillingRepository {
  Database? _db;
  final _lock = Lock(); // 创建一个锁

  BillingRepository() {
    WidgetsFlutterBinding.ensureInitialized();
  }

  Future<Database?> _initDatabase() async {
    if (_db == null) {
      await _lock.synchronized(() async {
        _db ??= await openDatabase(
          join(await getDatabasesPath(), 'billing_database.db'),
          onCreate: (db, version) {
            return db.execute(
              'CREATE TABLE Billing (id INTEGER PRIMARY KEY, type INTEGER, amount INTEGER, date TEXT, description TEXT, payment TEXT)',
            );
          },
          version: 1,
        );
      });
    }
    return _db;
  }

  Future<Database> get db async {
    final database = await _initDatabase();
    if (database != null) {
      return database;
    } else {
      // 返回一个默认的 Database 对象，或者抛出异常
      throw Exception('Database initialization failed');
    }
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
