import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:flutter/foundation.dart' show kIsWeb;
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';
import 'package:get_it/get_it.dart';
import '../../utils/storage_manager.dart';
import '../../resources/storage_keys.dart';

import '../../utils/custom_observer.dart';
import '../background_store.dart';
import '../../ui/text_input.dart';
import 'package:screwdriver/screwdriver.dart';

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
                        child: _NotesPane(color: color),
                      ),

                      SizedBox(
                        height: constraints.maxHeight,
                        width: middleWidth,
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
                                        setState(() {});
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
                              CustomObserver(
                                name: 'TodoList',
                                builder: (context) {
                                  final items = _showCompleted
                                      ? store.todoTasks.where((e) => e.completed).toList()
                                      : store.todoTasks.where((e) => !e.completed).toList();
                                  final completedCount = store.todoTasks.where((t) => t.completed).length;
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          TextButton(
                                            onPressed: () => setState(() => _showCompleted = !_showCompleted),
                                            child: Text(
                                              _showCompleted ? 'Show active' : 'Show completed',
                                              style: TextStyle(color: color.withOpacity(0.9)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          TextButton(
                                            onPressed: () {
                                              store.clearAllTodos();
                                            },
                                            child: Text(
                                              'Clear all tasks',
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
                                              '$completedCount',
                                              style: TextStyle(color: color.withOpacity(0.9)),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                        ],
                                      ),
                                      const SizedBox(height: 20),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
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
                                  );
                                },
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
                    child: _LegendPane(color: color),
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
  bool _isAm = true;

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    final task = store.todoTasks.firstWhereOrNull((e) => e.id == widget.id) ?? TodoTask(id: widget.id, text: widget.text, completed: widget.completed);
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
                          task.text,
                          style: TextStyle(
                            color: widget.color,
                            fontSize: 18,
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
                      hintText: use24h ? 'HH:MM' : 'hh:mm',
                      textAlign: TextAlign.center,
                      showInitialBorder: false,
                      fillColor: ((task.remindTime ?? '').isNotEmpty) ? widget.color.withOpacity(0.12) : null,
                      textStyle: TextStyle(color: widget.color),
                      hintStyle: TextStyle(color: widget.color.withOpacity(0.6)),
                      suffix:
                          !use24h
                              ? GestureDetector(
                                onTap: () => setState(() => _isAm = !_isAm),
                                child: Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: Text(_isAm ? 'AM' : 'PM', style: TextStyle(color: widget.color.withOpacity(0.8))),
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

class _NotesPane extends StatefulWidget {
  final Color color;
  const _NotesPane({required this.color});

  @override
  State<_NotesPane> createState() => _NotesPaneState();
}

class _NotesPaneState extends State<_NotesPane> {
  final TextEditingController _noteController = TextEditingController();
  late final LocalStorageManager storage = GetIt.instance.get<LocalStorageManager>();

  @override
  void initState() {
    super.initState();
    _noteController.addListener(_syncImagesFromEditor);
    _loadNotes();
    if (kIsWeb) {
      html.document.onPaste.listen((event) async {
        try {
          // no auto-save on paste
        } catch (_) {}
      });
      html.document.onKeyDown.listen((e) async {
        try {
          final key = e.key?.toLowerCase() ?? '';
          if ((e.ctrlKey || e.metaKey) && key == 's') {
            e.preventDefault();
            await _saveNotes();
          }
        } catch (_) {}
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: widget.color.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Notes',
                  style: TextStyle(color: widget.color, fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _saveNotes();
                },
                child: Text('Save', style: TextStyle(color: widget.color.withOpacity(0.9))),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _handlePaste(),
                child: Text('Paste', style: TextStyle(color: widget.color.withOpacity(0.9))),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  _noteController.clear();
                  setState(() {});
                },
                child: Text('Clear', style: TextStyle(color: widget.color.withOpacity(0.9))),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _noteController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    minLines: 24,
                    style: TextStyle(color: widget.color),
                    decoration: InputDecoration(
                      hintText: 'Write or paste…',
                      hintStyle: TextStyle(color: widget.color.withOpacity(0.5)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      filled: true,
                      fillColor: Colors.black.withOpacity(0.06),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: widget.color.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: widget.color.withOpacity(0.15)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: widget.color.withOpacity(0.4)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _noteController.removeListener(_syncImagesFromEditor);
    _noteController.dispose();
    super.dispose();
  }

  void _syncImagesFromEditor() {
    setState(() {});
  }

  // no image URL parsing for Notes

  Future<void> _handlePaste() async {
    try {
      if (kIsWeb) {
        final text = await html.window.navigator.clipboard?.readText();
        if (text != null && text.trim().isNotEmpty) {
          final cur = _noteController.text;
          _noteController.text = cur.isEmpty ? text : '$cur\n$text';
        }
      } else {
        final data = await Clipboard.getData('text/plain');
        final txt = data?.text ?? '';
        if (txt.trim().isNotEmpty) {
          final cur = _noteController.text;
          _noteController.text = cur.isEmpty ? txt : '$cur\n$txt';
        }
      }
    } catch (_) {}
    if (_noteController.text.trim().isEmpty) {
      final data = await Clipboard.getData('text/plain');
      final txt = data?.text ?? '';
      if (txt.trim().isNotEmpty) {
        final cur = _noteController.text;
        _noteController.text = cur.isEmpty ? txt : '$cur\n$txt';
      }
    }
    _syncImagesFromEditor();
    setState(() {});
  }

  Future<void> _loadNotes() async {
    try {
      final data = await storage.getJson(StorageKeys.todoNotes);
      if (data == null) return;
      final text = (data['text'] as String?) ?? '';
      _noteController.text = text;
      setState(() {});
    } catch (_) {}
  }

  Future<void> _saveNotes() async {
    try {
      final payload = {
        'text': _noteController.text,
      };
      await storage.setJson(StorageKeys.todoNotes, payload);
    } catch (_) {}
  }
}

class _NoteBlock {
  final String id;
  final _NoteType type;
  final String? content;
  final Uint8List? bytes;
  _NoteBlock(this.id, this.type, [this.content, this.bytes]);
}

enum _NoteType { text, image }

class _LegendPane extends StatelessWidget {
  final Color color;
  const _LegendPane({super.key, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Legend', style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.red.withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(child: Text('Red: due in < 10 minutes', style: TextStyle(color: color.withOpacity(0.9)))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.yellow.withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(child: Text('Yellow: due in < 60 minutes', style: TextStyle(color: color.withOpacity(0.9)))),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(width: 14, height: 14, decoration: BoxDecoration(color: Colors.green.withOpacity(0.5), borderRadius: BorderRadius.circular(3))),
              const SizedBox(width: 8),
              Expanded(child: Text('Green: completed', style: TextStyle(color: color.withOpacity(0.9)))),
            ],
          ),
        ],
      ),
    );
  }
}
