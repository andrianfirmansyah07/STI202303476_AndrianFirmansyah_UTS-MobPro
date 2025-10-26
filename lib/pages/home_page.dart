import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final ImagePicker _picker = ImagePicker();
  List<Map<String, dynamic>> _events = [];

  @override
  void initState() {
    super.initState();
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/events.json');
    if (await file.exists()) {
      final content = await file.readAsString();
      setState(() {
        _events = List<Map<String, dynamic>>.from(jsonDecode(content));
      });
    }
  }

  Future<void> _saveEvents() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/events.json');
    await file.writeAsString(jsonEncode(_events));
  }

  Future<void> _addEvent() async {
    final titleController = TextEditingController();
    final descController = TextEditingController();
    XFile? image;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Tambah Event"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Nama Event'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Deskripsi'),
              ),
              const SizedBox(height: 8),
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Ambil Foto"),
                onPressed: () async {
                  image = await _picker.pickImage(source: ImageSource.camera);
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () {
              if (titleController.text.isNotEmpty) {
                setState(() {
                  _events.add({
                    "title": titleController.text,
                    "desc": descController.text,
                    "image": image?.path
                  });
                });
                _saveEvents();
              }
              Navigator.pop(context);
            },
            child: const Text("Simpan"),
          ),
        ],
      ),
    );
  }

  void _deleteEvent(int index) async {
    setState(() {
      _events.removeAt(index);
    });
    _saveEvents();
  }

  Widget _buildEventList() {
    if (_events.isEmpty) {
      return const Center(child: Text("Belum ada event tersimpan."));
    }

    return ListView.builder(
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: event["image"] != null
                ? Image.file(File(event["image"]),
                    width: 50, height: 50, fit: BoxFit.cover)
                : const Icon(Icons.event),
            title: Text(event["title"]),
            subtitle: Text(event["desc"] ?? ''),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () => _deleteEvent(index),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaGallery() {
    final photos =
        _events.where((e) => e["image"] != null && e["image"] != "").toList();

    if (photos.isEmpty) {
      return const Center(child: Text("Belum ada foto event."));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemCount: photos.length,
      itemBuilder: (context, index) {
        final event = photos[index];
        return GestureDetector(
          onTap: () {
            showDialog(
              context: context,
              builder: (context) => Dialog(
                child: Image.file(File(event["image"])),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.hardEdge,
            child: Image.file(
              File(event["image"]),
              fit: BoxFit.cover,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [_buildEventList(), _buildMediaGallery()];

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Event Planner"),
      ),
      body: pages[_selectedIndex],
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _addEvent,
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.event_note),
            label: "Daftar Event",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.photo_library),
            label: "Media",
          ),
        ],
      ),
    );
  }
}
