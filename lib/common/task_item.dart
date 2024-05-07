import 'package:flutter/material.dart';
import 'package:todo_app/common/categories.dart';
import 'package:todo_app/common/commons.dart';

import '../models/task.dart';

class TaskItem extends StatefulWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  State<TaskItem> createState() => _TaskItemState();
}

class _TaskItemState extends State<TaskItem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 3.0),
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      height: 70.0,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(20.0)),
        color: primaryBackground,
      ),
      child: Row(
        children: [
          // Le cercle du checkboox (isDone)
          Container(
            padding: const EdgeInsets.all(2.0),
            height: 25,
            width: 25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.task.category == Categories.Business
                  ? businessIndicator
                  : personalIndicator,
            ),
            child: widget.task.isDone
                ? const Icon(
                    Icons.done_rounded,
                    color: Colors.white,
                    size: 18.0,
                  )
                : Container(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: primaryBackground,
                    ),
                  ),
          ),
          const SizedBox(width: 10.0),
          Text(
            " ${widget.task.title}",
            style: TextStyle(
              decoration: widget.task.isDone
                  ? TextDecoration.lineThrough
                  : TextDecoration.none,
              decorationColor: Colors.white,
              color: Colors.white,
              fontSize: 20.0,
            ),
          )
        ],
      ),
    );
  }
}
