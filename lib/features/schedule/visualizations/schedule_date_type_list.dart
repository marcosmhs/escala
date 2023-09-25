import 'package:escala/features/institution/institution.dart';
import 'package:escala/features/schedule/models/schedule_date.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages

class ScheduleDateTypeList extends StatefulWidget {
  final Institution institution;

  const ScheduleDateTypeList({Key? key, required this.institution}) : super(key: key);

  @override
  State<ScheduleDateTypeList> createState() => _ScheduleDateTypeListState();
}

class _ScheduleDateTypeListState extends State<ScheduleDateTypeList> {
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
              'Selecione o de evento da escala',
              style: TextStyle(
                fontSize: Theme.of(context).textTheme.titleLarge!.fontSize,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ),
          SizedBox(
            height: 250,
            child: ListView.builder(
              itemCount: ScheduleDate.scheduDateTypeList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.height * 0.07,
                        height: 45,
                        color: widget.institution.scheduleDateTypeColor(ScheduleDate.scheduDateTypeList[index].type),
                      ),
                      ConstrainedBox(
                        constraints: BoxConstraints.tightFor(height: 45, width: MediaQuery.of(context).size.height * 0.43),
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(ScheduleDate.scheduDateTypeList[index].type),
                          child: Text(ScheduleDate.scheduDateTypeList[index].name),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ConstrainedBox(
              constraints: BoxConstraints.tightFor(height: 45, width: MediaQuery.of(context).size.height * 0.75),
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancelar'),
              ),
            ),
          )
        ],
      ),
    );
  }
}
