import 'package:elajtech/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class WorkingHoursSelector extends StatefulWidget {
  const WorkingHoursSelector({
    required this.initialWorkingHours,
    required this.onSave,
    super.key,
  });
  final Map<String, List<String>> initialWorkingHours;
  final void Function(Map<String, List<String>>) onSave;

  @override
  State<WorkingHoursSelector> createState() => _WorkingHoursSelectorState();
}

class _WorkingHoursSelectorState extends State<WorkingHoursSelector> {
  late Map<String, List<String>> _workingHours;
  final List<String> _weekDays = [
    'الأحد',
    'الاثنين',
    'الثلاثاء',
    'الأربعاء',
    'الخميس',
    'الجمعة',
    'السبت',
  ];

  @override
  void initState() {
    super.initState();
    _workingHours = Map.from(widget.initialWorkingHours);
  }

  Future<void> _selectTime(
    String day,
    bool isStartTime,
    String currentTime,
  ) async {
    final timeParts = currentTime.split(':');
    final initialTime = TimeOfDay(
      hour: int.parse(timeParts[0]),
      minute: int.parse(timeParts[1]),
    );

    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
          ),
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        final formattedTime =
            '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
        final currentTimes = _workingHours[day]!;
        if (isStartTime) {
          _workingHours[day] = [formattedTime, currentTimes[1]];
        } else {
          _workingHours[day] = [currentTimes[0], formattedTime];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'تحديد أوقات العمل',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView.builder(
            itemCount: _weekDays.length,
            itemBuilder: (context, index) {
              final day = _weekDays[index];
              final isSelected = _workingHours.containsKey(day);

              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        title: Text(
                          day,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: isSelected,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value ?? false) {
                              _workingHours[day] = ['09:00', '17:00'];
                            } else {
                              _workingHours.remove(day);
                            }
                          });
                        },
                        activeColor: AppColors.primary,
                      ),
                      if (isSelected)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: _TimeButton(
                                  label: 'من',
                                  time: _workingHours[day]![0],
                                  onTap: () => _selectTime(
                                    day,
                                    true,
                                    _workingHours[day]![0],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _TimeButton(
                                  label: 'إلى',
                                  time: _workingHours[day]![1],
                                  onTap: () => _selectTime(
                                    day,
                                    false,
                                    _workingHours[day]![1],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () => widget.onSave(_workingHours),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('حفظ التغييرات'),
        ),
      ],
    ),
  );
}

class _TimeButton extends StatelessWidget {
  const _TimeButton({
    required this.label,
    required this.time,
    required this.onTap,
  });
  final String label;
  final String time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(8),
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            time,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    ),
  );
}
