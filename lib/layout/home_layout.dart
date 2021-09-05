//import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:udemy_flutter/modules/archived_tasks_screen.dart';
import 'package:udemy_flutter/modules/done_tasks_screen.dart';
import 'package:udemy_flutter/modules/new_tasks_screen.dart';
import 'package:udemy_flutter/shared/components.dart';
import 'package:udemy_flutter/shared/constants.dart';
import 'package:udemy_flutter/shared/cubit/cubit.dart';
import 'package:udemy_flutter/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget {





  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formKey = GlobalKey<FormState>();


  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => AppCubit()..createDatabase(),

      child: BlocConsumer<AppCubit,AppStates>(
        listener: (BuildContext context,AppStates state){
          if(state is AppInsertDatabaseState)
            {
              Navigator.pop(context);
            }
        },
        builder: (BuildContext context, AppStates state){
          AppCubit  cubit = AppCubit.get(context);
          return Scaffold(
              key: scaffoldKey,
              appBar: AppBar(
                title: Text(cubit.titles[cubit.currentIndex]),
              ),
              body:  cubit.screens[cubit.currentIndex],
              floatingActionButton: FloatingActionButton(
                  onPressed: () {
                    if (cubit.isBottomSheetShown) {
                      if (formKey.currentState!.validate()) {
                        cubit.insertToDatabase(
                            title: titleController.text,
                            time: timeController.text,
                            date: dateController.text);
                      }
                    } else {
                      scaffoldKey.currentState!
                          .showBottomSheet(
                            (context) => Container(
                          color: Colors.grey[100],
                          padding: EdgeInsets.all(
                            20,
                          ),
                          child: Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                defaultFormField(
                                    controller: titleController,
                                    type: TextInputType.text,
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'title must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Title',
                                    prefix: Icons.title),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                    controller: timeController,
                                    type: TextInputType.datetime,
                                    onTap: () {
                                      showTimePicker(
                                        context: context,
                                        initialTime: TimeOfDay.now(),
                                      ).then((value) {
                                        timeController.text =
                                            value!.format(context).toString();
                                      });
                                    },
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'time must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task Time',
                                    prefix: Icons.watch_later_outlined),
                                const SizedBox(
                                  height: 15.0,
                                ),
                                defaultFormField(
                                    controller: dateController,
                                    type: TextInputType.datetime,
                                    onTap: () {
                                      showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.parse('2021-10-03'),
                                      ).then((value) => dateController.text =
                                          DateFormat.yMMMd().format(value!));
                                    },
                                    validate: (String? value) {
                                      if (value!.isEmpty) {
                                        return 'date must not be empty';
                                      }
                                      return null;
                                    },
                                    label: 'Task date',
                                    prefix: Icons.calendar_today),
                              ],
                            ),
                          ),
                        ),
                        elevation: 20.0,
                      ).closed
                          .then((value) {
                            cubit.changeBottomSheetState(
                                isShow:false,
                                icon: Icons.edit);
                      });
                      cubit.changeBottomSheetState(
                          isShow: true,
                          icon: Icons.add);
                    }
                  },
                  child: Icon(cubit.fabIcon)),
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                currentIndex: cubit.currentIndex,
                onTap: (index) {
                  cubit.changeIndex(index);
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
        },

      ),
    );
  }


}


