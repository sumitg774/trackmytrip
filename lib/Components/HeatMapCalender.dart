import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_heatmap_calendar/flutter_heatmap_calendar.dart';


import '../Utils/AppColorTheme.dart';

class HeatMapCalendarWidget extends StatefulWidget {
  final Map<DateTime, int?> dateTimeMap;
  final Function(DateTime date, int count)? onDateSelected;
  final double size;
  final bool flexible;// Optional callback
  final bool showCalender;


  HeatMapCalendarWidget({
    Key? key,
    required this.dateTimeMap,
    required this.showCalender,
    this.onDateSelected,
    this.flexible = true,
    this.size = 42// Optional parameter
  }) : super(key: key);

  @override
  State<HeatMapCalendarWidget> createState() => _HeatMapCalendarWidgetState();
}

class _HeatMapCalendarWidgetState extends State<HeatMapCalendarWidget> {
  @override
  Widget build(BuildContext context) {
    // Ensure that the dataset has no null values
    final filteredMap = widget.dateTimeMap.map((key, value) => MapEntry(key, value ?? 0));
    return HeatMapCalendar(

      defaultColor: AppColors.customWhite,
      size: widget.size,
      flexible: widget.flexible,
      showColorTip: false,
      monthFontSize: 20,
      weekFontSize: 14,
      textColor: Colors.black,
      weekTextColor: AppColors.customBgPrimary,
      colorMode: ColorMode.color,
      datasets: filteredMap,
      colorsets: {
        for (int i = 1; i <= 100; i++) i: AppColors.customGreen,
      },

      onClick: widget.onDateSelected != null
          ? (date) {
        final count = filteredMap[date] ?? 0;
        widget.onDateSelected!(date, count);
      }
          : null,
    );
  }
}
