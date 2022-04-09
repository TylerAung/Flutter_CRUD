final String tableNotes = 'notes'; //Name of table we'll be creating later

class NoteFields{

  static final List<String> values = [
    id, isImportant, number, title, description, time
  ];

  static final String id = '_id';
  static final String isImportant = 'isImportant';
  static final String number = 'number';
  static final String title = 'title';
  static final String description = 'description';
  static final String time = 'time';
}

class Note {

  final int? id;
  final bool isImportant;
  final int number;
  final String title;
  final String description;
  final DateTime createdTime;

  const Note({
    this.id,
    required this.isImportant,
    required this.number,
    required this.title,
    required this.description,
    required this.createdTime
  });

  //To assist in JSON conversion
  //Map of key value
  Map<String, Object?> toJson() => {
    //For standard string & number, just straightaway parse
    NoteFields.id: id,
    NoteFields.title: title,
    NoteFields.number: number,
    NoteFields.description: description,
    //for bool & datetime, need to convert them first
    NoteFields.isImportant : isImportant ? 1 : 0, //Done this way because that's what SQL database understands
    NoteFields.time: createdTime.toIso8601String() //Convert to string obj
  };

  //Creating a copy of current note object, then pass in all the values which we wants to modify
  Note copy({
    int? id,
    bool? isImportant,
    int? number,
    String? title,
    String? description,
    DateTime? createdTime
  })  =>
      Note (

        id: id?? this.id,
        isImportant: isImportant ?? this.isImportant,
        number: number ?? this.number,
        title: title ?? this.title,
        description: description ?? this.description,
        createdTime: createdTime ?? this.createdTime,
  );

  static Note fromJSON(Map<String, Object?> json) => Note(
      id: json[NoteFields.id] as int?,
      number: json[NoteFields.number] as int,
      title: json[NoteFields.title] as String,
      description: json[NoteFields.description] as String,
      createdTime: DateTime.parse(json[NoteFields.time] as String), // convert to datetime then parse back to string due to schema strucuture of id
      isImportant: json[NoteFields.isImportant] == 1,
  );
}