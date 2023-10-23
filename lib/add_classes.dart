import 'package:campus_compass/test_data.dart';
import 'package:flutter/material.dart';

class AddClassSchedule extends StatefulWidget {
  // stateful widget for adding class schedules
  const AddClassSchedule({super.key}); // calls parent class constructor

  final String title = "Class Schedue"; // title property

  @override
  State<AddClassSchedule> createState() => _AddClassScheduleState();
}

class _AddClassScheduleState extends State<AddClassSchedule> {
  final List<Course> _selectedCourses =
      []; // list to keep track of selected courses

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // has two properties - body and appBar
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        backgroundColor:
            const Color.fromARGB(255, 0, 73, 144), // color of body of scaffold
        title: Text(widget.title),
        actions: <Widget>[
          Row(
            // inside the appBar to contain multiple children horizontally
            children: [
              InkWell(
                onTap: () {}, // our edit button
                child: const Padding(
                  padding: EdgeInsets.only(right: 16.0),
                  child: Icon(Icons.edit),
                ),
              ),
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
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: _selectedCourses.length,
              itemBuilder: (BuildContext context, int index) {
                Course course = _selectedCourses[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .start, // To align content to the start
                    children: [
                      Text(
                        'Course: ${course.courseNumber} - ${course.className}\nBy ${course.professorName}\nin ${course.building} - ${course.roomNumber}',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Divider(
                        color: Colors.black,
                        thickness: 2,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Align(
            // New aligned icon (+)
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                  onTap: () {
                    showDialog(
                      // display of the dialog box after pressing our + button
                      context: context,
                      builder: (context) {
                        return Dialog(
                          child: Container(
                            padding: const EdgeInsets.all(20.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text('Add a Class',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),

                                  // auto complete form fields that allow users to search for classes listed in the database, select, then display
                                  AutoCompleteFormField(
                                    label: 'Course Number',
                                    options: extractUniqueCourseNumbers(
                                        dummyCourses),
                                    onOptionSelected: (selection) {
                                      Course selectedCourse =
                                          dummyCourses.firstWhere((course) =>
                                              course.courseNumber == selection);
                                      setState(() {
                                        _selectedCourses.add(selectedCourse);
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  // form fields for the user to input depending on what information they have available to search with *probably will cut down?*
                                  AutoCompleteFormField(
                                    label: 'Class Name',
                                    options:
                                        extractUniqueCourseNames(dummyCourses),
                                    onOptionSelected: (selection) {
                                      Course selectedCourse =
                                          dummyCourses.firstWhere((course) =>
                                              course.className == selection);
                                      setState(() {
                                        _selectedCourses.add(selectedCourse);
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 16),

                                  AutoCompleteFormField(
                                    label: 'Professor Name',
                                    options: extractUniqueProfessorNames(
                                        dummyCourses),
                                    onOptionSelected: (selection) {
                                      Course selectedCourse =
                                          dummyCourses.firstWhere((course) =>
                                              course.professorName ==
                                              selection);
                                      setState(() {
                                        _selectedCourses.add(selectedCourse);
                                      });
                                    },
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    // row with cancel and add class buttons - will likely remove add class due to redundancy
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context)
                                              .pop(); // close the dialog
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
                      },
                    );
                  },
                  child: const Icon(Icons.add,
                      color: Color.fromARGB(255, 0, 73, 144),
                      size: 100.0) // stock '+' icon
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

// model class for course details used to work with our test data
class Course {
  final String courseNumber;
  final String className;
  final String professorName;
  final String building;
  final String roomNumber;

  Course({
    required this.courseNumber,
    required this.className,
    required this.professorName,
    required this.building,
    required this.roomNumber,
  });
}

// functions to extract unique values from a list of courses (currently provided by test_data)
List<String> extractUniqueCourseNumbers(List<Course> courses) {
  return courses.map((course) => course.courseNumber).toSet().toList();
}

List<String> extractUniqueCourseNames(List<Course> courses) {
  return courses.map((course) => course.className).toSet().toList();
}

List<String> extractUniqueProfessorNames(List<Course> courses) {
  return courses.map((course) => course.professorName).toSet().toList();
}

List<String> extractUniqueBuildings(List<Course> courses) {
  return courses.map((course) => course.building).toSet().toList();
}

List<String> extractUniqueRoomNumbers(List<Course> courses) {
  return courses.map((course) => course.roomNumber).toSet().toList();
}

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
        if (textEditingValue.text == '') {
          return const <String>[];
        }
        return options
            .where((option) => option
                .toLowerCase()
                .contains(textEditingValue.text.toLowerCase()))
            .toList();
      },
      onSelected: (String selection) {
        if (onOptionSelected != null) {
          onOptionSelected!(selection);
        }
        Navigator.of(context)
            .pop(); // close the dialog when the option is selected
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

// AutoCompleteFormField function from the login adapted to autocomplete fields for course input
/*Widget AutoCompleteFormField({
  required String label, // label of the input field 
  required List<String> options, // list of string options for the autocomplete funcitonality 
  TextEditingController? textEditingController, // allows the caller to provide a text controller to capture and control the input
  bool obscureText = false}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text( // displays the label of the input field
        label,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
      ),
      const SizedBox(
        height: 5,
      ),
      Autocomplete<String>(
        optionsBuilder: (TextEditingValue textEditingValue) { // filters the list of autocomplete options based on user input
          print("User Input: ${textEditingValue.text}");
          print("Available options: $options");
          return options;
        },
        onSelected: (String selection) { // called when a user selects an autocomplete suggestion
          if (textEditingController != null){ 
            textEditingController.text = selection;
          }
        },
          fieldViewBuilder: (
            BuildContext context, 
            TextEditingController fieldTextEditingController,
            FocusNode fieldFocusNode,
            VoidCallback onFieldSubmitted) {
              return TextField(
                controller: textEditingController,
                obscureText: obscureText,
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical:  0, horizontal: 10),
                  enabledBorder: OutlineInputBorder(
                    borderSide:  BorderSide(
                      color: Colors.grey,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey)
                  ),
                ),
                onSubmitted:  (String value){
                  onFieldSubmitted();
                },
              );
            },
          ),
          const SizedBox(
            height: 30,
      ),
    ],
  );
}*/
