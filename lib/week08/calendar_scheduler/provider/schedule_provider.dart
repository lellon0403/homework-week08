import 'package:myapp/week08/calendar_scheduler/model/schedule_model.dart';

import 'package:myapp/week08/calendar_scheduler/repository/schedule_repository.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ScheduleProvider extends ChangeNotifier {
  final ScheduleRepository repository; //API 요청 로직을 담은 클래스

  DateTime selectedDate = DateTime.utc( //선택한 날짜
    DateTime.now().year,
    DateTime.now().month,
    DateTime.now().day,
  );

  Map<DateTime,List<ScheduleModel>> cache = {}; //일정 정보를 저장해둘 변수

  ScheduleProvider({
    required this.repository,
  }) : super() {
    getSchedules(date: selectedDate);
  }


  void getSchedules({
    required DateTime date,
  }) async {
    final resp = await repository.getSchedules(date:date); //GET 메서드 보내기

    // 선택한 날짜의 일정들 업데이트 하기
    cache.update(date,(value) => resp, ifAbsent: ()  => resp);
    notifyListeners();
  }

  void createSchedule({
    required ScheduleModel schedule,
  }) async {
    final targetDate = schedule.date;

    final uuid = Uuid();

    final tempId = uuid.v4(); //유일한 ID값을 생성합니다.
    final newSchedule = schedule.copyWith(
      id: tempId, //임시 ID를 지정합니다
    );
    //긍정적 응답 구간입니다. 서버에서 응답을 받기 전에 캐시를 먼저 업데이트 합니다
    cache.update(
      targetDate,
      (value) => [
        ...value,
        newSchedule,
      ]..sort(
        (a,b) => a.startTime.compareTo(
          b.startTime,
        ),
      ),
      ifAbsent: () => [newSchedule],
    );
    notifyListeners(); //캐시 업데이트 반영하기

    try {
      //API 요청을 합니다.
      final savedSchedule = await repository.createSchedule(schedule: schedule);

      cache.update( //서버 응답 기반으로 캐시 업데이트
        targetDate,
        (value) => value
        .map((e) => e.id == tempId
        ? e.copyWith(
          id: savedSchedule,
        )
        :e)
        .toList(),
        );
    } catch(e) {
      cache.update( //일정 생성실패시 롤백하기
        targetDate,
        (value) => value.where((e) => e.id != tempId).toList(),
        );
    }
    notifyListeners();
  }

  void deleteSchedule({
    required DateTime date,
    required String id,
  }) async {
    final targetSchedule = cache[date]!.firstWhere(
      (e) => e.id == id,
    ); //삭제할 일정 기억
    
    cache.update( //캐시에서 데이터 삭제
    date,
    (value) => value.where((e) => e.id != id).toList(),
      ifAbsent: () => [],
      );
      notifyListeners();
  }

  void changeSelectedDate({
    required DateTime date,
  }) {
    selectedDate = date; //현재 선택된 날짜를 매개변수로 입력받은 날짜로 변경
    notifyListeners();
  }
}