import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:udemy_flutter/modules/archived_tasks_screen.dart';
import 'package:udemy_flutter/modules/done_tasks_screen.dart';
import 'package:udemy_flutter/modules/new_tasks_screen.dart';
import 'package:udemy_flutter/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates>{
  //constructor
  AppCubit():super(AppInitialState());

  static AppCubit get(context) => BlocProvider.of(context);

  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];
  int currentIndex = 0;

  void changeIndex(int index){
    currentIndex = index;
    emit(AppChangeBottomNavBarState());
  }
  late Database database;
  List<Map>tasks = [];
  List<Map>newTasks =[];
  List<Map>doneTasks=[];
  List<Map>archivedTasks=[];
  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  void createDatabase()  {
     openDatabase('todo.db', version: 1,
        onCreate: (database, version) async {
          print('database created');
          await database
              .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT,time TEXT, status TEXT)')
              .then((value) => print('table created'))
              .catchError((error) =>
              print('error when creating table ${error.toString()}'));
        }, onOpen: (database) {
         getDataFromDatabase(database);
        }).then(
             (value) {
               database = value;
               emit(AppCreateDatabaseState());
             });
  }

   insertToDatabase({
    required String title,
    required String time,
    required String date,
  }) async {
     await database.transaction((txn) async {
      txn.rawInsert(
          'INSERT INTO tasks(title, date, time, status) VALUES("$title","$date","$time","new")')
          .then((value) {
            emit(AppInsertDatabaseState());
            getDataFromDatabase(database);
        print('$value inserted successfully');
      }).catchError((error) {
        print('Error when inserting new record ${error.toString()}');
      });
    });
  }
  void deleteData({
    required int id,
  })async
  {
    database.rawDelete('DELETE FROM tasks WHERE id = ?',
        [id]
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppDeleteDatabaseState());

    });
  }
  void updateData({
  required String status,
    required int id,
})async
  {
     database.rawUpdate('Update tasks SET status = ? WHERE id = ?',
        ['$status',id]
    ).then((value) {
      getDataFromDatabase(database);
      emit(AppUpdateDatabaseState());

    });
  }
  void getDataFromDatabase(database)  {
    newTasks = [];
    doneTasks = [];
    archivedTasks = [];
     database.rawQuery('SELECT * FROM tasks').then((value){
       value.forEach((element){
         if(element['status']=='new')
           newTasks.add(element);
         else if (element['status'] == 'done')
           doneTasks.add(element);
         else archivedTasks.add(element);
       });
     });
     emit(AppGetDatabaseState());
  }
  void changeBottomSheetState({
    required bool isShow ,
    required IconData icon,})
  {
    isBottomSheetShown = isShow;
    fabIcon = icon;
    emit(AppChangeBottomSheetState());
  }
  List<Widget> screens = [
    NewTaskScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];
}