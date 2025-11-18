import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../utils/custom_observer.dart';
import '../background_store.dart';

class TodoWidget extends StatefulWidget {
  const TodoWidget({super.key});

  @override
  State<TodoWidget> createState() => _TodoWidgetState();
}

class _TodoWidgetState extends State<TodoWidget> {
  final TextEditingController _newController = TextEditingController();

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
            constraints: const BoxConstraints(maxWidth: 600),
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
                            final t = v.trim();
                            if (t.isEmpty) return;
                            store.addTodo(t);
                            _newController.clear();
                          },
                          style: TextStyle(color: color, fontSize: 18),
                          decoration: InputDecoration(
                            hintText: 'Add a task',
                            hintStyle: TextStyle(color: color.withOpacity(0.5)),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
                          final t = _newController.text.trim();
                          if (t.isEmpty) return;
                          store.addTodo(t);
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
                  const SizedBox(height: 20),
                  for (final item in store.todoTasks)
                    _TodoRow(
                      key: ValueKey(item.id),
                      id: item.id,
                      text: item.text,
                      completed: item.completed,
                      color: color,
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

  const _TodoRow({super.key, required this.id, required this.text, required this.completed, required this.color});

  @override
  State<_TodoRow> createState() => _TodoRowState();
}

class _TodoRowState extends State<_TodoRow> {
  late bool editing = false;
  late TextEditingController controller = TextEditingController(text: widget.text);

  @override
  Widget build(BuildContext context) {
    final store = context.read<BackgroundStore>();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
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
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
