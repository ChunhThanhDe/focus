/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-21 09:36:52
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:json_annotation/json_annotation.dart';

part 'todo_item.g.dart';

@JsonSerializable()
class TodoItem {
  final String id;
  final String text;
  final bool completed;
  final String? remindTime;
  final String? remindDate; // Format: "yyyy-MM-dd"

  const TodoItem({
    required this.id,
    required this.text,
    this.completed = false,
    this.remindTime,
    this.remindDate,
  });

  TodoItem copyWith({
    String? id,
    String? text,
    bool? completed,
    String? remindTime,
    String? remindDate,
  }) {
    return TodoItem(
      id: id ?? this.id,
      text: text ?? this.text,
      completed: completed ?? this.completed,
      remindTime: remindTime ?? this.remindTime,
      remindDate: remindDate ?? this.remindDate,
    );
  }

  factory TodoItem.fromJson(Map<String, dynamic> json) => _$TodoItemFromJson(json);
  Map<String, dynamic> toJson() => _$TodoItemToJson(this);
}
