import 'package:flutter/material.dart';
import 'package:myapp/week08/calendar_scheduler/component/custom_text_field.dart';
import 'package:myapp/week08/calendar_scheduler/const/colors.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:get_it/get_it.dart';
import 'package:myapp/week08/calendar_scheduler/database/drift_database.dart';
import 'package:myapp/week08/calendar_scheduler/model/schedule_model.dart';
import 'package:provider/provider.dart';
import 'package:myapp/week08/calendar_scheduler/provider/schedule_provider.dart';

class ScheduleBottomSheet extends StatefulWidget {
  final DateTime selectedDate; //선택된 날짜 상위 위젯에서 입력받기

  const ScheduleBottomSheet({
    required this.selectedDate,
    Key? key
  }) : super(key: key);
  
  @override
  State<ScheduleBottomSheet> createState() => _ScheduleBottomSheetState();
}

class _ScheduleBottomSheetState extends State<ScheduleBottomSheet>{
  final GlobalKey<FormState> formKey = GlobalKey(); //폼 key 생성

  int? startTime; //시작 시간 저장 변수
  int? endTime; //종료 시간 저장 변수
  String? content; //일정 내용 저장 변수

  @override
  Widget build(BuildContext context) {
    //키보드 높이 가져오기
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Form( //텍스트 필드를 한 번에 관리할 수 있는 폼
      key: formKey, //Form 을 조작할 키값
      child: SafeArea(
        child: Container(
          height: MediaQuery.of(context).size.height /2 + bottomInset, //
          color: Colors.white,
          child: Padding(
            padding: EdgeInsets.only(left: 8,right: 8,
            top: 8,bottom: bottomInset), //패딩에 키보드 높이 추가해서 위젯 전반적으로 위로 올려주기
            child: Column(
              //시간 관련 텍스트 필드와 내용 관련 텍스트 필드 세로로 배치
              children: [
                Row(
                  //시작 시간, 종료 시간 가로로 배치
                  children: [
                    Expanded(
                      child:  CustomTextField( //시작 시간 입력 필드
                      label: '시작 시간',
                      isTime: true,
                      onSaved: (String? val){
                        //저장이 실행되면 startTime 변수에 텍스트 필드값 저장
                        startTime = int.parse(val!);
                      },
                      validator: timeValidator,
                      ),
                    ),

                    const SizedBox(width: 16.0,),
                    Expanded(
                      child: CustomTextField( //종료 시간 입력 필드
                        label: '종료 시간',
                        isTime: true,
                        onSaved: (String? val){ 
                          //저장이 실행되면 endTime 변수에 텍스트 필드값 저장
                          endTime = int.parse(val!);
                        }, 
                        validator: timeValidator,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8.0,),
                Expanded(
                  child: CustomTextField( //내용 입력 필드
                    label: '내용',
                    isTime: false,
                    onSaved: (String? val){ 
                      //저장이 실행되면 content 변수에 텍스트 필드값 저장
                      content = val;
                    },
                    validator: contentValidator,
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton( //저장 버튼
                    //[저장] 버튼
                    onPressed: onSavePressed(context), //함수에 context 전달
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: PRIMARY_COLOR,
                    ),
                    child: Text('저장'),

                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onSavePressed(BuildContext context) async{
    if(formKey.currentState!.validate()){ //폼 검증하기
      formKey.currentState!.save();

      context.read<ScheduleProvider>().createSchedule(
        schedule: ScheduleModel(
          id: 'new_model', //임시 ID
          content: content!,
          date: widget.selectedDate,
          startTime: startTime!,
          endTime: endTime!,
        ),
      );
      
      Navigator.of(context).pop(); //일정 생성 후 화면 뒤로 가기
    }
  }

  String? timeValidator(String? val) {  
    if(val == null) {
      return '값을 입력해주세요';
    }
    int? number;

    try{
      number = int.parse(val);
    }catch(e) {
      return '숫자를 입력해주세요';
    }
    
    if(number < 0 || number > 24) {
      return '0시부터 24시 사이를 입력해주세요';
    }

    return null;
  } //시간값 검증

  String? contentValidator(String? val) { //내용 검증 함수
    if(val == null || val.length == 0){ 
      return '값을 입력해주세요';
    }
    return null;
  } //내용값 검증
}