import 'package:myapp/week08/calendar_scheduler/model/schedule_model.dart';

import 'package:myapp/week08/calendar_scheduler/repository/schedule_repository.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository repository; //API 요청 로직을 담은 클래스

  DateTime selectedDate = DateTime.utc( //선택한 날짜
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
    );
}