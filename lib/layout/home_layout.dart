
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:udemy_flutter/modules/archived_tasks_screen.dart';
import 'package:udemy_flutter/modules/done_tasks_screen.dart';
import 'package:udemy_flutter/modules/new_tasks_screen.dart';
import 'package:udemy_flutter/shared/components.dart';

class HomeLayout extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomeLayoutState();
}

class _HomeLayoutState extends State<HomeLayout> {
  List<Widget> screens = [
    NewTaskScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen(),
  ];

  @override
  void initState() {
    super.initState();
    createDatabase();
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;
  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();
  late Database database;
  List<String> titles = ['New Tasks', 'Done Tasks', 'Archived Tasks'];
  int currentIndex = 0;
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        key: scaffoldKey,
        appBar: AppBar(
          title: Text(titles[currentIndex]),
        ),
        body: screens[currentIndex],
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (isBottomSheetShown) {
                if(formKey.currentState!.validate()){
                  insertToDatabase(
                      title :titleController.text,
                      time :timeController.text,
                      date : dateController.text).
                  then((value){

                    Navigator.pop(context);
                    isBottomSheetShown = false;
                    setState(() {
                      fabIcon = Icons.edit;
                    });
                  });
                }

              } else {
                scaffoldKey.currentState!.showBottomSheet((context) => Container(
                  color: Colors.grey[100],
                  padding: EdgeInsets.all(20,),
                  child: Form(
                    key: formKey,
                    child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            defaultFormField(
                                controller: titleController,
                                type: TextInputType.text,
                                validate: (String? value){
                                  if(value!.isEmpty)
                                  {
                                    return 'title must not be empty';
                                  }
                                  return null;
                                },
                                label: 'Task Title',
                                prefix: Icons.title
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),
                            defaultFormField(
                                controller: timeController,
                                type: TextInputType.datetime,
                                onTap: (){
                                  showTimePicker(
                                      context: context,
                                      initialTime: TimeOfDay.now(),
                                  ).then((value){
                                    timeController.text = value!.format(context).toString();
                                  });
                                },
                                validate: (String? value){
                                  if(value!.isEmpty)
                                  {
                                    return 'time must not be empty';
                                  }
                                  return null;
                                },
                                label: 'Task Time',
                                prefix: Icons.watch_later_outlined
                            ),
                            const SizedBox(
                              height: 15.0,
                            ),defaultFormField(
                                controller: dateController,
                                type: TextInputType.datetime,

                                onTap: (){
                                  showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime.now(),
                                      lastDate: DateTime.parse('2021-10-03'),
                                  ).then((value) =>dateController.text=DateFormat.yMMMd().format(value!) );
                                },
                                validate: (String? value){
                                  if(value!.isEmpty)
                                  {
                                    return 'date must not be empty';
                                  }
                                  return null;
                                },
                                label: 'Task date',
                                prefix: Icons.calendar_today
                            ),

                          ],
                        ),
                  ),
                ),
                  elevation : 20.0,
                );
                isBottomSheetShown = true;
                setState(() {
                  fabIcon = Icons.add;
                });
              }
            },
            child: Icon(fabIcon)),
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          // ignore: prefer_const_literals_to_create_immutables
          items: [
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.menu,
              ),
              label: 'Tasks',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.check_circle_outline,
              ),
              label: 'Done',
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.archive_outlined,
              ),
              label: 'Archived',
            ),
          ],
        ));
  }

  void createDatabase() async {
    database = await openDatabase('todo.db', version: 1,
        onCreate: (database, version) async {
      print('database created');
      await database
          .execute(
              'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, date TEXT,time TEXT, status TEXT)')
          .then((value) => print('table created'))
          .catchError((error) =>
              print('error when creating table ${error.toString()}'));
    }, onOpen: (database) {});
  }

  Future insertToDatabase({required String title,
      required String time,
      required String date,
  }) async {
    return await database.transaction((txn)async {
        txn.rawInsert(
              'INSERT INTO tasks(title, date, time, status) VALUES("$title","$date","$time","new")')
          .then((value) {
        print('$value inserted successfully');
      }).catchError((error) {
        print('Error when inserting new record ${error.toString()}');
      });

    });

  }
}
