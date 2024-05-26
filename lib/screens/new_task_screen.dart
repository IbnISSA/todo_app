import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:todo_app/common/commons.dart';
import 'package:todo_app/models/categories.dart';
import 'package:todo_app/models/task.dart';
import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

List<Categories> categories = Categories.values;

class NewTaskScreen extends StatefulWidget {
  final VoidCallback updateHome;
  const NewTaskScreen({super.key, required this.updateHome});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController textFieldControlller = TextEditingController();
  Categories selectedCategory = categories.first;
  bool isLoading = false;

  _saveTask(Task task, BuildContext context) async {
    setState(() {
      isLoading = true;
    });
    var saveTaskUrl = Uri.http(backendBaseUrl, '/tasks');
    var saveResponse = await http.post(saveTaskUrl,
        body: convert.jsonEncode(task.toJson()),
        headers: {'Content-Type': 'application/json'});
    setState(() {
      isLoading = false;
      _showSaveTaskResult(context, saveResponse);
    });
    // print("--------------- saveResponse Code: ${saveResponse.statusCode}");
    // print("--------------- saveResponse Body: ${saveResponse.body}");
    // widget.updateHome();
  }

  void _showSaveTaskResult(BuildContext context, Response saveResponse) {
    textFieldControlller.clear();
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: Text(saveResponse.statusCode == 200 ? "Success" : "Error"),
        content: Text(saveResponse.statusCode == 200
            ? "The task have been saved successfully."
            : "Something gone Wrong. Try Again Later"),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Okay'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 4.0,
        automaticallyImplyLeading: false,
        leading: IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: primaryBackground,
              size: 25.0,
            )),
        centerTitle: true,
        title: const Text(
          "Add a new task",
          style: TextStyle(
            color: primaryBackground,
            fontSize: 25.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: paddingValue),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const SizedBox(
                height: 100.0,
              ),
              //Champs pour la saisie de la tache
              TextFormField(
                controller: textFieldControlller,
                decoration: const InputDecoration(
                  hintText: 'Enter your task',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(15.0)),
                  ),
                ),
                validator: (String? value) {
                  if (value == null || value.isEmpty) {
                    return 'Please fill the input field';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15.0),
              // Dropdown Button for 'Categories' Selection
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(15.0)),
                  border: Border.all(width: 1.0, color: Colors.black),
                ),
                child: DropdownButton<Categories>(
                  value: selectedCategory,
                  icon: const Icon(Icons.arrow_downward),
                  elevation: 16,
                  underline: Container(
                    height: 2,
                    color: Colors.transparent,
                  ),
                  onChanged: (Categories? value) {
                    // This is called when the user selects an item.
                    setState(() {
                      selectedCategory = value!;
                    });
                  },
                  items: categories
                      .map<DropdownMenuItem<Categories>>((Categories value) {
                    return DropdownMenuItem<Categories>(
                      value: value,
                      child: Text(value.name),
                    );
                  }).toList(),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Construction de l'objet Task à envoyer au serveur pour enregistrer une tache
                      Task newTask = Task(
                          category: selectedCategory,
                          title: textFieldControlller.text,
                          isDone: false);
                      // Method Call for Saving the Task
                      _saveTask(newTask, context);
                    }
                  },
                  child: isLoading
                      ? CircularProgressIndicator(
                          color: Colors.white.withOpacity(.1))
                      : const Text('Submit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
