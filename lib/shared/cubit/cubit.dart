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
         getDataFromDatabase(database).then((value) {
                tasks = value;
                emit(AppGetDatabaseState());
          });
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
            getDataFromDatabase(database).then((value)
            {
              tasks= value;
              emit(AppGetDatabaseState());
            });
        print('$value inserted successfully');
      }).catchError((error) {
        print('Error when inserting new record ${error.toString()}');
      });
    });
  }

  Future<List<Map>> getDataFromDatabase(database) async {
    return await database.rawQuery('SELECT * FROM tasks');
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