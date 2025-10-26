import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/event_model.dart';

class Storage {
  static File? _file;
  static List<EventModel> events = [];

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    _file = File('${dir.path}/events.json');
    if (await _file!.exists()) {
      String content = await _file!.readAsString();
      if (content.isNotEmpty) {
        List data = json.decode(content);
        events = data.map((e) => EventModel.fromMap(e)).toList();
      }
    } else {
      await _file!.create();
      await _file!.writeAsString('[]');
    }
  }

  static Future<void> save() async {
    List<Map<String, dynamic>> list = events.map((e) => e.toMap()).toList();
    await _file!.writeAsString(json.encode(list));
  }

  static Future<void> add(EventModel e) async {
    events.add(e);
    await save();
  }

  static Future<void> update(EventModel e) async {
    int i = events.indexWhere((x) => x.id == e.id);
    if (i != -1) events[i] = e;
    await save();
  }

  static Future<void> delete(String id) async {
    events.removeWhere((x) => x.id == id);
    await save();
  }
}
