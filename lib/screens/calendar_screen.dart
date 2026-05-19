import 'package:flutter/material.dart';

class TaskEntry {
  final String title;
  bool isComplete;

  TaskEntry({
    required this.title,
    this.isComplete = false,
  });
}

class CalendarScreen extends StatefulWidget {
  final String username;

  const CalendarScreen({
    super.key,
    required this.username,
  });

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  DateTime currentMonth = DateTime(
    DateTime.now().year,
    DateTime.now().month,
  );

  final Map<String, List<TaskEntry>> tasks = {};

  String getDateKey(DateTime date) {
    return '${date.year}-${date.month}-${date.day}';
  }

  List<TaskEntry> get selectedTasks {
    return tasks[getDateKey(selectedDay)] ?? [];
  }

  void addTask() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('New Task'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'Task name',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final text = controller.text.trim();

                if (text.isEmpty) return;

                setState(() {
                  final key = getDateKey(selectedDay);

                  tasks.putIfAbsent(key, () => []);

                  tasks[key]!.add(
                    TaskEntry(title: text),
                  );
                });

                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  List<DateTime?> getCalendarDays() {
    final firstDay = DateTime(
      currentMonth.year,
      currentMonth.month,
      1,
    );

    final lastDay = DateTime(
      currentMonth.year,
      currentMonth.month + 1,
      0,
    );

    final days = <DateTime?>[];

    for (int i = 0; i < firstDay.weekday % 7; i++) {
      days.add(null);
    }

    for (int day = 1; day <= lastDay.day; day++) {
      days.add(
        DateTime(
          currentMonth.year,
          currentMonth.month,
          day,
        ),
      );
    }

    return days;
  }

  void previousMonth() {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month - 1,
      );
    });
  }

  void nextMonth() {
    setState(() {
      currentMonth = DateTime(
        currentMonth.year,
        currentMonth.month + 1,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final calendarDays = getCalendarDays();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addTask,
        child: const Icon(Icons.add),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Welcome, ${widget.username}!',
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: previousMonth,
                    icon: const Icon(Icons.chevron_left),
                  ),

                  Text(
                    '${currentMonth.month}/${currentMonth.year}',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  IconButton(
                    onPressed: nextMonth,
                    icon: const Icon(Icons.chevron_right),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text('Sun'),
                  Text('Mon'),
                  Text('Tue'),
                  Text('Wed'),
                  Text('Thu'),
                  Text('Fri'),
                  Text('Sat'),
                ],
              ),

              const SizedBox(height: 8),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: calendarDays.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisExtent: 42,
                  crossAxisSpacing: 2,
                  mainAxisSpacing: 2,
                ),
                itemBuilder: (context, index) {
                  final day = calendarDays[index];

                  if (day == null) {
                    return const SizedBox(height: 8);
                  }

                  final isSelected =
                      day.year == selectedDay.year &&
                      day.month == selectedDay.month &&
                      day.day == selectedDay.day;

                  final hasTasks =
                      tasks.containsKey(getDateKey(day));

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedDay = day;
                      });
                    },
                    child: Container(
                      height: 8,
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primaryContainer
                            : null,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: hasTasks
                              ? Theme.of(context)
                                .colorScheme
                                .primary
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: hasTasks
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              Text(
                'Tasks for ${selectedDay.day}/${selectedDay.month}/${selectedDay.year}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                height: 300,
                child: selectedTasks.isEmpty
                    ? const Align(
                        alignment: Alignment.topCenter,
                        child: Padding(
                          padding: EdgeInsets.only(top: 16),
                          child: Text('No tasks for this day'),
                        ),
                      )
                    : ListView.builder(
                        itemCount: selectedTasks.length,
                        itemBuilder: (context, index) {
                          final task = selectedTasks[index];

                          return Dismissible(
                            key: ValueKey('${task.title}-$index'),
                            direction: DismissDirection.horizontal,
                            background: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerLeft,
                              child: const Row(
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            secondaryBackground: Container(
                              color: Colors.red,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              alignment: Alignment.centerRight,
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Icon(
                                    Icons.delete,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                            ),
                            onDismissed: (_) {
                              setState(() {
                                selectedTasks.removeAt(index);
                              });
                            },
                            child: Card(
                              color: (task.isComplete
                                    ? Colors.lightGreenAccent
                                    : null),
                              child: CheckboxListTile(
                                activeColor: Colors.green,
                                checkColor: Colors.white,
                                title: Text(
                                  task.title,
                                ),
                                value: task.isComplete,
                                onChanged: (value) {
                                  setState(() {
                                    task.isComplete =
                                        value ?? false;
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}