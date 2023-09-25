import 'package:escala/components/util/util.dart';
import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/schedule/schedule_controller.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages

class ScheduleDateUserList extends StatefulWidget {
  final List<ScheduleDateUser> scheduleDateUser;
  final Institution institution;

  const ScheduleDateUserList({Key? key, required this.scheduleDateUser, required, required this.institution}) : super(key: key);

  @override
  State<ScheduleDateUserList> createState() => _ScheduleDateUserListState();
}

class _ScheduleDateUserListState extends State<ScheduleDateUserList> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Escala do dia ${Util.dateTimeFormat(date: widget.scheduleDateUser.first.scheduleDates.first.date!)} ',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          if (widget.scheduleDateUser.isNotEmpty)
            SizedBox(
              height: 300,
              child: ListView.builder(
                itemCount: widget.scheduleDateUser.length,
                itemBuilder: (ctx, index) => Card(
                  child: ListTile(
                    visualDensity: const VisualDensity(horizontal: 0, vertical: -4),
                    leading: Icon(Icons.person,
                        size: 40,
                        color: widget.institution.scheduleDateTypeColor(
                          widget.scheduleDateUser[index].scheduleDates.first.type,
                        )),
                    title: Text(widget.scheduleDateUser[index].user.name),
                    subtitle: Text(widget.scheduleDateUser[index].scheduleDates.first.typeLabel),
                  ),
                ),
              ),
            )
        ],
      ),
    );
  }
}
