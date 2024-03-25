import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/entities.dart';
import '../../../providers/taskProvider.dart';
import '../../../providers/task_provider.dart';

class AddTagView extends StatefulWidget {
  const AddTagView({super.key});

  @override
  State<AddTagView> createState() {
    return _AddTagViewState();
  }
}

class _AddTagViewState extends State<AddTagView> {
  final TextEditingController tagController = TextEditingController();

  @override
  void dispose() {
    // Dispose the TextEditingController when the widget is disposed
    tagController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Tag> tags = context.watch<TasksProvider>().tags;
    final searchedTags = context.watch<TasksProvider>().searchedTags;
    final temporarilyAddedTags = context.watch<TasksProvider>().temporarilyAddedTags;

    tags = searchedTags.isNotEmpty ? searchedTags : tags;

    return SafeArea(
      child: Padding(
        padding: MediaQuery.of(context).viewInsets,
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.90,
          height: MediaQuery.of(context).size.height * 0.40,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: SizedBox(
                  
                  height: 40,
                  child: TextField(
                    controller: tagController,
                    decoration: const InputDecoration(
                      labelText: '# Add Tag or select already existing ones',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                    onChanged: (String value) {
                      if (RegExp(r'^[a-zA-Z_][a-zA-Z0-9_\-\.]*$')
                          .hasMatch(value)) {
                        // Only add value if it matches the allowed pattern
                        setState(() {
                          tagController.text = value;
                          tagController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: tagController.text.length));
                        });
                      } else {
                        // Remove invalid characters
                        setState(() {
                          tagController.text = tagController.text
                              .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '');
                          tagController.selection =
                              TextSelection.fromPosition(TextPosition(
                                  offset: tagController.text.length));
                        });
                      }
                      searchTags(tagController
                          .text); // Call searchTags with the updated value
                    },
                    onSubmitted: (_) {
                      if (_.isNotEmpty) {
                        context.read<TasksProvider>().addTemporarilyAddedTags(_);
                        tagController.clear();
                      }
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: tags.isEmpty
                        ? [const Text('Add a new tag')]
                        : tags.map((tag) {
                            return Container(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: CheckboxListTile(
                                contentPadding: const EdgeInsets.all(0),
                                title: Text("#${tag.name}"),
                                checkboxShape: RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(15)),
                                value: temporarilyAddedTags.any((element) => element.name == tag.name),
                                onChanged: (bool? newValue) {
                                  if (newValue != null) {
                                    if (newValue) {
                                      context
                                          .read<TasksProvider>()
                                          .addTemporarilyAddedTags(tag.name);
                                    } else {
                                      context
                                          .read<TasksProvider>()
                                          .removeTemporarilyAddedTags(tag);
                                    }
                                  }
                                },
                                activeColor:
                                    const Color.fromARGB(255, 0, 73, 133),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            );
                          }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void searchTags(String query) {
    if (query.isEmpty) {
      // If the query is empty, show all tags
      context.read<TasksAPI>().setSearchedTags(context.read<TasksAPI>().tags);
    } else {
      // search tags based on the query
      final suggestions = context.read<TasksAPI>().tags.where((tag) {
        return tag.toLowerCase().contains(query.toLowerCase());
      }).toList();
      context.read<TasksAPI>().setSearchedTags(suggestions);
    }
  }
}
