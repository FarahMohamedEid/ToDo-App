import 'dart:io';

import 'package:conditional_builder/conditional_builder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:todo_app/shared/cubit/cubit.dart';

Widget defaultButton({
  double width = double.infinity,
  double height = 50,
  Color background = Colors.blue,
  @required Function function,
  @required String text,
}) =>
    MaterialButton(
        child: Text(text),
        color: background,
        height: height,
        textColor: Colors.white,
        onPressed: function);

Widget defultTextFormField({
  @required Function validate,
  @required TextEditingController controller,
  @required TextInputType textInputType,
  Function onSubmit,
  bool isClickable = true,
  Function onEyePressed,
  Function onTap,
  @required String label,
  @required IconData prefix,
  IconData suffix,
  bool isPassword = false,
}) =>
    TextFormField(
// to cheek if the text form field is null or not :)
      validator: validate,
      controller: controller,
      onTap: onTap,
      enabled: isClickable,
      keyboardType: textInputType,
      onFieldSubmitted: onSubmit,
      obscureText: isPassword,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(prefix),
        suffixIcon: IconButton(
          icon: Icon(suffix),
          onPressed: onEyePressed,
        ),
        border: OutlineInputBorder(),
      ),
    );

Widget buildTaskItem(Map model, context) => Dismissible(
      key: Key(model['id'].toString()),
      onDismissed: (directions) {
        AppCubit.get(context).Deletedata(id: model['id']);
      },
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            CircleAvatar(
              radius: 35,
              child: Text('${model['time']}'),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${model['title']}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Text(
                  '${model['date']}',
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            Spacer(),
            IconButton(
                icon: Icon(Icons.check_box),
                color: Colors.green,
                onPressed: () {
                  AppCubit.get(context)
                      .Updatedata(status: 'done', id: model['id']);
                }),
            IconButton(
                icon: Icon(Icons.archive_outlined),
                color: Colors.blueGrey,
                onPressed: () {
                  AppCubit.get(context)
                      .Updatedata(status: 'archived', id: model['id']);
                }),
          ],
        ),
      ),
    );

Widget TasksBuilder ({
  @required List<Map> tasks,
}) =>ConditionalBuilder(
  condition: tasks.length>0 ,
  builder:(context) =>  ListView.separated(
      itemBuilder:(context, index) =>  buildTaskItem(tasks[index],context),
      separatorBuilder: (context, index) => Container(
        width: double.infinity,
        height: 1.0,
        color: Colors.grey,
      ),
      itemCount: tasks.length
  ),
  fallback: (context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.menu_outlined,
          size: 50,
          color: Colors.black45,
        ),
        Text(
          'empty Tasks !!',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 30,
            color: Colors.black45,

          ),
        ),
      ],
    ),
  ),
);
