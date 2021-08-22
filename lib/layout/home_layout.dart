import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:todo_app/modules/archived_tasks_screen.dart';
import 'package:todo_app/modules/done_tasks_screen.dart';
import 'package:todo_app/modules/new_tasks_screen.dart';
import 'package:todo_app/shared/components/components.dart';
import 'package:todo_app/shared/conestants/constants.dart';
import 'package:todo_app/shared/cubit/cubit.dart';
import 'package:todo_app/shared/cubit/states.dart';

class HomeLayout extends StatelessWidget
  {

  var scaffoldKey = GlobalKey<ScaffoldState>();
  var formkey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var timeController = TextEditingController();
  var dateController = TextEditingController();



  // to make a thread use (async) ->  return -> Instance of 'Future<String>'
  //لانه لسه مجاش من ال back ground .... فعلشان اجيبه لازم اخلي ال on pressed تبقا async بردو واضيف await
  // Future<String> getName() async {
  // return 'Faraaah';
  // }

  @override
  Widget build(BuildContext context) {
  return BlocProvider(

    // شرح معني الل .. الي علي اليمين هو هو نفس الي علي الشمال
    // final foo = Foo()                 final foo = Foo();
    //  ..first()            =  -->      foo.first();
    //  ..second();                      foo.second();

    create: (context) => AppCubit()..createDataBase(),
    child: BlocConsumer<AppCubit,AppStates>(
      listener: (context, state) {
        if(state is AppInsertDataBaseState)
        {
          Navigator.pop(context);
        }
      },
      builder: (context, state) {
        AppCubit cubit = AppCubit.get(context);
        return Scaffold(
          key: scaffoldKey,
          appBar: AppBar(
            title: Text(
              cubit.Titels[cubit.current_index],
            ),
          ),
          body: ConditionalBuilder(
            condition: state is! AppGetDataBaseLoadingState,
            builder:(context) =>  cubit.screens[cubit.current_index],
            fallback:(context) => Center(child: CircularProgressIndicator()) ,
          ),
          floatingActionButton: FloatingActionButton(
            // الطريقه الاولي
            // onPressed: () async{
            //   var name= await getName();
            //   print(name);
            // },

            // الطريقه التانيه
            //  ممكن اشيل ال async+await واحط .then علشان تضمنلي ان الداتا جاتلي من بره + ممكن تخليني اعمل كاتش للايرور لو في يعني
            onPressed: () {
              // getName().then((value) {
              //   print(value);
              //   print('eid');
              //   // throw بعمل بيها ايرور بس مش اكتر
              //   throw ('i create this error :)');
              //
              // }).catchError((onError){
              //   print('error is ---> ${onError.toString()}');
              // });

              if (cubit.isBottomSheetShown) {
                if(formkey.currentState.validate()){
                  cubit.insertOnDataBase(title: titleController.text,
                      time: timeController.text,
                      date:dateController.text );
                }
              } else {
                scaffoldKey.currentState.showBottomSheet(
                      (context) => Container(
                    padding: EdgeInsets.all(20),
                    child: Form(
                      key: formkey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          defultTextFormField(
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return 'title must not be empty';
                                }
                                return null;
                              },
                              controller: titleController,
                              textInputType: TextInputType.text,
                              label: 'Task Title',
                              prefix: Icons.title_sharp),
                          SizedBox(height: 10,),
                          defultTextFormField(
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return 'time must not be empty';
                                }
                                return null;
                              },
                              controller: timeController,
                              textInputType: TextInputType.datetime,
                              label: 'Task Time',
                              onTap:(){
                                showTimePicker(context: context,
                                    initialTime: TimeOfDay.now()).then((value){
                                  timeController.text=value.format(context).toString();
                                });
                              },
                              prefix: Icons.watch_later_outlined),
                          SizedBox(height: 10,),
                          defultTextFormField(
                              validate: (String value) {
                                if (value.isEmpty) {
                                  return 'Date must not be empty';
                                }
                                return null;
                              },
                              controller: dateController,
                              textInputType: TextInputType.datetime,
                              label: 'Task Date',
                              onTap:(){
                                showDatePicker(context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2021-12-12')).then((value){
                                  dateController.text=DateFormat.yMMMd().format(value);
                                });
                              },
                              prefix: Icons.calendar_today),

                        ],
                      ),
                    ),
                  ),
                  elevation: 30,
                ).closed.then((value) {

                  cubit.ChangeBottomSheetState(isShow: false, icon: Icons.edit);

                });

                cubit.ChangeBottomSheetState(isShow: true, icon: Icons.add);

              }
            },

            child: Icon(cubit.fabIcon),
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: cubit.current_index,
            onTap: (index) {
              cubit.changeIndex(index);
            },
            items: [
              BottomNavigationBarItem(
                  icon: Icon(Icons.menu_outlined), label: 'Tasks'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.check_circle_outline_outlined), label: 'Done'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.archive_outlined), label: 'Archived'),
            ],
          ),
        );
      },
    ),
  );
  }


}




