import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks_screen.dart';
import 'package:todo_app/shared/cubit/states.dart';

class AppCubit extends Cubit<AppStates> {
  AppCubit() : super(AppInitialStates());

  // to make it easy make an object anywhere :)
  static AppCubit get(context) => BlocProvider.of(context);

  List<Map> Newtasks = [];
  List<Map> Donetasks = [];
  List<Map> Archivedtasks = [];
  int current_index = 0;

  List<Widget> screens = [
    NewTasksScreen(),
    DoneTasksScreen(),
    ArchivedTasksScreen()
  ];
  List<String> Titels = ['New Tasks', 'Done Tasks', 'Archived Tasks'];

  void changeIndex(int index) {
    current_index = index;
    emit(AppChangeBottomNavBarState());
  }

  Database database;

  void createDataBase() {
    openDatabase(
      'todo.db',
      version: 1,
      onCreate: (db, version) {
        print('created db');
        db
            .execute(
                'CREATE TABLE tasks ( id INTEGER PRIMARY KEY, title TEXT,date TEXT, time TEXT,status TEXT)')
            .then((value) {
          print('table created');
        }).catchError((error) {
          print('error is ---> ${error.toString()}');
        });
      },
      onOpen: (db) {
        // ببعتلها الل db علشان دي الي هتتعمل قبل ال database الي انا عاملاها فوق خالص ومعرفاها
        getDataFromDataBase(db);
        print('opened db');
      },
    ).then((value) {
      database = value;
      emit(AppCreateDataBaseState());
    });
  }

  Future insertOnDataBase({
    @required String title,
    @required String time,
    @required String date,
  }) async {
    return await database.transaction((txn) {
      txn
          .rawInsert(
              'INSERT INTO tasks(title,date, time ,status) VALUES("$title","$date","$time","new") ')
          .then((value) {
        print('$value inserted done');
        emit(AppInsertDataBaseState());
        getDataFromDataBase(database);

      }).catchError((error) {
        print('errrrrrrrrrrrrror $error in inserted');
      });
      return null;
    });
  }

  void getDataFromDataBase(db) {
    Newtasks=[];
    Donetasks=[];
    Archivedtasks=[];
    emit(AppGetDataBaseLoadingState());
    db.rawQuery('SELECT * FROM tasks').then((value) {

      value.forEach((element){

        if(element['status'] == 'new'){
          Newtasks.add(element);
        }else if(element['status'] == 'done'){
          Donetasks.add(element);
        }else Archivedtasks.add(element);

      });

      emit(AppGetDataBaseState());
    });
  }

  bool isBottomSheetShown = false;
  IconData fabIcon = Icons.edit;

  void ChangeBottomSheetState({
    @required bool isShow,
    @required IconData icon,
  }) {
    isBottomSheetShown= isShow;
    fabIcon=icon;

    emit(AppChangeBottomSheetState());
  }


  void Updatedata({
    @required String status,
    @required int id,
}) async {
     database.rawUpdate(
        'UPDATE tasks SET status = ? WHERE id = ?',
        ['$status', id]).then((value) {

          getDataFromDataBase(database);
          emit(AppUpdateDataBaseState());
     });

  }

  void Deletedata({
    @required int id,
  }) async {
    database.rawDelete('DELETE FROM tasks WHERE id = ?', [id])
        .then((value) {

      getDataFromDataBase(database);
      emit(AppDeleteDataBaseState());
    });

  }
}
