/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-19 20:30:51
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:focus/presentation/home/store/background_store.dart';
import 'package:focus/presentation/home/widgets/todo_widget/legend_pane.dart';
import 'package:focus/presentation/home/widgets/todo_widget/notes_pane.dart';
import 'package:focus/presentation/home/widgets/todo_widget/todo_row.dart';
import 'package:focus/common/widgets/observer/custom_observer.dart';

class TodoWidget extends StatefulWidget {
  const TodoWidget({super.key});

  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  final TextEditingController _newController = TextEditingController();
  bool _showCompleted = false;

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    return CustomObserver(
      name: 'TodoWidget',
      builder: (context) {
        final color = store.foregroundColor;
        final bool isDarkTodo = store.isTodoMode && store.todoDarkMode;
        final Color borderBase = isDarkTodo ? Theme.of(context).colorScheme.primary : color;
        return LayoutBuilder(
          builder: (context, constraints) {
            final double total = constraints.maxWidth;
            final double leftWidth = total * 4 / 12;
            final double middleWidth = total * 6 / 12;
            final double rightWidth = total * 2 / 12;
            return Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      SizedBox(
                        height: constraints.maxHeight,
                        width: leftWidth,
                        child: NotesPane(color: color),
                      ),

                      SizedBox(
                        height: constraints.maxHeight,
                        width: middleWidth,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: TextField(
                                      controller: _newController,
                                      onSubmitted: (v) {
                                        final lines = v.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                                        if (lines.isEmpty) return;
                                        if (lines.length == 1) {
                                          store.addTodo(lines.first);
                                        } else {
                                          store.addTodos(lines);
                                        }
                                        _newController.clear();
                                        setState(() {});
                                      },
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color),
                                      decoration: InputDecoration(
                                        hintText: 'todo.addTask'.tr(),
                                        hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(color: color.withOpacity(0.5)),
                                        contentPadding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 12,
                                        ),
                                        filled: true,
                                        fillColor: Colors.black.withOpacity(0.1),
                                        border: OutlineInputBorder(
                                          borderSide: BorderSide(color: borderBase.withOpacity(0.15)),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: borderBase.withOpacity(0.15)),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderSide: BorderSide(color: borderBase.withOpacity(0.4)),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: () {
                                      final lines = _newController.text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
                                      if (lines.isEmpty) return;
                                      if (lines.length == 1) {
                                        store.addTodo(lines.first);
                                      } else {
                                        store.addTodos(lines);
                                      }
                                      _newController.clear();
                                      setState(() {});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                      decoration: BoxDecoration(
                                        color: color.withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Icon(Icons.add_rounded, color: color),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton(
                                    onPressed: () => setState(() => _showCompleted = !_showCompleted),
                                    child: Text(
                                      _showCompleted ? 'todo.showActive'.tr() : 'todo.showCompleted'.tr(),
                                      style: TextStyle(color: color.withOpacity(0.9)),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    onPressed: () {
                                      store.clearAllTodos();
                                    },
                                    child: Text(
                                      'todo.clearAllTasks'.tr(),
                                      style: TextStyle(color: color.withOpacity(0.9)),
                                    ),
                                  ),

                                  CustomObserver(
                                    name: 'TodoCompletedCount',
                                    builder: (context) {
                                      final completedCount = store.todoTasks.where((t) => t.completed).length;
                                      return Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: color.withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          '$completedCount',
                                          style: TextStyle(color: color.withOpacity(0.9)),
                                        ),
                                      );
                                    },
                                  ),
                                  const SizedBox(width: 8),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Expanded(
                                child: CustomObserver(
                                  name: 'TodoListScrollable',
                                  builder: (context) {
                                    final items = _showCompleted ? store.todoTasks.where((e) => e.completed).toList() : store.todoTasks.where((e) => !e.completed).toList();
                                    return ListView.builder(
                                      padding: EdgeInsets.zero,
                                      itemCount: items.length,
                                      itemBuilder: (context, index) {
                                        final item = items[index];
                                        return DragTarget<int>(
                                          onWillAccept: (from) => from != null && from != index,
                                          onAccept: (from) {
                                            final fromId = items[from].id;
                                            final toId = items[index].id;
                                            final oldIndex = store.todoTasks.indexWhere((e) => e.id == fromId);
                                            final newIndex = store.todoTasks.indexWhere((e) => e.id == toId);
                                            store.reorderTodo(oldIndex, newIndex);
                                          },
                                          builder: (context, candidateData, rejectedData) {
                                            return LongPressDraggable<int>(
                                              data: index,
                                              dragAnchorStrategy: childDragAnchorStrategy,
                                              feedback: Material(
                                                type: MaterialType.transparency,
                                                child: Container(
                                                  width: 600,
                                                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Text(
                                                          item.text,
                                                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                            color: color,
                                                            decoration: item.completed ? TextDecoration.lineThrough : TextDecoration.none,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      SizedBox(
                                                        width: 84,
                                                        child: DecoratedBox(
                                                          decoration: BoxDecoration(
                                                            color: (item.remindTime ?? '').isNotEmpty ? color.withOpacity(0.12) : Colors.transparent,
                                                            borderRadius: BorderRadius.circular(4),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              (item.remindTime ?? '').isNotEmpty
                                                                  ? item.remindTime!
                                                                  : (context.read<BackgroundStore>().use24HourTodo ? 'todo.timeHint24'.tr() : 'todo.timeHint12'.tr()),
                                                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color.withOpacity(0.8)),
                                                              textAlign: TextAlign.center,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 6),
                                                      Icon(Icons.delete_outline_rounded, color: color.withOpacity(0.8)),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              childWhenDragging: Opacity(
                                                opacity: 0.4,
                                                child: TodoRow(
                                                  key: ValueKey('${item.id}-drag'),
                                                  id: item.id,
                                                  text: item.text,
                                                  completed: item.completed,
                                                  color: color,
                                                  startEditing: false,
                                                ),
                                              ),
                                              child: TodoRow(
                                                key: ValueKey(item.id),
                                                id: item.id,
                                                text: item.text,
                                                completed: item.completed,
                                                color: color,
                                                startEditing: item.text.isEmpty,
                                              ),
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: constraints.maxHeight,
                    width: rightWidth,
                    child: LegendPane(color: color),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _newController.dispose();
    super.dispose();
  }
}
