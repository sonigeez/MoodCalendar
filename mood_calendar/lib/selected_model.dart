import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class SelectedModel {
  String selectedEmoji;
  DateTime day;
  SelectedModel({
    required this.selectedEmoji,
    required this.day,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'selectedEmoji': selectedEmoji,
      'day': day.toString(),
    };
  }

  factory SelectedModel.fromMap(Map<String, dynamic> map) {
    return SelectedModel(
      selectedEmoji: map['selectedEmoji'] as String,
      day: DateTime.parse(map['day']),
    );
  }

  String toJson() => json.encode(toMap());

  factory SelectedModel.fromJson(String source) =>
      SelectedModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
