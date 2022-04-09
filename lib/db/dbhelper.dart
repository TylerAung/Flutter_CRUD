import 'package:crud_sqlflite_tutorial/model/notes.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

//https://www.youtube.com/watch?v=UpKrhZ0Hppk
//https://github.com/JohannesMilke/sqflite_database_example

class NotesDatabase {
  static final NotesDatabase instance = NotesDatabase._init();
  static Database? _database; //Comes from sqflite package
  NotesDatabase._init();

  //Open connection to Db
  Future<Database> get database async{
    if(_database != null) return _database!;  //If db exist, return current db

    _database = await _initDB('todos.db'); //else if not, create new db
    return _database!; //Return db for user later
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath(); //Get current db path
    //Can configure above to store the db on the seperate file path
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB); //Create db according to file path and name it according to name input in constructor method, then return Db
    //openDatabase(path, version: 2, onCreate: _createDB , onUpgrade:); //Incrementing version and adding onUpgrade allows database schema to be updated when want to add new fields or so
  }

  //Database with Schema
  //_createDB is only executed when todos.db does not exist in the filesystem
  Future _createDB(Database db, int version) async{
    //Initializing type for fields in db table
    final idType = 'INTEGER PRIMARY KEY AUTOINCREMENT'; //For Primary Key SQL
    final textType = 'TEXT NOT NULL';
    final boolType = 'BOOLEAN NOT NULL';
    final integerType = 'INTEGER NOT NULL';

    //${NoteFields}  accessed via class
    await db.execute(
      '''
      CREATE TABLE $tableNotes(
        ${NoteFields.id} $idType,
        ${NoteFields.isImportant} $boolType,
        ${NoteFields.number} $integerType,
        ${NoteFields.title} $textType,
        ${NoteFields.description} $textType,
        ${NoteFields.time} $textType
      )
      '''
    ); //Creating table and defining table schema
  }

  Future<Note> create(Note note) async {
    //Gets reference to database
    final db = await instance.database;

    //Next 8 lines of code can be reduce to just, which is writing in query syntax --> final id = await db.insert(tableNotes, note.toJson());
    // final json = note.toJson();
    // final columns =
    //     '${NoteFields.title}, ${NoteFields.description}, ${NoteFields.time}';
    // final values =
    //     '${json[NoteFields.title]}, ${json[NoteFields.description]}, ${json[NoteFields.time]}';
    // final id = await db
    //     .rawInsert('INSERT INTO table_name ($columns) VALUES ($values)');

    //db.insert(table, values) table = name of table to put, values = data to put inside
    final id = await db.insert(tableNotes, note.toJson()); //insert to db after convert to json object
    //after inserting data, db a unique auto generate id value;
    return note.copy(id: id); //create current note object then only modify the id
  }

  Future<Note> readNote(int id) async{ //Single note
    final db = await instance.database;

    final maps = await db.query(
        tableNotes, //Put in all the tables that you want to query
        columns: NoteFields.values,
        where: '${NoteFields.id} = ?',
        whereArgs: [id], //Helps prevent SQL injection, more secure approach
    );

    if(maps.isNotEmpty){
      return Note.fromJSON(maps.first);
    }
    else{
      throw Exception('ID ${id} not found');
    }
  }

  //Get collection of notes
  Future<List<Note>> readAllNotes() async {

    final db = await instance.database;

    final orderBy = '${NoteFields.time} ASC'; //ASC = sort ascending
    // final result =
    //     await db.rawQuery('SELECT * FROM $tableNotes ORDER BY $orderBy'); SQL syntax

    final res = await db.query(tableNotes, orderBy: orderBy); //Call all the object since we want all rather than individual row

    return res.map((json) =>  Note.fromJSON(json)).toList();
  }

  //Update statement
  Future<int> update(Note note) async {
    final db = await instance.database;
    return db.update(
        tableNotes,
        note.toJson(),
        where: '${NoteFields.id} = ?',
        whereArgs: [note.id],
    );
  }

  //Delete
  Future<int> delete(int id) async {
    final db = await instance.database;
    return await db.delete(
      tableNotes,
      where: '${NoteFields.id} = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database; //get current database
    db.close(); //close connection with current db
  }
}