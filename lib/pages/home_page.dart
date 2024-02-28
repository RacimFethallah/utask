import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:provider/provider.dart';
import 'package:utask/services/task.dart';
import 'package:top_modal_sheet/top_modal_sheet.dart';
import '../providers/drag_provider.dart';
import '../widgets/add_task_view.dart';
import '../widgets/calendar_view.dart';
import '../widgets/build_body.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool deleteFloatingActionButton = false;
  String _topModalData = "";

  bool addTaskDialogOpened = false;
  int _bottomNavIndex = 0;
  List<IconData> iconList = [
    Icons.inbox_rounded,
    Icons.format_list_bulleted_rounded,
  ];
  List<String> appBarTitles = [
    'Your inbox',
    'Your lists',
  ];

  void removeTask(Object? data) async {
    final removedTaskId = data as String?;
    if (removedTaskId != null) {
      try {
        await context.read<TasksAPI>().deleteTask(taskId: removedTaskId);
        // showSuccessDelete();
      } on AppwriteException catch (e) {
        showAlert(title: 'Error', text: e.message.toString());
      }
    } else {
      showAlert(title: 'Error', text: 'An error occured');
    }
  }

  void _showAddTaskDialog() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const AddTaskView(),
      isScrollControlled: true,
      // expand: true,
    );
    // .whenComplete(() => setState(() {
    //       addTaskDialogOpened = !addTaskDialogOpened;
    //     }));
  }

  Future<void> _showCalendarView() async {
    final value = await showTopModalSheet<String?>(
      context,
      const CalendarView(),
      backgroundColor: Colors.white,
      borderRadius: const BorderRadius.vertical(
        bottom: Radius.circular(25),
      ),
    );

    if (value != null) setState(() => _topModalData = value);
  }

  void showSuccessDelete() {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Task deleted successfully'),
      elevation: 10.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      showCloseIcon: true,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitles[_bottomNavIndex]),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.calendar_month_rounded),
            onPressed: () {
              _showCalendarView();
            },
          ),
        ],
      ),
      floatingActionButton: DragTarget(
          builder: (context, incoming, rejected) {
            return floatingActionButton(context, incoming.isNotEmpty);
          },
          onWillAccept: (data) => true,
          onAccept: (data) {
            removeTask(data);
            // tasks.remove(data);
          }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavigationBar(
          height: 65.0,
          icons: iconList,
          activeIndex: _bottomNavIndex,
          gapLocation: GapLocation.center,
          leftCornerRadius: 32,
          rightCornerRadius: 32,
          notchSmoothness: NotchSmoothness.softEdge,
          iconSize: 28,
          activeColor: const Color.fromARGB(255, 0, 73, 133),
          inactiveColor: Colors.grey,
          shadow: BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10),
          onTap: (index) {
            setState(() {
              _bottomNavIndex = index;
            });
          }
          //other params
          ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'user',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                ),
              ),
            ),
            ListTile(
              title: Text('Item 1'),
              onTap: () {
                // Update UI based on drawer item selected
              },
            ),
            ListTile(
              title: Text('Item 2'),
              onTap: () {
                // Update UI based on drawer item selected
              },
            ),
            // Add more ListTile widgets for additional items as needed
          ],
        ),
      ),
      body: buildBody(_bottomNavIndex),
    );
  }

  FloatingActionButton floatingActionButton(
      BuildContext context, bool isNotEmpty) {
    final isDragging = Provider.of<DragStateProvider>(context).isDragging;
    return isDragging
        ? isNotEmpty
            ? FloatingActionButton.large(
                shape: const CircleBorder(),
                tooltip: 'add task',
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 50),
                // addTaskDialogOpened
                //     ? const Icon(Icons.close_rounded, color: Colors.white, size: 38)
                //     : const Icon(Icons.add_rounded, color: Colors.white, size: 38),
                onPressed: () {
                  // setState(() {
                  //   addTaskDialogOpened = !addTaskDialogOpened;
                  // });
                  // if (addTaskDialogOpened) {
                    _showAddTaskDialog();
                  // }
                }, //params
              )
            : FloatingActionButton(
                shape: const CircleBorder(),
                tooltip: 'add task',
                backgroundColor: Colors.red,
                child: const Icon(Icons.delete_outline_rounded,
                    color: Colors.white, size: 38),
                // addTaskDialogOpened
                //     ? const Icon(Icons.close_rounded, color: Colors.white, size: 38)
                //     : const Icon(Icons.add_rounded, color: Colors.white, size: 38),
                onPressed: () {
                  setState(() {
                    addTaskDialogOpened = !addTaskDialogOpened;
                  });
                  if (addTaskDialogOpened) {
                    _showAddTaskDialog();
                  }
                }, //params
              )
        : FloatingActionButton(
            shape: const CircleBorder(),
            tooltip: 'add task',
            backgroundColor: const Color.fromARGB(255, 0, 73, 133),
            child: const Icon(Icons.add_rounded, color: Colors.white, size: 38),
            // addTaskDialogOpened
            //     ? const Icon(Icons.close_rounded, color: Colors.white, size: 38)
            //     : const Icon(Icons.add_rounded, color: Colors.white, size: 38),
            onPressed: () {
              setState(() {
                addTaskDialogOpened = !addTaskDialogOpened;
              });
              if (addTaskDialogOpened) {
                _showAddTaskDialog();
              }
            },
            //params
          );
  }

  showAlert({required String title, required String text}) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: Text(text),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Ok'))
            ],
          );
        });
  }
}

// if (task.auth.status == AuthStatus.uninitialized) {
//   await task.auth.loadUser();
// }

//old version
// void _showModalBottomSheet() {
//   addTaskBox().whenComplete(() => setState(() {
//         addTaskDialogOpened = !addTaskDialogOpened;
//       }));
// }

// Future<dynamic> addTaskBox() {
// return showModalBottomSheet(
//   context: context,
//   builder: (context) {
// return AnimatedOpacity(
//   opacity: addTaskDialogOpened ? 1.0 : 0.0,
//   duration: const Duration(milliseconds: 5000),
//   child: AnimatedContainer(
//     duration: const Duration(milliseconds: 5000),
//     height: addTaskDialogOpened
//         ? MediaQuery.of(context).size.height * 0.62
//         : 0.0,
//     child: Wrap(
//       // Use Wrap widget to center the content vertically
//       children: [
//         Center(
//           // Center the content vertically
//           child: Padding(
//             padding: MediaQuery.of(context)
//                 .viewInsets, // Adjust for keyboard
//             child: Container(
//               padding: const EdgeInsets.all(20.0),
//               height: MediaQuery.of(context).size.height *
//                   0.21, // 30% of screen height
//               child: Column(
//                 children: [
//                   TextField(
//                     controller: taskController,
//                     autofocus:
//                         true, // Automatically focus the input field
//                     decoration: const InputDecoration(
//                       labelText: 'Enter Task',
//                       border: OutlineInputBorder(),
//                     ),
//                     keyboardType: TextInputType
//                         .text, // Set appropriate keyboard type
//                     textInputAction: TextInputAction
//                         .done, // Dismiss keyboard on Done
//                     onSubmitted: (_) {
//                       setState(() {
//                         addTaskDialogOpened = !addTaskDialogOpened;
//                       });
//                       // Handle task submission, e.g.,
//                       _addTask(taskController.text);
//                       Navigator.pop(context); // Close bottom sheet
//                     },
//                   ),
//                   const SizedBox(height: 10.0),
//                   // Row(
//                   //   mainAxisAlignment: MainAxisAlignment.end,
//                   //   children: [
//                   //     TextButton(
//                   //       onPressed: () {
//                   //         Navigator.pop(context); // Close bottom sheet
//                   //       },
//                   //       child: const Text('Cancel'),
//                   //     ),
//                   //     const SizedBox(width: 10.0),
//                   //     ElevatedButton(
//                   //       onPressed: () {
//                   //         // Handle task submission, e.g.,
//                   //         _addTask(taskController.text);
//                   //         Navigator.pop(context); // Close bottom sheet
//                   //       },
//                   //       child: const Text('Submit'),
//                   //     ),
//                   //   ],
//                   // ),
//                   Center(
//                     child: ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           addTaskDialogOpened = !addTaskDialogOpened;
//                         });
//                         // Handle task submission, e.g.,
//                         _addTask(taskController.text);
//                         Navigator.pop(context); // Close bottom sheet
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor:
//                             const Color.fromARGB(255, 0, 73, 133),
//                         shape: const CircleBorder(),
//                         padding: const EdgeInsets.all(10),
//                       ),
//                       child: const Icon(Icons.check_rounded,
//                           color: Colors.white, size: 38),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ],
//     ),
//   ),
// );
//   },
//   isScrollControlled: true, // Ensure content stays above keyboard
// );
// }
