import 'package:campus_compass/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:campus_compass/database_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddClassSchedule extends StatefulWidget {
  // stateful constructor for adding class schedules
  const AddClassSchedule({super.key}); // calls parent class constructor

  // title of the app bar
  //final String title = "Class Schedule";

  // create state for this widget
  @override
  State<AddClassSchedule> createState() => _AddClassScheduleState();
}

// private state class for AddClassSchedule widget
class _AddClassScheduleState extends State<AddClassSchedule> {
  // firebase auth instance
  final AuthService authService = AuthService();
  final DatabaseService databaseService = DatabaseService();
  // list to store selected courses
  List<Sections> _selectedCourses = [];
  // lists to store courses and sections fetched from the database
  List<Courses> _fetchedCourses = [];
  List<Sections> _fetchedSections = [];

  // building our main ui
  @override
  void initState() {
    super.initState();
    // call a method to fetch user data from db
    _fetchUserCourses();
    // calls a method to fetch course/section data from the database
    _fetchData();
  }

  void _fetchUserCourses() async {
    User? user = authService.getCurrentUser();
    if (user != null) {
      var userData = await databaseService.getUserData(user.uid);
      if (userData != null) {
        List<dynamic> coursesList = userData['courses'] ?? [];
        _selectedCourses = coursesList
            .map((c) => Sections.fromMap(Map<String, dynamic>.from(c)))
            .toList();
      }
    }
  }

  // method to fetch data from the database
  void _fetchData() async {
    // attempts to fetch course data from the database
    var coursesData = await databaseService.fetchCourses();
    // if fetched successfully, process it
    if (coursesData != null) {
      // temp lists to store fetched data
      List<Courses> fetchedCourses = [];
      List<Sections> fetchedSections = [];
      // iterates through entries of the fetched data
      for (var entry in coursesData.entries) {
        // extracts the key (course number) and value (course data)
        String key = entry.key;
        var data = entry.value;
        // checks if the map is a map and if so casts it to the correct type
        var courseData = data is Map ? Map<String, dynamic>.from(data) : null;
        // if the course data is valid, create a Courses object and add it to the list
        if (courseData != null) {
          fetchedCourses.add(Courses.fromData(key, courseData));
          // fetches sections for each course and adds them to the sections list
          var sectionsList = await databaseService.fetchSections(key);
          for (var sectionData in sectionsList) {
            fetchedSections.add(Sections.fromData(sectionData, key));
          }
        }
      }
      // triggers ui rebuild with new data
      setState(() {
        _fetchedCourses = fetchedCourses;
        _fetchedSections = fetchedSections;
      });
    }
    // debugging
    print('Fetched Courses: $_fetchedCourses');
    print('Fetched Sections: $_fetchedSections');
  }

  void _saveCoursesToDatabase() async {
    // gets user from database
    User? user = authService.getCurrentUser();
    if (user != null) {
      // structure the data we want to save
      List<Map<String, dynamic>> selectedCoursesData =
          _selectedCourses.map((section) {
        return {
          'courseNumber': section.courseNumber,
          'sectionNumber': section.sectionNumber,
          'professorName': section.professorName,
          'building': section.building,
          'roomNumber': section.roomNumber
        };
      }).toList();
      // save the list of courses to the DB
      await databaseService
          .updateUserData(user.uid, {'courses': selectedCoursesData});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[800],
        actions: <Widget>[
          // Existing padding and image
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: SizedBox(
              height: kToolbarHeight,
              child: Image.asset(
                'assets/images/SHSU_Primary_Logo.png', // uni logo
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Add FAQ IconButton
          IconButton(
            onPressed: () {
              // Navigate to the FAQ page when the question mark icon is pressed
              Navigator.pushNamed(context, '/faq');
            },
            icon: const Icon(Icons.question_mark),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Title for add classes screen
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Your Class Schedule',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Click the plus button below to search and add a class to your schedule.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            // listview to display selected courses
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _selectedCourses.length,
              separatorBuilder: (BuildContext context, int index) =>
                  const Divider(
                color: Colors.black,
                thickness: 2,
              ),
              itemBuilder: (BuildContext context, int index) {
                // extracts section and course details for the current index
                Sections section = _selectedCourses[index];
                Courses course = _fetchedCourses
                    .firstWhere((c) => c.courseNumber == section.courseNumber);

                // returns formatted details of the course
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    title: Text(
                      'Course: ${course.courseNumber} | '
                      'Section: ${section.sectionNumber}'
                      '\n${course.className}'
                      '\nBy ${section.professorName}'
                      '\nIn ${section.building}, Room ${section.roomNumber}',
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.orange),
                      onPressed: () {
                        setState(() {
                          _selectedCourses.removeAt(index);
                          _saveCoursesToDatabase();
                        });
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          Align(
            // New aligned icon (+) to the bottom right
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                  // press to display dialog box to add course
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => CourseDialog(
                        onCourseSelected: (selectedCourse) {
                          setState(() {
                            _selectedCourses.add(selectedCourse);
                            // save updated course to database
                            _saveCoursesToDatabase();
                          });
                          Navigator.of(context).pop();
                        },
                        // passes the fetched courses and sections to dialog
                        fetchedCourses: _fetchedCourses,
                        fetchedSections: _fetchedSections,
                      ),
                    );
                  },
                  // displaying the '+' icon
                  child: Icon(Icons.add,
                      color: Colors.lightBlue[800],
                      size: 100.0) // stock '+' icon
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// dialog that is shown when adding a new course
class CourseDialog extends StatelessWidget {
  // callback function to handle when a course is selected
  final Function(Sections) onCourseSelected;
  // lists of fetched courses and sections to display in the dialog
  final List<Courses> fetchedCourses;
  final List<Sections> fetchedSections;

  // constructor for CourseDialog
  const CourseDialog(
      {super.key,
      required this.onCourseSelected,
      required this.fetchedCourses,
      required this.fetchedSections});

  // ui of the dialog
  @override
  Widget build(BuildContext context) {
    print(
        'Options for autocomplete: ${generateCombinedOptions(fetchedSections, fetchedCourses)}'); // debugging
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // header text of the dialog
              const Text('Add a Class',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // auto complete form fields that allow users to search for classes listed in the database, select, then display
              AutoCompleteFormField(
                label: 'Search by Course Number or Class Name',
                // options generated from the combined courses and sections
                options:
                    generateCombinedOptions(fetchedSections, fetchedCourses),
                // call back function when an option is selected
                onOptionSelected: (selection) {
                  // finds the selected section based on the selected option
                  Sections selectedSection = fetchedSections.firstWhere(
                      (section) =>
                          generateOptionString(section, fetchedCourses) ==
                          selection);
                  // executes callback with selected section
                  onCourseSelected(selectedSection);
                },
              ),

              const SizedBox(height: 20),
              Row(
                // row with cancel
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // close the dialog
                    },
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// model class for course details used to work with our test data
class Courses {
  final String courseNumber;
  final String className;

  // constructor for Courses
  Courses({
    required this.courseNumber,
    required this.className,
  });

  // factory constructor that creates a Courses object from a key-value pair of data
  factory Courses.fromData(String key, Map<String, dynamic> data) {
    return Courses(
      courseNumber: key,
      // casts course_name
      className: data['course_name'] as String,
    );
  }
}

// model class to represent section details
class Sections {
  final String courseNumber;
  final int sectionNumber;
  final String professorName;
  final String building;
  final String roomNumber;

  // constructor for Sections
  Sections({
    required this.courseNumber,
    required this.sectionNumber,
    required this.professorName,
    required this.building,
    required this.roomNumber,
  });

  // factory constructor that creates a Sections object from data and a course
  factory Sections.fromData(Map<String, dynamic> data, String courseNumber) {
    int sectionNumber =
        int.tryParse(data['section_number'] as String? ?? '0') ?? 0;
    // returns a new Sections object
    return Sections(
      courseNumber: courseNumber,
      sectionNumber: sectionNumber,
      // gives default values if data not present
      professorName: data['professor'] as String? ?? 'Unknown',
      building: data['building'] as String? ?? 'Unknown',
      roomNumber: data['room_number'] as String? ?? 'Unknown',
    );
  }

  factory Sections.fromMap(Map<String, dynamic> map) {
    return Sections(
      courseNumber: map['courseNumber'] as String? ?? 'Unknown',
      sectionNumber: map['sectionNumber'] as int? ?? 0,
      professorName: map['professorName'] as String? ?? 'Unknown',
      building: map['building'] as String? ?? 'Unknown',
      roomNumber: map['roomNumber'] as String? ?? 'Unknown',
    );
  }
}

// function to generate options for the autocomplete search
List<String> generateCombinedOptions(
    List<Sections> fetchedSections, List<Courses> fetchedCourses) {
  // maps the sections to string representation combining section and course details
  var combinedOptions = fetchedSections
      .map((section) => generateOptionString(section, fetchedCourses))
      .toList();

  print('Combined Options: $combinedOptions'); // debugging
  return combinedOptions;
}

// helper function to format the string for display in autocomplete
String generateOptionString(Sections section, List<Courses> fetchedCourses) {
  // find the corresponding course for the section
  Courses course = fetchedCourses.firstWhere(
    (c) => c.courseNumber == section.courseNumber,
    orElse: () {
      print(
          "Error: Course not found for course number: ${section.courseNumber}");
      return Courses(courseNumber: "Unkown", className: 'Unknown Course');
    },
  );
  return '${course.courseNumber} - ${course.className} (${section.sectionNumber})';
}

// our autocomplete widget for seaching and adding courses by name or number
class AutoCompleteFormField extends StatelessWidget {
  // autocomplete widget
  final String label;
  final List<String> options;
  final Function(String)? onOptionSelected;

  const AutoCompleteFormField({
    required this.label,
    required this.options,
    this.onOptionSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Autocomplete<String>(
      optionsBuilder: (TextEditingValue textEditingValue) {
        // if the input is empty, show all options
        if (textEditingValue.text.isEmpty) {
          // when there's no text, show no options
          return const Iterable<String>.empty();
        } else {
          // otherwise, show the filtered list
          var filteredOptions = options
              .where((option) => option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase()))
              .toList();
          print('Filtered options: $filteredOptions'); // debugging
          return filteredOptions;
        }
      },
      onSelected: (String selection) {
        if (onOptionSelected != null) {
          onOptionSelected!(selection);
        }
      },
      fieldViewBuilder: (BuildContext context,
          TextEditingController textEditingController,
          FocusNode focusNode,
          VoidCallback onFieldSubmitted) {
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: label,
            filled: true,
            fillColor: Colors.white,
            border: const OutlineInputBorder(),
          ),
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
    );
  }
}
