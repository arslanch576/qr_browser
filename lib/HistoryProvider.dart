import 'package:sqflite/sqflite.dart';

import 'HistoryItem.dart';

class HistoryProvider{

   Database db;
   
   String createHistoryItemsTableQuery=
   '''create table ${HistoryItem.TABLE_NAME}(
   ${HistoryItem.COLUMN_ID} integer primary key autoincrement,
   ${HistoryItem.COLUMN_NAME} text,
   ${HistoryItem.COLUMN_URL} text,
   ${HistoryItem.COLUMN_FILE} text
   )''';
   
   Future<HistoryProvider> open() async {
      String path = await getDatabasesPath();
      path=path+ "history_db.db";
      db= await openDatabase(path, version: 3, onCreate: (Database db, int version){
         db.execute(createHistoryItemsTableQuery);
      });
      return this;
   }
   
   Future<HistoryItem> insert(HistoryItem historyItem) async {
      historyItem.id=await db.insert(HistoryItem.TABLE_NAME, historyItem.toMap());
      return historyItem;
   }
   
   Future<void> update(HistoryItem historyItem) async {
      await db.update(HistoryItem.TABLE_NAME, historyItem.toMap(), where: '${HistoryItem.COLUMN_ID}= ?', whereArgs: [historyItem.id]);
   }
   
   Future<void> delete(HistoryItem historyItem) async {
      await db.delete(HistoryItem.TABLE_NAME, where: '${HistoryItem.COLUMN_ID}=?', whereArgs: [historyItem.id]);
   }
   
   Future<List<HistoryItem>> getAllHistoryItems() async {
      List<Map> rows = await db.query(HistoryItem.TABLE_NAME);
      return rows.map((Map row)=>HistoryItem.fromMap(row)).toList();
   }
   
   

}