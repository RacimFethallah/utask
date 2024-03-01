import 'package:flutter/material.dart';
import 'package:msh_checkbox/msh_checkbox.dart';
import 'package:provider/provider.dart';

import '../../models/tasks.dart';
import '../../providers/drag_provider.dart';
import '../../providers/task_provider.dart';

class TasksViewInboxPage extends StatelessWidget {
  const TasksViewInboxPage({
    Key? key,
    required this.filteredTasks,
  }) : super(key: key);

  final List<Task> filteredTasks;

  @override
  Widget build(BuildContext context) {
    final doneTasks = filteredTasks.where((task) => task.isDone).toList();
    final notDoneTasks = filteredTasks.where((task) => !task.isDone).toList();

    return Expanded(
      child: filteredTasks.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('No tasks Yet! Add a task to get started!'),
                  SizedBox(height: 40),
                  Icon(
                    Icons.arrow_downward_rounded,
                    size: 50,
                    color: Color.fromARGB(255, 0, 73, 133),
                  )
                ],
              ),
            )
          : ListView.builder(
              itemCount: notDoneTasks.length + (doneTasks.isNotEmpty ? 1 : 0),
              itemBuilder: (context, index) {
                return buildTaskItem(context, notDoneTasks, doneTasks, index);
              },
            ),
    );
  }

  Widget buildTaskItem(
    BuildContext context,
    List<Task> notDoneTasks,
    List<Task> doneTasks,
    int index,
  ) {
    if (index < notDoneTasks.length) {
      return buildTaskWidget(context, notDoneTasks[index], index);
    } else {
      return doneTasks.isNotEmpty
          ? doneTasksList(context, doneTasks)
          : const SizedBox();
    }
  }

  Widget buildTaskWidget(BuildContext context, Task task, index) {
    return LongPressDraggable(
      dragAnchorStrategy: (Draggable<Object> _, BuildContext __, Offset ___) =>
          const Offset(70, 70),
      key: ValueKey(task),
      data: task.id,
      onDragStarted: () {
        context.read<DragStateProvider>().startDrag(index);
      },
      onDragEnd: (data) {
        context.read<DragStateProvider>().endDrag();
      },
      feedback: buildTaskCard(task),
      childWhenDragging: const SizedBox(),
      child: buildDragTarget(context, task),
    );
  }

  Widget buildDragTarget(BuildContext context, Task task) {
    return DragTarget(
      builder: (context, incoming, rejected) {
        return GestureDetector(
          onTap: () {
            showTaskDetails(context);
          },
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
            child: buildTaskContainer(context, task, incoming),
          ),
        );
      },
      // Drag target callbacks...
    );
  }

  Widget buildTaskContainer(
      BuildContext context, Task task, List<Object?> incoming) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: incoming.isNotEmpty ? Colors.blue[100] : Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          MSHCheckbox(
            size: 22,
            value: task.isDone,
            colorConfig: MSHColorConfig.fromCheckedUncheckedDisabled(
              checkedColor: const Color.fromARGB(255, 0, 73, 133),
            ),
            style: MSHCheckboxStyle.fillScaleColor,
            onChanged: (selected) {
              context.read<TasksAPI>().updateTask(task.id, isDone: selected);
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              task.content,
              style: TextStyle(
                fontSize: 14,
                decoration: task.isDone
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
                color: task.isDone ? Colors.grey : Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTaskCard(Task task) {
    return Card(
      color: Colors.blue[100],
      child: Container(
        padding: const EdgeInsets.all(10),
        child: Text(task.content),
      ),
    );
  }

  Widget doneTasksList(BuildContext context, List<Task> doneTasks) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 0),
      child: Card(
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text('Done tasks (${doneTasks.length})'),
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: doneTasks.length,
                itemBuilder: (BuildContext context, int index) {
                  return buildTaskWidget(context, doneTasks[index], index);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> showTaskDetails(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            width: 300,
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Edit Task',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    initialValue: 'Example Task',
                    decoration: InputDecoration(
                      labelText: 'Task Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 10),
                  TextFormField(
                    initialValue: 'This is an example task description.',
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Task Description',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          // Save changes
                          Navigator.pop(context);
                        },
                        child: Text('Save'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          // Cancel editing
                          Navigator.pop(context);
                        },
                        child: Text('Cancel'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  _filterNotDoneTasks(List filteredTasks) {
    return filteredTasks.where((task) => !task.isDone).toList();
  }
}
