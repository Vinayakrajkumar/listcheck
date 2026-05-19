import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  runApp(const ChecklistApp());
}

class ChecklistApp extends StatelessWidget {
  const ChecklistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState
    extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: const [
            Icon(
              Icons.task_alt,
              size: 120,
              color: Colors.purple,
            ),
            SizedBox(height: 20),
            Text(
              "CHECKLIST PRO",
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Task {
  String title;
  String tag;
  Color color;

  Task({
    required this.title,
    required this.tag,
    required this.color,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() =>
      _HomeScreenState();
}

class _HomeScreenState
    extends State<HomeScreen> {
  int streak = 0;

  List<Task> tasks = [
    Task(
      title:
          "Dashboard design for admin",
      tag: "High",
      color: Colors.pinkAccent,
    ),
    Task(
      title:
          "Konom web application",
      tag: "Low",
      color: Colors.green,
    ),
    Task(
      title:
          "Research and development",
      tag: "Medium",
      color: Colors.orange,
    ),
    Task(
      title:
          "Event booking application",
      tag: "Medium",
      color: Colors.purple,
    ),
  ];

  List<Task> completedTasks = [];

  List<Task> pendingTasks = [];

  @override
  void initState() {
    super.initState();

    loadStreak();
  }

  Future<void> loadStreak() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    streak = prefs.getInt('streak') ?? 0;

    setState(() {});
  }

  Future<void> saveStreak() async {
    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    await prefs.setInt('streak', streak);
  }

  void completeTask(Task task) async {
    setState(() {
      completedTasks.add(task);

      tasks.remove(task);

      streak++;
    });

    saveStreak();
  }

  void laterTask(Task task) {
    setState(() {
      pendingTasks.add(task);

      tasks.remove(task);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,

        title: Row(
          children: [
            Container(
              padding:
                  const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.purple.shade100,
                borderRadius:
                    BorderRadius.circular(
                        12),
              ),
              child: const Icon(
                Icons.task,
                color: Colors.purple,
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              "Task List",
              style: TextStyle(
                color: Colors.black,
                fontWeight:
                    FontWeight.bold,
                fontSize: 28,
              ),
            ),
          ],
        ),

        actions: [
          CircleAvatar(
            backgroundColor:
                Colors.white,
            child: Icon(
              Icons.arrow_outward,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 10),

          CircleAvatar(
            backgroundColor:
                Colors.white,
            child: Icon(
              Icons.more_vert,
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 15),
        ],
      ),

      body: Padding(
        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),

        child: Column(
          children: [

            const SizedBox(height: 10),

            Row(
              children: [

                buildTopChip(
                  "Complete",
                  completedTasks.length,
                  Colors.green,
                ),

                const SizedBox(width: 10),

                buildTopChip(
                  "To Do",
                  tasks.length,
                  Colors.orange,
                ),

                const SizedBox(width: 10),

                buildTopChip(
                  "In Review",
                  pendingTasks.length,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 25),

            Expanded(
              child: tasks.isEmpty
                  ? const Center(
                      child: Text(
                        "All Tasks Completed",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    )
                  : PageView.builder(
                      controller:
                          PageController(
                        viewportFraction:
                            0.93,
                      ),

                      itemCount:
                          tasks.length,

                      itemBuilder:
                          (context, index) {

                        final task =
                            tasks[index];

                        return Dismissible(

                          key:
                              Key(task.title),

                          background:
                              Container(
                            alignment:
                                Alignment
                                    .centerLeft,

                            padding:
                                const EdgeInsets
                                        .only(
                                    left: 30),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.green,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          25),
                            ),

                            child:
                                const Text(
                              "COMPLETED",

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,

                                fontSize:
                                    22,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),

                          secondaryBackground:
                              Container(
                            alignment:
                                Alignment
                                    .centerRight,

                            padding:
                                const EdgeInsets
                                        .only(
                                    right: 30),

                            decoration:
                                BoxDecoration(
                              color:
                                  Colors.orange,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          25),
                            ),

                            child:
                                const Text(
                              "DO LATER",

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,

                                fontSize:
                                    22,

                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ),

                          onDismissed:
                              (direction) {

                            if (direction ==
                                DismissDirection
                                    .startToEnd) {

                              completeTask(
                                  task);

                            } else {

                              laterTask(
                                  task);
                            }
                          },

                          child:
                              Container(

                            margin:
                                const EdgeInsets
                                        .only(
                                    bottom:
                                        20),

                            padding:
                                const EdgeInsets
                                        .all(
                                    20),

                            decoration:
                                BoxDecoration(
                              color:
                                  task.color
                                      .withOpacity(
                                          0.15),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          25),

                              border:
                                  Border.all(
                                color:
                                    Colors.black
                                        .withOpacity(
                                            0.08),
                              ),
                            ),

                            child:
                                Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Row(

                                  mainAxisAlignment:
                                      MainAxisAlignment
                                          .spaceBetween,

                                  children: [

                                    buildTag(
                                      task.tag,
                                      task.color,
                                    ),

                                    const Icon(
                                      Icons
                                          .more_horiz,
                                      color:
                                          Colors.black54,
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height:
                                        25),

                                Text(
                                  task.title,

                                  style:
                                      const TextStyle(
                                    fontSize:
                                        28,

                                    fontWeight:
                                        FontWeight
                                            .bold,

                                    color:
                                        Colors.black,
                                  ),
                                ),

                                const Spacer(),

                                Row(
                                  children: [

                                    const Icon(
                                      Icons
                                          .calendar_today,

                                      size:
                                          18,
                                    ),

                                    const SizedBox(
                                        width:
                                            8),

                                    const Text(
                                      "14 Oct 2024",
                                    ),

                                    const Spacer(),

                                    const Icon(
                                      Icons.link,
                                      size: 18,
                                    ),

                                    const SizedBox(
                                        width:
                                            5),

                                    Text(
                                      "$streak",
                                    ),
                                  ],
                                ),

                                const SizedBox(
                                    height:
                                        20),

                                const Text(
                                  "Swipe Right → Complete",

                                  style:
                                      TextStyle(
                                    color:
                                        Colors.green,
                                  ),
                                ),

                                const SizedBox(
                                    height:
                                        5),

                                const Text(
                                  "Swipe Left ← Do Later",

                                  style:
                                      TextStyle(
                                    color:
                                        Colors.orange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor: Colors.purple,

        child: const Icon(Icons.add),

        onPressed: () {

          TextEditingController
              controller =
              TextEditingController();

          showDialog(
            context: context,

            builder: (_) {

              return AlertDialog(

                shape:
                    RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(
                          20),
                ),

                title:
                    const Text("Add Task"),

                content:
                    TextField(
                  controller:
                      controller,
                ),

                actions: [

                  ElevatedButton(

                    onPressed: () {

                      if (controller
                          .text
                          .isNotEmpty) {

                        setState(() {

                          tasks.add(

                            Task(
                              title:
                                  controller
                                      .text,

                              tag:
                                  "New",

                              color:
                                  Colors.blue,
                            ),
                          );
                        });
                      }

                      Navigator.pop(
                          context);
                    },

                    child:
                        const Text(
                            "Add"),
                  ),
                ],
              );
            },
          );
        },
      ),

      bottomNavigationBar:
          Container(

        height: 80,

        padding:
            const EdgeInsets.symmetric(
          horizontal: 20,
        ),

        child: Row(

          mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,

          children: [

            const Icon(
              Icons.grid_view_rounded,
              size: 30,
            ),

            Container(

              padding:
                  const EdgeInsets.symmetric(
                horizontal: 25,
                vertical: 12,
              ),

              decoration: BoxDecoration(
                color: Colors.black,

                borderRadius:
                    BorderRadius.circular(
                        25),
              ),

              child: Row(
                children: const [

                  Icon(
                    Icons.task_alt,
                    color: Colors.white,
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Task",

                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.bar_chart,
              size: 30,
            ),

            const CircleAvatar(
              backgroundImage:
                  NetworkImage(
                "https://i.pravatar.cc/150?img=3",
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTopChip(
    String title,
    int count,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),

      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black12,
        ),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(
        children: [

          Text(
            title,
            style: const TextStyle(
              color: Colors.black,
            ),
          ),

          const SizedBox(width: 10),

          CircleAvatar(
            radius: 11,
            backgroundColor: color,

            child: Text(
              "$count",

              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTag(
    String text,
    Color color,
  ) {
    return Container(
      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 8,
      ),

      decoration: BoxDecoration(
        color: color,

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        text,

        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}