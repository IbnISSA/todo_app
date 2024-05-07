import 'dart:convert' as convert;

import 'package:flutter/material.dart';
import 'package:todo_app/common/block_title.dart';
import 'package:todo_app/common/categories.dart';
import 'package:todo_app/common/commons.dart';
import 'package:todo_app/common/slider_item.dart';
import 'package:todo_app/common/task_item.dart';
import "package:http/http.dart" as http;
import 'package:todo_app/models/task.dart';

var taskListUrl = Uri.http('192.168.1.14:8080', '/tasks');

Future _fecthTasks() {
  return http.get(taskListUrl);
}

class HomeScreen extends StatefulWidget {
  final Duration duration;
  final bool isClosed;
  final AnimationController animationController;
  final Animation<double> scaleAnimation;
  final VoidCallback toggleMenu;

  const HomeScreen({
    super.key,
    required this.duration,
    required this.isClosed,
    required this.animationController,
    required this.scaleAnimation,
    required this.toggleMenu,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    return AnimatedPositioned(
      duration: widget.duration,
      top: 0.0,
      bottom: 0.0,
      left: widget.isClosed ? 0.0 : .7 * screenWidth,
      right: widget.isClosed ? 0.0 : -screenWidth,
      child: ScaleTransition(
        scale: widget.scaleAnimation,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          floatingActionButton: FloatingActionButton(
            onPressed: () => print("Add Button Pressed"),
            backgroundColor: businessIndicator,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add_rounded,
              color: Colors.white,
              size: 35.0,
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                  Radius.circular(widget.isClosed ? 0.0 : 50.0)),
              color: secondaryBackground,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 50.0,
                ),
                //L'en-tête avec les icônes
                Padding(
                  padding:
                      const EdgeInsets.only(right: paddingValue, left: 12.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: widget.toggleMenu,
                        icon: Icon(Icons.menu_rounded,
                            size: iconSize, color: iconColor),
                      ),
                      Expanded(child: Container()),
                      Icon(Icons.search_rounded,
                          size: iconSize, color: iconColor),
                      const SizedBox(width: 15.0),
                      Icon(Icons.notifications_none_rounded,
                          size: iconSize, color: iconColor),
                    ],
                  ),
                ),
                const SizedBox(height: 30.0),
                // Texte de Bienvenue
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: paddingValue),
                  child: Text(
                    "What's up, Doudou!",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 38.0,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(height: 30.0),
                // Block categories title
                const BlockTitle(
                  title: "Categories",
                ),
                // Slider items
                SizedBox(
                  height: 150.0,
                  child: ListView(
                    padding:
                        const EdgeInsets.only(left: paddingValue, right: 10.0),
                    scrollDirection: Axis.horizontal,
                    children: const [
                      //slider item Business
                      SliderItem(
                        category: Categories.Business,
                        progress: .6,
                        tasksNumber: 40,
                      ),
                      SizedBox(width: 10.0),
                      // slider item Personal
                      SliderItem(
                          category: Categories.Personal,
                          progress: .35,
                          tasksNumber: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 20.0),
                // block Today's Tasks
                const BlockTitle(
                  title: "Today's Tasks",
                ),
                const SizedBox(height: 10.0),
                // Listes des taches
                Expanded(
                    child: FutureBuilder(
                  future: _fecthTasks(),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    List<Widget> content;
                    List<Widget> taskItems = [];
                    // 1er Cas : La réponse vient avec les données
                    if (snapshot.hasData) {
                      if (snapshot.data.statusCode == 200) {
                        for (var jsonItem
                            in convert.jsonDecode(snapshot.data.body)) {
                          taskItems
                              .add(TaskItem(task: Task.fromJson(jsonItem)));
                        }
                        return ListView(
                            padding: const EdgeInsets.symmetric(
                                vertical: 0.0, horizontal: paddingValue),
                            children: taskItems);
                      } else {
                        content = [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: paddingValue),
                            child: Text(
                              'Erreur: Serveur Indisponible avec le code ${snapshot.data.statusCode}.\n Details :${snapshot.data.body}',
                              style: TextStyle(
                                color: iconColor,
                                fontSize: 14.0,
                              ),
                            ),
                          ),
                        ];
                      }
                    }
                    // 2è Cas: une erreur survient
                    else if (snapshot.hasError) {
                      content = [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: paddingValue),
                          child: Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 14.0,
                            ),
                          ),
                        ),
                      ];
                    }
                    // 3è Cas ou Cas par défaut: Notifier le chargement
                    else {
                      content = <Widget>[
                        const SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(
                            color: primaryBackground,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text(
                            'En Attente de résultat...',
                            style: TextStyle(
                              color: iconColor,
                              fontSize: 20.0,
                            ),
                          ),
                        ),
                      ];
                    }
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: content,
                      ),
                    );
                  },
                )),
                const SizedBox(height: 35.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
