/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-19 20:30:51
* @ Message: Ã°Å¸Å½Â¯ Happy coding and Have a nice day! Ã°Å¸Å’Â¤Ã¯Â¸Â
 */

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:focus/domain/entities/todo_item.dart';
import 'package:focus/presentation/home/store/background_store.dart';
import 'package:provider/provider.dart';
import 'package:focus/common/widgets/observer/custom_observer.dart';

import 'package:focus/common/widgets/input/text_input.dart';

class TodoRow extends StatefulWidget {
  final String id;
  final String text;
  final bool completed;
  final Color color;
  final bool startEditing;

  const TodoRow({super.key, required this.id, required this.text, required this.completed, required this.color, this.startEditing = false});

  @override
  State<TodoRow> createState() => TodoRowState();
}

class TodoRowState extends State<TodoRow> {
  late bool editing = widget.startEditing;
  late TextEditingController controller = TextEditingController(text: widget.text);
  final TextEditingController timeController = TextEditingController();
  bool _isAm = true;

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    final task = store.todoTasks.firstWhereOrNull((e) => e.id == widget.id) ?? TodoItem(id: widget.id, text: widget.text, completed: widget.completed);
    if ((task.remindTime ?? '').isNotEmpty && timeController.text != task.remindTime) {
      timeController.text = task.remindTime!;
    }
    Color? bg;
    if (task.completed) {
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
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.color),
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
                          task.text,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: widget.color,
                            decoration: task.completed ? TextDecoration.lineThrough : TextDecoration.none,
                          ),
                        ),
                      ),
            ),
            const SizedBox(width: 12),
            Checkbox(
              value: task.completed,
              onChanged: (v) {
                store.toggleTodo(widget.id, v ?? false);
                setState(() {});
              },
              side: BorderSide(color: widget.color.withOpacity(0.5)),
              fillColor: MaterialStateProperty.resolveWith((states) => widget.color.withOpacity(0.2)),
              checkColor: Colors.black,
            ),
            const SizedBox(width: 6),
            IgnorePointer(
              ignoring: task.completed,
              child: CustomObserver(
                name: 'TodoRowTimeInput',
                builder: (context) {
                  final use24h = context.read<BackgroundStore>().use24HourTodo;
                  return SizedBox(
                    width: 84,
                    child: TextInput(
                      controller: timeController,
                      inputFormatters: [MaskedInputFormatter('00:00')],
                      hintText: use24h ? 'todo.timeHint24'.tr() : 'todo.timeHint12'.tr(),
                      textAlign: TextAlign.center,
                      showInitialBorder: false,
                      fillColor: ((task.remindTime ?? '').isNotEmpty) ? widget.color.withOpacity(0.12) : null,
                      textStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color),
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color.withOpacity(0.6)),
                      suffix:
                          !use24h
                              ? GestureDetector(
                                onTap: () => setState(() => _isAm = !_isAm),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Text(
                                    _isAm ? 'AM' : 'PM',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color.withOpacity(0.8)),
                                  ),
                                ),
                              )
                              : null,
                      onSubmitted: (value) async {
                        final v = value.trim();
                        final parts = v.split(':');
                        final int? h = parts.length == 2 ? int.tryParse(parts[0]) : null;
                        final int? m = parts.length == 2 ? int.tryParse(parts[1]) : null;
                        if (h == null || m == null) return false;
                        String toStore;
                        if (use24h) {
                          toStore = '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
                        } else {
                          if (h < 1 || h > 12) return false;
                          if (m < 0 || m > 59) return false;
                          final int h24 = (h % 12) + (_isAm ? 0 : 12);
                          toStore = '${h24.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
                        }
                        store.setTodoRemindTime(widget.id, toStore);
                        store.scheduleTaskReminderFromTime(widget.id);
                        setState(() {});
                        return true;
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 6),
            InkWell(
              onTap: () {
                store.removeTodo(widget.id);
                setState(() {});
              },
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
