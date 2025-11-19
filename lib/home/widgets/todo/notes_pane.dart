import 'dart:async';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:get_it/get_it.dart';

import '../../../resources/storage_keys.dart';
import '../../../utils/storage_manager.dart';

class NotesPane extends StatefulWidget {
  final Color color;
  const NotesPane({super.key, required this.color});

  @override
  State<NotesPane> createState() => NotesPaneState();
}

class NotesPaneState extends State<NotesPane> {
  final TextEditingController _noteController = TextEditingController();
  late final LocalStorageManager storage = GetIt.instance.get<LocalStorageManager>();

  @override
  void initState() {
    super.initState();
    _noteController.addListener(_syncImagesFromEditor);
    _loadNotes();
    if (kIsWeb) {
      html.document.onPaste.listen((event) async {
        try {} catch (_) {}
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
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color, fontWeight: FontWeight.w500),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _saveNotes();
                },
                child: Text('Save', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color.withOpacity(0.9))),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _handlePaste(),
                child: Text('Paste', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color.withOpacity(0.9))),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  _noteController.clear();
                  setState(() {});
                },
                child: Text('Clear', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color.withOpacity(0.9))),
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
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color),
                    decoration: InputDecoration(
                      hintText: 'Write or paste…',
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color.withOpacity(0.5)),
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
