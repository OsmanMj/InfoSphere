import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // استيراد الحزمة
import 'note_detail_page.dart';

class NotesPage extends StatefulWidget {
  @override
  _NotesPageState createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  List<Map<String, String>> _notes = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  int? _editingIndex;
  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  void _loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String>? storedNotes = prefs.getStringList('notes');

    if (storedNotes != null) {
      setState(() {
        _notes = storedNotes.map((note) {
          final noteParts = note.split('###');
          return {
            'title': noteParts[0],
            'content': noteParts[1],
          };
        }).toList();
      });
    }
  }

  void _saveNotes() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> notesToSave =
        _notes.map((note) => '${note['title']}###${note['content']}').toList();
    await prefs.setStringList('notes', notesToSave);
  }

  void _addOrUpdateNote() {
    if (_titleController.text.isNotEmpty &&
        _contentController.text.isNotEmpty) {
      setState(() {
        if (_editingIndex != null) {
          _notes[_editingIndex!] = {
            'title': _titleController.text,
            'content': _contentController.text,
          };
          _editingIndex = null;
        } else {
          _notes.add({
            'title': _titleController.text,
            'content': _contentController.text,
          });
        }
        _saveNotes();
        _titleController.clear();
        _contentController.clear();
      });
    }
  }

  void _removeNote(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Silmek istediğinize emin misiniz?'),
          content:
              Text('Bu notu favorilerden silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'iptal',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _notes.removeAt(index);
                });
                _saveNotes();
                Navigator.of(context).pop();
              },
              child: Text(
                'Sil',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void _editNote(int index) {
    setState(() {
      _titleController.text = _notes[index]['title']!;
      _contentController.text = _notes[index]['content']!;
      _editingIndex = index;

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('düzenlem istediğinize emin misiniz?'),
            content: Text('Bu notu düzenlemek istediğinizden emin misiniz?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  'iptal',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {});
                  _saveNotes();
                  Navigator.of(context).pop();
                },
                child: Text(
                  'düzenle',
                  style: TextStyle(color: Colors.lightBlue),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  void _viewNoteDetail(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailPage(
          title: _notes[index]['title']!,
          content: _notes[index]['content']!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Not',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Başlık',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: InputDecoration(
                labelText: 'İçerik',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomLeft,
              child: ElevatedButton(
                onPressed: _addOrUpdateNote,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _editingIndex == null ? Icons.add : Icons.edit,
                      color: Colors.white,
                    ),
                    SizedBox(width: 1),
                    Text(
                      _editingIndex == null ? 'Notu Ekle' : 'Notu düzenle',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrangeAccent,
                ),
              ),
            ),
            SizedBox(height: 10),
            Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: _notes.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () => _viewNoteDetail(index),
                    child: Card(
                      elevation: 3,
                      margin: EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        title: Text(_notes[index]['title']!),
                        subtitle: Text(_notes[index]['content']!),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editNote(index),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _removeNote(index),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
