import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

import '../../utils/custom_observer.dart';
import '../background_store.dart';
import '../../ui/text_input.dart';

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
    final color = store.foregroundColor;
    return CustomObserver(
      name: 'TodoWidget',
      builder: (context) {
        return Align(
          alignment: Alignment.center,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
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
                          },
                          style: TextStyle(color: color, fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'Add a task',
                            hintStyle: TextStyle(color: color.withOpacity(0.5)),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            filled: true,
                            fillColor: Colors.black.withOpacity(0.1),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(color: color.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: color.withOpacity(0.15)),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: color.withOpacity(0.4)),
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
                          'Show all completed',
                          style: TextStyle(color: color.withOpacity(0.9)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => store.clearCompletedTodos(),
                        child: Text(
                          'Clear completed',
                          style: TextStyle(color: color.withOpacity(0.9)),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${store.todoTasks.where((t) => t.completed).length}',
                          style: TextStyle(color: color.withOpacity(0.9)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: (_showCompleted ? store.todoTasks : store.todoTasks.where((e) => !e.completed).toList()).length,
                    itemBuilder: (context, index) {
                      final items = _showCompleted ? store.todoTasks : store.todoTasks.where((e) => !e.completed).toList();
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
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.text,
                                        style: TextStyle(
                                          color: color,
                                          fontSize: 18,
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
                                            (item.remindTime ?? '').isNotEmpty ? item.remindTime! : 'HH:MM',
                                            style: TextStyle(color: color.withOpacity(0.8), fontSize: 14),
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
                              child: _TodoRow(key: ValueKey('${item.id}-drag'), id: item.id, text: item.text, completed: item.completed, color: color, startEditing: false),
                            ),
                            child: _TodoRow(
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
                  ),
                ],
              ),
            ),
          ),
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

class _TodoRow extends StatefulWidget {
  final String id;
  final String text;
  final bool completed;
  final Color color;
  final bool startEditing;

  const _TodoRow({
    super.key,
    required this.id,
    required this.text,
    required this.completed,
    required this.color,
    this.startEditing = false,
  });

  @override
  State<_TodoRow> createState() => _TodoRowState();
}

class _TodoRowState extends State<_TodoRow> {
  late bool editing = widget.startEditing;
  late TextEditingController controller = TextEditingController(text: widget.text);
  final TextEditingController timeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    final task = store.todoTasks.firstWhere((e) => e.id == widget.id);
    if ((task.remindTime ?? '').isNotEmpty && timeController.text != task.remindTime) {
      timeController.text = task.remindTime!;
    }
    Color? bg;
    if (widget.completed) {
      bg = Colors.green.withOpacity(0.5);
    } else {
      final s = task.remindTime ?? '';
      if (s.isNotEmpty) {
        final parts = s.split(':');
        final int? h = int.tryParse(parts[0]);
        final int? m = int.tryParse(parts[1]);
        if (h != null && m != null) {
          final now = DateTime.now();
          var candidate = DateTime(now.year, now.month, now.day, h, m);
          if (!candidate.isAfter(now)) candidate = candidate.add(const Duration(days: 1));
          final minutes = candidate.difference(now).inMinutes;
          if (minutes < 10) {
            bg = Colors.red.withOpacity(0.5);
          } else if (minutes < 60) {
            bg = Colors.yellow.withOpacity(0.5);
          }
        }
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Container(
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Expanded(
              child:
                  editing
                      ? TextField(
                        controller: controller,
                        onSubmitted: (v) {
                          store.updateTodoText(widget.id, v);
                          setState(() => editing = false);
                        },
                        style: TextStyle(color: widget.color, fontSize: 18),
                        decoration: InputDecoration(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                          filled: true,
                          fillColor: Colors.black.withOpacity(0.06),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(color: widget.color.withOpacity(0.15)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: widget.color.withOpacity(0.15)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: widget.color.withOpacity(0.4)),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      )
                      : GestureDetector(
                        onDoubleTap: () => setState(() => editing = true),
                        child: Text(
                          widget.text,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 18,
                            decoration: widget.completed ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                      ),
            ),
            const SizedBox(width: 12),
            Checkbox(
              value: widget.completed,
              onChanged: (v) => store.toggleTodo(widget.id, v ?? false),
              side: BorderSide(color: widget.color.withOpacity(0.5)),
              fillColor: MaterialStateProperty.resolveWith((states) => widget.color.withOpacity(0.2)),
              checkColor: Colors.black,
            ),
            const SizedBox(width: 6),
            IgnorePointer(
              ignoring: widget.completed,
              child: SizedBox(
                width: 84,
                child: TextInput(
                  controller: timeController,
                  inputFormatters: [MaskedInputFormatter('00:00')],
                  hintText: 'HH:MM',
                  textAlign: TextAlign.center,
                  showInitialBorder: false,
                  fillColor: ((task.remindTime ?? '').isNotEmpty) ? widget.color.withOpacity(0.12) : null,
                  textStyle: TextStyle(color: widget.color),
                  hintStyle: TextStyle(color: widget.color.withOpacity(0.6)),
                  onSubmitted: (value) async {
                    final v = value.trim();
                    final parts = v.split(':');
                    final valid = parts.length == 2 && int.tryParse(parts[0]) != null && int.tryParse(parts[1]) != null;
                    if (!valid) return false;
                    store.setTodoRemindTime(widget.id, v);
                    store.scheduleTaskReminderFromTime(widget.id);
                    return true;
                  },
                ),
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () => store.removeTodo(widget.id),
              child: Icon(Icons.delete_outline_rounded, color: widget.color.withOpacity(0.8)),
            ),
            const SizedBox(width: 12),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    timeController.dispose();
    super.dispose();
  }
}
