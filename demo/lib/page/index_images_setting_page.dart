import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import '../utils/utils.dart';

class IndexImagesSettingPage extends StatefulWidget {
  const IndexImagesSettingPage({super.key});

  @override
  State<IndexImagesSettingPage> createState() => _IndexImagesSettingPageState();
}

class _IndexImagesSettingPageState extends State<IndexImagesSettingPage> {
  var focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  @override
  Widget build(BuildContext context) {
    FToast fToast = FToast();
    fToast.init(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
      body: ListView(
        children: [
          ..._urlTags.map((element) {
            return TextButton(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: element));
                Utils.showToast('复制成功', fToast);
              },
              onLongPress: () {
                _urlTags.remove(element);
                _saveUrls();
                setState(() {});
              },
              child: Text(element),
            );
          }),
          TextField(
            focusNode: focusNode,
            controller: _textController,
            maxLines: 1,
            decoration: InputDecoration(
              labelText: 'Enter Text',
              border: const OutlineInputBorder(),
              suffixIcon: IconButton(
                icon: Icon(
                    _isKeyboardVisible ? Icons.keyboard_hide : Icons.keyboard),
                onPressed: () {
                  setState(() {
                    _isKeyboardVisible = !_isKeyboardVisible;
                    if (_isKeyboardVisible) {
                      FocusManager.instance.primaryFocus?.unfocus();
                    } else {
                      FocusManager.instance.primaryFocus
                          ?.requestFocus(focusNode);
                    }
                  });
                },
              ),
            ),
            onSubmitted: (value) {
              autoFocus = true;
              if (value.trim() == '') {
                return;
              }
              _urlTags.add(value);
              _textController.text = '';
              _saveUrls();
              setState(() {});
            },
            autofocus: autoFocus,
          )
        ],
      ),
    );
  }

  var autoFocus = false;
  List<String> _urlTags = [];
  final TextEditingController _textController = TextEditingController();
  bool _isKeyboardVisible = false;

  Future<void> _loadText() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/saved_text.txt');
      if (file.existsSync()) {
        setState(() {
          _urlTags = file
              .readAsStringSync()
              .trim()
              .split(';')
              .where((element) => element != '')
              .toList();
        });
      }
    } catch (e) {
      log('Failed to load text: $e');
    }
  }

  Future<void> _saveUrls() async {
    final text = _urlTags.join(';');
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/saved_text.txt');
      await file.writeAsString(text);
    } catch (e) {
      log('Failed to save text: $e');
    }
  }
}
