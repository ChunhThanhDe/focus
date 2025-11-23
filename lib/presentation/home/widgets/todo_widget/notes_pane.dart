/*
 * @ Author: Chung Nguyen Thanh <chunhthanhde.dev@gmail.com>
 * @ Created: 2025-08-19 20:30:51
 * @ Message: 🎯 Happy coding and Have a nice day! 🌤️
 */

import 'dart:async';

// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/services.dart' hide TextInput;
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:focus/presentation/home/store/background_store.dart';

import 'package:focus/core/constants/storage_keys.dart';
import 'package:focus/data/sources/storage/local_storage_manager.dart';

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
    final store = context.read<BackgroundStore>();
    final bool isDarkTodo = store.isTodoMode && store.todoDarkMode;
    final Color borderBase = isDarkTodo ? Theme.of(context).colorScheme.primary : widget.color;
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderBase.withOpacity(0.15)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              SizedBox(width: 4),
              Expanded(
                child: Text(
                  'todo.notes'.tr(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.color, fontWeight: FontWeight.bold),
                ),
              ),
              TextButton(
                onPressed: () async {
                  await _saveNotes();
                },
                child: Text('todo.save'.tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.color.withOpacity(0.9), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () => _handlePaste(),
                child: Text('todo.paste'.tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.color.withOpacity(0.9), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: () {
                  _noteController.clear();
                  setState(() {});
                },
                child: Text('todo.clear'.tr(), style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: widget.color.withOpacity(0.9), fontWeight: FontWeight.bold)),
              ),
              SizedBox(width: 4),
            ],
          ),
          const SizedBox(height: 8),
          Expanded(
            child: TextField(
              controller: _noteController,
              keyboardType: TextInputType.multiline,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color),
              decoration: InputDecoration(
                hintText: 'todo.writeOrPaste'.tr(),
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: widget.color.withOpacity(0.5)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                filled: true,
                fillColor: Colors.black.withOpacity(0.06),
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: borderBase),
                  borderRadius: BorderRadius.circular(8),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderBase),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: borderBase),
                  borderRadius: BorderRadius.circular(8),
                ),
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
