import 'dart:async';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        scaffoldBackgroundColor: Colors.white,
        fontFamily: "Roboto",
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

    Timer(
      const Duration(seconds: 2),
      () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) =>
                const HomeScreen(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
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
                fontWeight:
                    FontWeight.bold,
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
  String status;

  Task({
    required this.title,
    required this.status,
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

  late Box taskBox;

  int selectedIndex = 0;

  int streak = 0;

  List<Task> tasks = [];

  List<Task> completedTasks = [];

  List<Task> pendingTasks = [];

  @override
  void initState() {
    super.initState();

    initializeApp();
  }

  Future<void> initializeApp() async {

    taskBox =
        await Hive.openBox("tasks");

    loadTasks();

    loadStreak();
  }

  Future<void> loadStreak() async {

    SharedPreferences prefs =
        await SharedPreferences
            .getInstance();

    streak =
        prefs.getInt("streak") ?? 0;

    setState(() {});
  }

  Future<void> saveStreak() async {

    SharedPreferences prefs =
        await SharedPreferences
            .getInstance();

    prefs.setInt("streak", streak);
  }

  void loadTasks() {

    List saved = taskBox.get(
      "allTasks",
      defaultValue: [],
    );

    tasks = saved
        .map<Task>(
          (e) => Task(
            title: e,
            status: "Pending",
          ),
        )
        .toList();

    setState(() {});
  }

  void saveTasks() {

    List<String> titles =
        tasks
            .map((e) => e.title)
            .toList();

    taskBox.put("allTasks", titles);
  }

  void completeTask(Task task) {

    setState(() {

      completedTasks.add(task);

      tasks.remove(task);

      streak++;
    });

    saveTasks();

    saveStreak();
  }

  void laterTask(Task task) {

    setState(() {

      pendingTasks.add(task);

      tasks.remove(task);
    });

    saveTasks();
  }

  void addBulkTasks(
      String rawText) {

    List<String> separatedTasks =
        rawText
            .split(RegExp(r'[\n,]'));

    setState(() {

      for (String t
          in separatedTasks) {

        if (t
            .trim()
            .isNotEmpty) {

          tasks.add(
            Task(
              title: t.trim(),
              status: "Pending",
            ),
          );
        }
      }
    });

    saveTasks();
  }

  Widget buildHomeScreen() {

    return SafeArea(

      child: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          children: [

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(
                  "Task List",

                  style: TextStyle(
                    fontSize: 32,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                CircleAvatar(
                  backgroundColor:
                      Colors.purple
                          .shade100,

                  child: Text(
                    "$streak🔥",

                    style:
                        const TextStyle(
                      color:
                          Colors.black,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(

              children: [

                buildChip(
                  "Complete",
                  completedTasks.length,
                  Colors.green,
                ),

                const SizedBox(width: 10),

                buildChip(
                  "Pending",
                  pendingTasks.length,
                  Colors.orange,
                ),

                const SizedBox(width: 10),

                buildChip(
                  "Tasks",
                  tasks.length,
                  Colors.purple,
                ),
              ],
            ),

            const SizedBox(height: 25),

            Expanded(

              child: tasks.isEmpty

                  ? const Center(
                      child: Text(
                        "No Tasks",
                        style: TextStyle(
                          fontSize: 28,
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

                        Task task =
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
                                          30),
                            ),

                            child:
                                const Text(
                              "COMPLETED",

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,

                                fontSize:
                                    24,

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
                                          30),
                            ),

                            child:
                                const Text(
                              "DO LATER",

                              style:
                                  TextStyle(
                                color:
                                    Colors.white,

                                fontSize:
                                    24,

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
                                    25),

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors.purple
                                      .shade50,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          30),
                            ),

                            child:
                                Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Container(

                                  padding:
                                      const EdgeInsets
                                              .symmetric(
                                    horizontal:
                                        15,

                                    vertical:
                                        8,
                                  ),

                                  decoration:
                                      BoxDecoration(

                                    color:
                                        Colors
                                            .purple,

                                    borderRadius:
                                        BorderRadius
                                            .circular(
                                                20),
                                  ),

                                  child:
                                      const Text(
                                    "TASK",

                                    style:
                                        TextStyle(
                                      color:
                                          Colors
                                              .white,
                                    ),
                                  ),
                                ),

                                const Spacer(),

                                Text(
                                  task.title,

                                  style:
                                      const TextStyle(
                                    fontSize:
                                        30,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const Spacer(),

                                const Text(
                                  "Swipe Right → Complete",

                                  style:
                                      TextStyle(
                                    color:
                                        Colors.green,
                                  ),
                                ),

                                const SizedBox(
                                    height: 8),

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
    );
  }

  Widget buildAnalyticsScreen() {

    return SafeArea(

      child: Padding(

        padding:
            const EdgeInsets.all(20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Analytics",

              style: TextStyle(
                fontSize: 32,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(

              height: 300,

              child: BarChart(

                BarChartData(

                  alignment:
                      BarChartAlignment
                          .spaceAround,

                  maxY: 20,

                  barGroups: [

                    BarChartGroupData(
                      x: 1,

                      barRods: [

                        BarChartRodData(
                          toY:
                              completedTasks
                                  .length
                                  .toDouble(),

                          color:
                              Colors.green,

                          width: 30,
                        ),
                      ],
                    ),

                    BarChartGroupData(
                      x: 2,

                      barRods: [

                        BarChartRodData(
                          toY:
                              pendingTasks
                                  .length
                                  .toDouble(),

                          color:
                              Colors.orange,

                          width: 30,
                        ),
                      ],
                    ),

                    BarChartGroupData(
                      x: 3,

                      barRods: [

                        BarChartRodData(
                          toY:
                              tasks.length
                                  .toDouble(),

                          color:
                              Colors.purple,

                          width: 30,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),

            buildAnalyticsTile(
              "Completed Tasks",
              completedTasks.length,
              Colors.green,
            ),

            buildAnalyticsTile(
              "Pending Tasks",
              pendingTasks.length,
              Colors.orange,
            ),

            buildAnalyticsTile(
              "Current Tasks",
              tasks.length,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPendingScreen() {

    return SafeArea(

      child: ListView.builder(

        padding:
            const EdgeInsets.all(20),

        itemCount:
            pendingTasks.length,

        itemBuilder:
            (context, index) {

          return buildSimpleTile(
            pendingTasks[index].title,
            Colors.orange,
          );
        },
      ),
    );
  }

  Widget buildCompletedScreen() {

    return SafeArea(

      child: ListView.builder(

        padding:
            const EdgeInsets.all(20),

        itemCount:
            completedTasks.length,

        itemBuilder:
            (context, index) {

          return buildSimpleTile(
            completedTasks[index].title,
            Colors.green,
          );
        },
      ),
    );
  }

  Widget buildSimpleTile(
      String text,
      Color color) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 15),

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
            color.withOpacity(0.12),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Text(
        text,

        style: const TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildChip(
      String title,
      int count,
      Color color) {

    return Container(

      padding:
          const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 10,
      ),

      decoration: BoxDecoration(

        borderRadius:
            BorderRadius.circular(20),

        border: Border.all(
          color: Colors.black12,
        ),
      ),

      child: Row(

        children: [

          Text(title),

          const SizedBox(width: 10),

          CircleAvatar(
            radius: 10,

            backgroundColor:
                color,

            child: Text(
              "$count",

              style:
                  const TextStyle(
                fontSize: 12,
                color:
                    Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildAnalyticsTile(
      String title,
      int count,
      Color color) {

    return Container(

      margin:
          const EdgeInsets.only(
              bottom: 20),

      padding:
          const EdgeInsets.all(20),

      decoration: BoxDecoration(

        color:
            color.withOpacity(0.12),

        borderRadius:
            BorderRadius.circular(20),
      ),

      child: Row(

        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [

          Text(
            title,

            style: const TextStyle(
              fontSize: 20,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            "$count",

            style: const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> screens = [

      buildHomeScreen(),

      buildAnalyticsScreen(),

      buildPendingScreen(),

      buildCompletedScreen(),
    ];

    return Scaffold(

      body:
          screens[selectedIndex],

      floatingActionButton:
          FloatingActionButton(

        backgroundColor:
            Colors.purple,

        child:
            const Icon(Icons.add),

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
                          25),
                ),

                title:
                    const Text(
                  "Add Tasks",
                ),

                content:
                    SizedBox(

                  width:
                      double.maxFinite,

                  child:
                      TextField(

                    controller:
                        controller,

                    maxLines: 10,

                    decoration:
                        const InputDecoration(

                      hintText:
                          "Paste CSV / Sheet / Manual Tasks\n\nEach line or comma becomes separate card",

                      border:
                          OutlineInputBorder(),
                    ),
                  ),
                ),

                actions: [

                  ElevatedButton(

                    onPressed: () {

                      addBulkTasks(
                        controller.text,
                      );

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
          SafeArea(

        child: Container(

          height: 75,

          padding:
              const EdgeInsets.symmetric(
            horizontal: 10,
          ),

          child: Row(

            mainAxisAlignment:
                MainAxisAlignment
                    .spaceAround,

            children: [

              navButton(
                Icons.home,
                0,
              ),

              navButton(
                Icons.bar_chart,
                1,
              ),

              navButton(
                Icons.pending_actions,
                2,
              ),

              navButton(
                Icons.done_all,
                3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget navButton(
      IconData icon,
      int index) {

    bool isSelected =
        selectedIndex == index;

    return GestureDetector(

      onTap: () {

        setState(() {

          selectedIndex =
              index;
        });
      },

      child: Container(

        padding:
            const EdgeInsets.all(15),

        decoration: BoxDecoration(

          color: isSelected
              ? Colors.purple
              : Colors.transparent,

          borderRadius:
              BorderRadius.circular(20),
        ),

        child: Icon(
          icon,

          color: isSelected
              ? Colors.white
              : Colors.black,
        ),
      ),
    );
  }
}