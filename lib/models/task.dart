import '../common/categories.dart';

class Task {
  final String title;
  final bool isDone;
  final Categories category;

  Task({required this.title, required this.isDone, required this.category});
  factory Task.fromJson(Map<String, dynamic> jsonString) {
    return Task(
      title: jsonString['title'],
      category: jsonString['category'] == 'Business'
          ? Categories.Business
          : Categories.Personal,
      isDone: jsonString['done'],
    );
  }
}
