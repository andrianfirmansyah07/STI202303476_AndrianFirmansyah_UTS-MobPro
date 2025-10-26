class EventModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String date;
  final String time;
  final String? imagePath;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.date,
    required this.time,
    this.imagePath,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category,
        'date': date,
        'time': time,
        'imagePath': imagePath,
      };

  factory EventModel.fromMap(Map<String, dynamic> map) => EventModel(
        id: map['id'],
        title: map['title'],
        description: map['description'],
        category: map['category'],
        date: map['date'],
        time: map['time'],
        imagePath: map['imagePath'],
      );
}
