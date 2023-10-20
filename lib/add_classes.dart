import 'package:campus_compass/test_data.dart';
import 'package:flutter/material.dart';

class AddClassSchedule extends StatefulWidget {
  const AddClassSchedule({super.key});

  final String title = "Class Schedule";

  @override
  State<AddClassSchedule> createState() => _AddClassScheduleState();
}

class _AddClassScheduleState extends State<AddClassSchedule> {
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
            children: [
              InkWell(
                // our + button
                onTap: () {},
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
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'This is a test field',
                ),
              ],
            ), // Existing centered content
          ),
          Align(
            // New aligned icon
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: InkWell(
                onTap: () {
                  showDialog(
                    // function that shows our pop up dialog box
                    context: context, // context of our current screen
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Add a Class'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            makeAutoCompleteInput(label: 'Course Number', options: extractUniqueCourseNumbers(dummyCourses)),
                            makeAutoCompleteInput(label: 'Course Name', options:  extractUniqueCourseNames(dummyCourses)),
                            makeAutoCompleteInput(label: 'Professor Name', options:  extractUniqueCourseNames(dummyCourses)),
                            makeAutoCompleteInput(label: 'Building Number', options: extractUniqueBuildings(dummyCourses)),
                            makeAutoCompleteInput(label: 'Room Number', options: extractUniqueRoomNumbers(dummyCourses)),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // close the dialog
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(); // close the dialog
                            },
                            child: const Text('Add Class'),
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

  // used to work with our test data
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

List<String> extractUniqueCourseNumbers(List<Course> courses){
  return courses.map((course) => course.courseNumber).toSet().toList();
}
List<String> extractUniqueCourseNames(List<Course> courses){
  return courses.map((course) => course.className).toSet().toList();
}
List<String> extractUniqueProfessorNames(List<Course> courses){
  return courses.map((course) => course.professorName).toSet().toList();
}
List<String> extractUniqueBuildings(List<Course> courses){
  return courses.map((course) => course.building).toSet().toList();
}
List<String> extractUniqueRoomNumbers(List<Course> courses){
  return courses.map((course) => course.roomNumber).toSet().toList();
}



// makeAutoCompleteInput function from the login adapted to autocomplete fields for course input
Widget makeAutoCompleteInput({
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
          
          if (textEditingValue.text == ''){ // if the user hasn't typed anything, don't show any autocomplete suggestions
            return const [];
          }

          return options.where((option) => // filter the provided options based on what the user has typed
            option.toLowerCase().contains(textEditingValue.text.toLowerCase()));
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
}
