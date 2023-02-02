import 'dart:async';

import 'package:flutter/material.dart';
import 'package:localstore/localstore.dart';
import 'package:mood_calendar/selected_model.dart';
import 'package:mood_calendar/services/notification_service.dart';
import 'package:table_calendar/table_calendar.dart';

import 'utils.dart';

class MoodCalendar extends StatefulWidget {
  const MoodCalendar({super.key});

  @override
  MoodCalendarState createState() => MoodCalendarState();
}

class MoodCalendarState extends State<MoodCalendar> {
  final db = Localstore.instance;
  NotificationService notificationService = NotificationService();

  Future<void> onCreate() async {
    await notificationService.showNotification(
      0,
      "_textEditingController.text",
      "A new event has been created.",
    );
  }

  // Using a `Set` is recommended due to equality comparison override
  final Set<DateTime> _selectedDays = {};

  String? selectedEmoji;

  final List<String> emojis = [
    "😃",
    "🙂",
    "😐",
    "😔",
    "😫",
    "😭",
    "🥲",
    "😑",
    "😡",
    "🥱"
  ];
  Map selectedEmojis = {};

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();

  Future<void> _onDaySelected(DateTime selectedDay, DateTime focusedDay) async {
    if (selectedEmoji != null) {
      // Datbase entries
      final id = db.collection('selectedDateModel').doc().id;
      db.collection('selectedDateModel').doc(id).set(
          SelectedModel(selectedEmoji: selectedEmoji!, day: focusedDay)
              .toMap());
      setState(() {
        _focusedDay = focusedDay;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Mood Calendar'),
        ),
        body: FutureBuilder(
            future: db.collection('selectedDateModel').get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                var listMap = snapshot.data;
                var list2 = listMap!.entries
                    .map(
                      (e) => SelectedModel.fromMap(e.value),
                    )
                    .toList();
                for (var element in list2) {
                  _selectedDays.add(element.day);
                  selectedEmojis
                      .addAll({"${element.day}": element.selectedEmoji});
                }
              }

              return Column(
                children: [
                  TableCalendar<Event>(
                    calendarBuilders: CalendarBuilders(
                      selectedBuilder: (context, day, focusedDay) {
                        var showEmoji = selectedEmojis['$day'];
                        return Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: const Color(0xff9BA7E0).withOpacity(0.4),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 4, horizontal: 8),
                          child: Column(
                            children: [
                              Text(day.day.toString()),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(showEmoji),
                            ],
                          ),
                        );
                      },
                    ),
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,
                    calendarFormat: _calendarFormat,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    selectedDayPredicate: (day) {
                      // Use values from Set to mark multiple days as selected
                      return _selectedDays.contains(day);
                    },
                    onDaySelected: _onDaySelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    "Choose Emojis",
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GridView.count(
                      crossAxisSpacing: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 4,
                      children: [
                        for (int i = 0; i < emojis.length; i++)
                          InkWell(
                            borderRadius: BorderRadius.circular(10),
                            onTap: () => setState(() {
                              selectedEmoji = emojis[i];
                            }),
                            child: Container(
                              decoration: BoxDecoration(
                                color: selectedEmoji == emojis[i]
                                    ? Colors.white24
                                    : null,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  emojis[i],
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                          )
                      ],
                    ),
                  )
                ],
              );
            }));
  }
}
