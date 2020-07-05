class HistoryItem {
   int id;
   String name;
   String url;
   String filePath="-";

   static const String TABLE_NAME = "history_table";
   static const String COLUMN_ID = "_id";
   static const String COLUMN_NAME = "name";
   static const String COLUMN_URL = "url";
   static const String COLUMN_FILE = "file";

   HistoryItem(this.name, this.url){
      filePath="-";
   }

   HistoryItem.fromMap(Map<String, dynamic> map) {
      id = map[COLUMN_ID];
      name = map[COLUMN_NAME];
      url = map[COLUMN_URL];
      filePath = map[COLUMN_FILE];
   }


   Map<String, dynamic> toMap() {
      Map<String, dynamic> map= {
         COLUMN_NAME: name,
         COLUMN_URL: url,
         COLUMN_FILE: filePath,
      };
      if(id!=null)
         map[COLUMN_ID]=id;
      return map;
   }
}