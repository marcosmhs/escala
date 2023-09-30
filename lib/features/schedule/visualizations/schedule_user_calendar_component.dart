import 'package:escala/components/util/custom_return.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:escala/features/schedule/models/schedule_date.dart';
import 'package:escala/features/schedule/visualizations/schedule_date_type_list.dart';
import 'package:escala/features/user/models/user.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

enum DisplayMode { dialog, modal }

class ScheduleUsersCalendarComponent extends StatefulWidget {
  final BuildContext context;
  final List<ScheduleDate> scheduleDateList;
  final String scheduleId;
  final ScheduleStatus scheduleStatus;
  final User user;
  final Institution institution;
  final void Function(CalendarTapDetails)? onTap;
  final DateTime initialDate;

  const ScheduleUsersCalendarComponent({
    Key? key,
    required this.context,
    required this.scheduleDateList,
    required this.scheduleId,
    required this.scheduleStatus,
    required this.user,
    required this.institution,
    required this.initialDate,
    this.onTap,
  }) : super(key: key);

  @override
  State<ScheduleUsersCalendarComponent> createState() => _ScheduleUsersCalendarComponentState();
}

class _ScheduleUsersCalendarComponentState extends State<ScheduleUsersCalendarComponent> {
  List<Appointment> localScheduleDates = <Appointment>[];

  @override
  void initState() {
    super.initState();
    localScheduleDates = [];
  }

  _AppointmentDataSource _getCalendarDataSource() {
    localScheduleDates = [];
    for (var scheduleDate in widget.scheduleDateList) {
      localScheduleDates.add(Appointment(
        startTime: scheduleDate.date!,
        endTime: scheduleDate.date!,
        subject: scheduleDate.typeLabel,
        color: widget.institution.scheduleDateTypeColor(scheduleDate.type),
        isAllDay: true,
      ));
    }
    return _AppointmentDataSource(localScheduleDates);
  }

  void _addScheduleDate({required DateTime dayOffDate}) {
    showModalBottomSheet<ScheduleDateType>(
      constraints: kIsWeb
          ? BoxConstraints.tightFor(width: MediaQuery.of(context).size.width * 0.55)
          : BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 32),
      context: context,
      isDismissible: true,
      builder: (context) => ScheduleDateTypeList(institution: widget.institution),
    ).then((value) {
      if (value != null) {
        ScheduleDate scheduleDate = ScheduleDate(
          scheduleId: widget.scheduleId,
          date: dayOffDate,
          type: value,
          userIdCreation: widget.user.id,
          userId: widget.user.id,
        );

        ScheduleController(widget.user).addScheduleDate(scheduleDate: scheduleDate).then((value) {
          if (value.returnType == ReturnType.sucess) {
            setState(() => widget.scheduleDateList.add(scheduleDate));
          }
        });
      }
    });
  }

  void _removeScheduleDate({required DateTime dayOffDate}) {
    var scheduleDate = widget.scheduleDateList.singleWhere((element) => element.date == dayOffDate);
    ScheduleController(widget.user).deleteScheduleDate(scheduleDate: scheduleDate);
    setState(() {
      widget.scheduleDateList.remove(scheduleDate);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SfCalendar(
      allowDragAndDrop: false,
      onTap: widget.onTap ??
          (calendarTapDetails) {
            if (widget.scheduleStatus != ScheduleStatus.released) {
              if (calendarTapDetails.appointments != null && calendarTapDetails.appointments!.isNotEmpty) {
                _removeScheduleDate(dayOffDate: calendarTapDetails.date!);
              } else {
                _addScheduleDate(dayOffDate: calendarTapDetails.date!);
              }
            }
          },
      view: CalendarView.month,
      cellEndPadding: 0,
      initialDisplayDate: widget.initialDate,
      monthViewSettings: const MonthViewSettings(appointmentDisplayMode: MonthAppointmentDisplayMode.appointment),
      todayHighlightColor: Theme.of(context).primaryColor,
      dataSource: _getCalendarDataSource(),
    );
  }
}

class _AppointmentDataSource extends CalendarDataSource {
  _AppointmentDataSource(List<Appointment> source) {
    appointments = source;
  }
}
