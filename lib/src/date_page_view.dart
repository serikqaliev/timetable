import 'package:flutter/material.dart';
import 'package:time_machine/time_machine.dart';

import 'controller.dart';

typedef DateWidgetBuilder = Widget Function(
    BuildContext context, LocalDate date);

class DatePageView extends StatefulWidget {
  const DatePageView({
    Key key,
    @required this.controller,
    @required this.builder,
  })  : assert(controller != null),
        assert(builder != null),
        super(key: key);

  final TimetableController controller;
  final DateWidgetBuilder builder;

  @override
  _DatePageViewState createState() => _DatePageViewState();
}

class _DatePageViewState extends State<DatePageView> {
  ScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller.scrollControllers.addAndGet();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scrollable(
      axisDirection: AxisDirection.right,
      physics: TimetableScrollPhysics(widget.controller),
      controller: _controller,
      viewportBuilder: (context, position) {
        return Viewport(
          // TODO(JonasWanke): anchor
          axisDirection: AxisDirection.right,
          offset: position,
          slivers: <Widget>[
            SliverFillViewport(
              viewportFraction: 1 / widget.controller.visibleDays,
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    widget.builder(context, LocalDate.fromEpochDay(index)),
              ),
            ),
          ],
        );
      },
    );
  }
}