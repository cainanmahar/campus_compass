// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) { 
    return MaterialApp(
      // property to specify the user interface
      title: 'Class Schedule',
      theme: ThemeData(
        // This is the theme of your application.
        primaryColor: const Color.fromARGB(255, 0, 73, 144),

        colorScheme:
            ColorScheme.fromSwatch(
              primarySwatch: Colors.blue,
              backgroundColor: Colors.white,
            ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: const Color.fromARGB(255, 0, 73, 144)
        ),
      ),
      home: const AddClassSchedule(title: "Class Schedule"),
    );
  }
}

class AddClassSchedule extends StatefulWidget {
  const AddClassSchedule({super.key, required this.title});

  final String title;

  @override
  State<AddClassSchedule> createState() => _AddClassScheduleState();
}


class _AddClassScheduleState extends State<AddClassSchedule> {
  @override
  Widget build(BuildContext context) {
    return Scaffold( // has two properties - body and appBar
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 73, 144), // color of body of scaffold
        title: Text(widget.title),
        actions: <Widget>[
          Row(
            children: [
              InkWell( // our + button
                onTap: () {
                  print("edit Icon Tapped");
                },
                child: Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.edit),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: SizedBox(
                  height: kToolbarHeight,
                  child: Image.asset(
                    'assets/images/SHSU_Primary_Logo.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ), 
        ],
      ),
      body: Stack(
        children: <Widget>[
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'This is a test field',
                ),
              ],
            ), // Existing centered content
          ),
          Align( // New aligned icon
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  showDialog( // function that shows our pop up dialog box
                    context: context, // context of our current screen
                    builder: (context){
                      return AlertDialog(
                        title: Text('Add a Class'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField( // Our course field
                              decoration:  InputDecoration(labelText: 'Course Name'),
                            ),
                            TextFormField( // Our course field
                              decoration:  InputDecoration(labelText: 'Course Number'),
                            ),
                            TextFormField( // Our course field
                              decoration:  InputDecoration(labelText: 'Course Building'),
                            ),
                            TextFormField( // Our course field
                              decoration:  InputDecoration(labelText: 'Course Room Number'),
                            ),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // close the dialog
                            }, 
                            child: Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // close the dialog
                              }, 
                            child: Text('Add Class'),
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Image.asset(
                  'assets/images/paw_thick.png',
                  width: 100.0,
                  height: 100.0,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}