import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:webview_flutter/webview_flutter.dart';

import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  tz.initializeTimeZones();

  runApp(const ChecklistApp());
}

class ChecklistApp extends StatelessWidget {

  const ChecklistApp({super.key});

  @override
  Widget build(BuildContext context) {

    return MaterialApp(

      debugShowCheckedModeBanner: false,

      theme: ThemeData(

        useMaterial3: true,

        colorSchemeSeed: Colors.purple,
      ),

      home: const HomeScreen(),
    );
  }
}

class Task {

  String id;

  String category;

  String checklist;

  String priority;

  Task({

    required this.id,

    required this.category,

    required this.checklist,

    required this.priority,
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

  final FlutterLocalNotificationsPlugin
      notifications =
      FlutterLocalNotificationsPlugin();

  // PASTE YOUR APPS SCRIPT URL HERE
  final String apiUrl =
      "https://script.google.com/macros/s/AKfycbzbrzhrWX6w7V_n8oTmrqkn0tiHxf5ZhwxbD-riZ9IXPUOqHtjQ7yokRMbQxltXalg6/exec";

  int selectedIndex = 0;

  List<Task> tasks = [];

  List<Task> completedTasks = [];

  List<Task> pendingTasks = [];

  @override
  void initState() {

    super.initState();

    initializeNotifications();

    fetchTasks();
  }

  Future<void>
      initializeNotifications() async {

    const AndroidInitializationSettings
        androidSettings =
        AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const InitializationSettings
        settings =
        InitializationSettings(
      android: androidSettings,
    );

    await notifications.initialize(
      settings,
    );
  }

  Future<void> fetchTasks() async {

    try {

      final response =
          await http.get(
        Uri.parse(apiUrl),
      );

      print(response.body);

      if (response.statusCode ==
          200) {

        final List<dynamic> data =
            jsonDecode(response.body);

        List<Task> loadedTasks =
            [];

        for (var item in data) {

          loadedTasks.add(

            Task(

              id:
                  item['id']
                      .toString(),

              category:
                  item['category']
                      .toString(),

              checklist:
                  item['checklist']
                      .toString(),

              priority:
                  item['priority']
                      .toString(),
            ),
          );
        }

        setState(() {

          tasks = loadedTasks;
        });
      }

    } catch (e) {

      print("FETCH ERROR");

      print(e);
    }
  }

  Future<void> addTask(

    String category,

    String checklist,

    String priority,

  ) async {

    try {

      Task task = Task(

        id:
            DateTime.now()
                .millisecondsSinceEpoch
                .toString(),

        category: category,

        checklist: checklist,

        priority: priority,
      );

      setState(() {

        tasks.add(task);
      });

      await http.post(

        Uri.parse(apiUrl),

        headers: {

          "Content-Type":
              "application/json",
        },

        body: jsonEncode({

          "category": category,

          "checklist": checklist,

          "priority": priority,
        }),
      );

    } catch (e) {

      print(e);
    }
  }

  bool containsLink(
    String text,
  ) {

    return text.contains("http://") ||
        text.contains("https://") ||
        text.contains("www.");
  }

  String extractLink(
    String text,
  ) {

    RegExp exp = RegExp(

      r'(https?:\/\/[^\s]+)',

      caseSensitive: false,
    );

    Match? match =
        exp.firstMatch(text);

    return match?.group(0) ?? "";
  }

  Widget buildChip(

    String title,

    int count,

    Color color,

  ) {

    return Container(

      padding:
          const EdgeInsets.symmetric(

        horizontal: 14,

        vertical: 10,
      ),

      decoration: BoxDecoration(

        color: color.withOpacity(
            0.12),

        borderRadius:
            BorderRadius.circular(18),
      ),

      child: Row(

        mainAxisSize:
            MainAxisSize.min,

        children: [

          Text(

            title,

            style: TextStyle(
              color: color,
            ),
          ),

          const SizedBox(width: 8),

          CircleAvatar(

            radius: 11,

            backgroundColor:
                color,

            child: Text(

              "$count",

              style:
                  const TextStyle(

                fontSize: 11,

                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildHomeScreen() {

    return SafeArea(

      child: Padding(

        padding:
            const EdgeInsets.all(
                20),

        child: Column(

          children: [

            Row(

              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,

              children: [

                const Text(

                  "CHECKLIST PRO",

                  style: TextStyle(

                    fontSize: 30,

                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                ElevatedButton.icon(

                  onPressed: () {

                    fetchTasks();
                  },

                  icon:
                      const Icon(
                    Icons.refresh,
                  ),

                  label:
                      const Text(
                    "Refresh",
                  ),
                ),
              ],
            ),

            const SizedBox(
                height: 20),

            Wrap(

              spacing: 10,

              runSpacing: 10,

              children: [

                buildChip(

                  "Tasks",

                  tasks.length,

                  Colors.purple,
                ),

                buildChip(

                  "Completed",

                  completedTasks
                      .length,

                  Colors.green,
                ),

                buildChip(

                  "Later",

                  pendingTasks
                      .length,

                  Colors.orange,
                ),
              ],
            ),

            const SizedBox(
                height: 25),

            Expanded(

              child: tasks.isEmpty

                  ? const Center(

                      child: Text(

                        "No Tasks Found",

                        style:
                            TextStyle(

                          fontSize: 24,

                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    )

                  : PageView.builder(

                      controller:
                          PageController(
                        viewportFraction:
                            0.92,
                      ),

                      itemCount:
                          tasks.length,

                      itemBuilder:
                          (context, index) {

                        Task task =
                            tasks[index];

                        return Padding(

                          padding:
                              const EdgeInsets.only(
                                  right:
                                      10),

                          child:
                              Dismissible(

                            key: Key(
                              task.id,
                            ),

                            background:
                                Container(

                              alignment:
                                  Alignment
                                      .centerLeft,

                              padding:
                                  const EdgeInsets
                                          .only(
                                      left:
                                          30),

                              decoration:
                                  BoxDecoration(

                                color:
                                    Colors
                                        .green,

                                borderRadius:
                                    BorderRadius.circular(
                                        28),
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
                                      FontWeight.bold,
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
                                      right:
                                          30),

                              decoration:
                                  BoxDecoration(

                                color:
                                    Colors
                                        .orange,

                                borderRadius:
                                    BorderRadius.circular(
                                        28),
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
                                      FontWeight.bold,
                                ),
                              ),
                            ),

                            onDismissed:
                                (direction) {

                              if (direction ==
                                  DismissDirection
                                      .startToEnd) {

                                setState(() {

                                  completedTasks
                                      .add(
                                          task);

                                  tasks.remove(
                                      task);
                                });

                              } else {

                                setState(() {

                                  pendingTasks
                                      .add(
                                          task);

                                  tasks.remove(
                                      task);
                                });
                              }
                            },

                            child:
                                Container(

                              height: 520,

                              padding:
                                  const EdgeInsets
                                          .all(
                                      25),

                              decoration:
                                  BoxDecoration(

                                gradient:
                                    LinearGradient(

                                  colors: [

                                    Colors
                                        .purple
                                        .shade100,

                                    Colors
                                        .white,
                                  ],
                                ),

                                borderRadius:
                                    BorderRadius.circular(
                                        30),

                                boxShadow: [

                                  BoxShadow(

                                    color: Colors
                                        .black
                                        .withOpacity(
                                            0.06),

                                    blurRadius:
                                        12,

                                    offset:
                                        const Offset(
                                            0,
                                            5),
                                  ),
                                ],
                              ),

                              child:
                                  Column(

                                crossAxisAlignment:
                                    CrossAxisAlignment
                                        .start,

                                children: [

                                  Container(

                                    padding:
                                        const EdgeInsets.symmetric(

                                      horizontal:
                                          16,

                                      vertical:
                                          8,
                                    ),

                                    decoration:
                                        BoxDecoration(

                                      color:
                                          Colors
                                              .purple,

                                      borderRadius:
                                          BorderRadius.circular(
                                              20),
                                    ),

                                    child:
                                        Text(

                                      task.category,

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors.white,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const Spacer(),

                                  Text(

                                    task.checklist,

                                    style:
                                        const TextStyle(

                                      fontSize:
                                          28,

                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          22),

                                  Container(

                                    padding:
                                        const EdgeInsets.symmetric(

                                      horizontal:
                                          14,

                                      vertical:
                                          8,
                                    ),

                                    decoration:
                                        BoxDecoration(

                                      color:
                                          Colors.red,

                                      borderRadius:
                                          BorderRadius.circular(
                                              20),
                                    ),

                                    child:
                                        Text(

                                      "Priority ${task.priority}",

                                      style:
                                          const TextStyle(

                                        color:
                                            Colors.white,

                                        fontWeight:
                                            FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(
                                      height:
                                          20),

                                  if (
                                    containsLink(
                                      task
                                          .checklist,
                                    )
                                  )

                                    ElevatedButton.icon(

                                      onPressed:
                                          () {

                                        Navigator.push(

                                          context,

                                          MaterialPageRoute(

                                            builder:
                                                (_) => WebViewScreen(

                                              url:
                                                  extractLink(
                                                task.checklist,
                                              ),
                                            ),
                                          ),
                                        );
                                      },

                                      icon:
                                          const Icon(Icons.link),

                                      label:
                                          const Text(
                                        "Open Link",
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
                                      height:
                                          8),

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
            const EdgeInsets.all(
                20),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            const Text(

              "Analytics",

              style: TextStyle(

                fontSize: 32,

                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
                height: 40),

            SizedBox(

              height: 300,

              child: BarChart(

                BarChartData(

                  maxY: 100,

                  barGroups: [

                    BarChartGroupData(
                      x: 1,
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

                    BarChartGroupData(
                      x: 2,
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
                      x: 3,
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
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildSimplePage(
    List<Task> list,
    Color color,
  ) {

    return SafeArea(

      child: ListView.builder(

        padding:
            const EdgeInsets.all(
                20),

        itemCount: list.length,

        itemBuilder:
            (context, index) {

          Task task =
              list[index];

          return Container(

            margin:
                const EdgeInsets.only(
                    bottom: 15),

            padding:
                const EdgeInsets.all(
                    20),

            decoration:
                BoxDecoration(

              color:
                  color.withOpacity(
                      0.1),

              borderRadius:
                  BorderRadius
                      .circular(22),
            ),

            child: Column(

              crossAxisAlignment:
                  CrossAxisAlignment
                      .start,

              children: [

                Text(

                  task.category,

                  style:
                      const TextStyle(

                    fontWeight:
                        FontWeight.bold,

                    fontSize: 18,
                  ),
                ),

                const SizedBox(
                    height: 10),

                Text(

                  task.checklist,

                  style:
                      const TextStyle(

                    fontSize: 20,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    List<Widget> screens = [

      buildHomeScreen(),

      buildAnalyticsScreen(),

      buildSimplePage(
        pendingTasks,
        Colors.orange,
      ),

      buildSimplePage(
        completedTasks,
        Colors.green,
      ),
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
              categoryController =
              TextEditingController();

          TextEditingController
              checklistController =
              TextEditingController();

          TextEditingController
              priorityController =
              TextEditingController();

          showDialog(

            context: context,

            builder: (_) {

              return AlertDialog(

                title:
                    const Text(
                  "Add Task",
                ),

                content:
                    SingleChildScrollView(

                  child: Column(

                    mainAxisSize:
                        MainAxisSize.min,

                    children: [

                      TextField(

                        controller:
                            categoryController,

                        decoration:
                            const InputDecoration(

                          hintText:
                              "Category",
                        ),
                      ),

                      const SizedBox(
                          height: 15),

                      TextField(

                        controller:
                            checklistController,

                        maxLines: 5,

                        decoration:
                            const InputDecoration(

                          hintText:
                              "Checklist / Link",
                        ),
                      ),

                      const SizedBox(
                          height: 15),

                      TextField(

                        controller:
                            priorityController,

                        decoration:
                            const InputDecoration(

                          hintText:
                              "Priority",
                        ),
                      ),
                    ],
                  ),
                ),

                actions: [

                  ElevatedButton(

                    onPressed: () {

                      addTask(

                        categoryController
                            .text,

                        checklistController
                            .text,

                        priorityController
                            .text,
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
          NavigationBar(

        selectedIndex:
            selectedIndex,

        onDestinationSelected:
            (index) {

          setState(() {

            selectedIndex =
                index;
          });
        },

        destinations: const [

          NavigationDestination(

            icon:
                Icon(Icons.home),

            label: "Home",
          ),

          NavigationDestination(

            icon:
                Icon(Icons.bar_chart),

            label:
                "Analytics",
          ),

          NavigationDestination(

            icon:
                Icon(Icons.pending),

            label: "Later",
          ),

          NavigationDestination(

            icon:
                Icon(Icons.done),

            label:
                "Completed",
          ),
        ],
      ),
    );
  }
}

class WebViewScreen
    extends StatelessWidget {

  final String url;

  const WebViewScreen({

    super.key,

    required this.url,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(),

      body: WebViewWidget(

        controller:
            WebViewController()

              ..loadRequest(
                Uri.parse(url),
              ),
      ),
    );
  }
}