import 'package:flutter/material.dart';

import '../../controller/controller.dart';
import '../../extension/extension.dart';
import '../../typedef/typedef.dart';
import '../scope/scope.dart';
import '../widget.dart';

/// A Timetable widget that displays [MonthWidget]s in a page view.
///
/// When a [DateControllerScope] is placed above in the widget tree, the
/// visible month is synced to it and swiping between months also updates that
/// [DateController].
class CompactMonthTimetable extends StatefulWidget {
  CompactMonthTimetable({
    MonthWidgetBuilder? monthBuilder,
  }) : monthBuilder = monthBuilder ?? ((context, month) => MonthWidget(month));

  final MonthWidgetBuilder monthBuilder;

  @override
  State<CompactMonthTimetable> createState() => _CompactMonthTimetableState();
}

class _CompactMonthTimetableState extends State<CompactMonthTimetable> with TickerProviderStateMixin {
  DateController? dateController;
  late final MonthPageController _monthPageController;

  @override
  void initState() {
    super.initState();

    _monthPageController = MonthPageController(
      initialMonth: dateController?.date.value.firstDayOfMonth ?? DateTimeTimetable.currentMonth(),
    );
    _monthPageController.addListener(_onMonthPageControllerChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    dateController?.date.removeListener(_onDateControllerChanged);
    dateController = DateControllerScope.of(context);
    dateController?.date.addListener(_onDateControllerChanged);
  }

  @override
  void dispose() {
    dateController?.date.removeListener(_onDateControllerChanged);
    _monthPageController.removeListener(_onMonthPageControllerChanged);
    _monthPageController.dispose();
    super.dispose();
  }

  int _dateControllerDriverCount = 0;
  int _monthPageControllerDriverCount = 0;
  Future<void> _onDateControllerChanged() async {
    if (_dateControllerDriverCount > 0) return;
    final dateControllerMonth = dateController!.date.value.firstDayOfMonth;
    if (dateControllerMonth == _monthPageController.value) return;

    _monthPageControllerDriverCount++;
    await _monthPageController.animateTo(dateControllerMonth);
    _monthPageControllerDriverCount--;
  }

  Future<void> _onMonthPageControllerChanged() async {
    if (_monthPageControllerDriverCount > 0) return;

    _dateControllerDriverCount++;
    await dateController?.animateTo(_monthPageController.value, vsync: this);
    _dateControllerDriverCount--;
  }

  @override
  Widget build(BuildContext context) {
    return MonthPageView(
      monthPageController: _monthPageController,
      shrinkWrapInCrossAxis: true,
      builder: widget.monthBuilder,
    );
  }
}
