import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:escala/features/schedule/models/schedule.dart';
import 'package:escala/features/schedule/visualizations/schedule_user_calendar_component.dart';
import 'package:flutter/material.dart';

enum DisplayMode { dialog, modal }

class ScheduleUsersComponent extends StatefulWidget {
  final BuildContext context;
  final List<ScheduleDateUser> scheduleDateUsers;
  final String scheduleId;
  final ScheduleStatus scheduleStatus;
  final Institution institution;
  final DateTime initialDate;

  const ScheduleUsersComponent({
    Key? key,
    required this.context,
    required this.scheduleDateUsers,
    required this.scheduleId,
    required this.scheduleStatus,
    required this.institution,
    required this.initialDate,
  }) : super(key: key);

  @override
  State<ScheduleUsersComponent> createState() => _ScheduleUsersComponentState();
}

class _ScheduleUsersComponentState extends State<ScheduleUsersComponent> {
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    widget.scheduleDateUsers.sort((a, b) => a.user.name.compareTo(b.user.name));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: widget.scheduleDateUsers.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ExpansionTile(
                  initiallyExpanded: true,
                  title: Text(widget.scheduleDateUsers[index].user.name, style: Theme.of(context).textTheme.headlineSmall),
                  subtitle: Text('Folgas: ${widget.scheduleDateUsers[index].scheduleDates.length}'),
                  childrenPadding: const EdgeInsets.only(bottom: 10),
                  children: [
                    ScheduleUsersCalendarComponent(
                      context: context,
                      institution: widget.institution,
                      scheduleDateList: widget.scheduleDateUsers[index].scheduleDates,
                      scheduleId: widget.scheduleId,
                      scheduleStatus: widget.scheduleStatus,
                      user: widget.scheduleDateUsers[index].user,
                      initialDate: widget.initialDate,
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
