import 'package:campus_compass/test_data.dart';
import 'package:flutter/material.dart';

class AddClassSchedule extends StatefulWidget {
  // stateful constructor for adding class schedules
  const AddClassSchedule({super.key}); // calls parent class constructor

  // title of the app bar
  final String title = "Class Schedue"; 

  // create state for this widget
  @override
  State<AddClassSchedule> createState() => _AddClassScheduleState();
}

class _AddClassScheduleState extends State<AddClassSchedule> {

  // list to store selected courses
  final List<Sections> 
  _selectedCourses = [];

  // building our main ui
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // has two properties - body and appBar
      backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      appBar: AppBar(
        backgroundColor:
            // color of body of scaffold
            const Color.fromARGB(255, 0, 73, 144),
        title: Text(widget.title),
        actions: <Widget>[
          Row(
            
            // inside the appBar to contain multiple children horizontally
            children: [
              InkWell(
                // edit button functionality
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
            // listview to display selected courses
            child: ListView.separated(
              padding: const EdgeInsets.all(16.0),
              itemCount: _selectedCourses.length,
              separatorBuilder: (BuildContext context, int index)
              => const Divider(
                color: Colors.black,
                thickness: 2,
              ),
              itemBuilder: (BuildContext context, int index) {
                // extracts section and course details for the current index
                Sections section = _selectedCourses[index];
                Courses course = dummyCourses.firstWhere(
                (c) => c.courseNumber == section.courseNumber);

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
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.orange),
                      onPressed: () {
                        setState(() {
                          _selectedCourses.removeAt(index);
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
                      onCourseSelected: (selectedCourse){
                        setState(() {
                          _selectedCourses.add(selectedCourse);
                        });
                      }
                    )   
                  );
                },
                // displaying the '+' icon
                child: const Icon(Icons.add, color: Color.fromARGB(255, 0, 73, 144), size: 100.0) // stock '+' icon              
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
  final Function(Sections) onCourseSelected;

  const CourseDialog({Key? key, required this.onCourseSelected}) : super(key:key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // header text of the dialog
              const Text('Add a Class', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // auto complete form fields that allow users to search for classes listed in the database, select, then display
              AutoCompleteFormField(
                label: 'Search by Course Number or Class Name',
                options: generateCombinedOptions(),
                onOptionSelected: (selection){
                  Sections selectedSection = dummySections.firstWhere((section) =>
                  generateOptionString(section) == selection);
                  onCourseSelected(selectedSection);
                },
              ),

              const SizedBox(height: 20),
              Row( // row with cancel
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
  final int courseNumber; // primary key for Courses
  final String className;

  Courses({
    required this.courseNumber,
    required this.className,
    });
}

// model class to represent section details
class Sections {
  final int courseNumber; // foreign key
  final int sectionNumber; // primary key for sections
  final String professorName;
  final String building;
  final String roomNumber;

  Sections({
    required this.courseNumber,
    required this.sectionNumber,
    required this.professorName,
    required this.building,
    required this.roomNumber,
  });
}

// function to generate options for the autocomplete search
List<String> generateCombinedOptions() {
  return dummySections.map((section) => generateOptionString(section)).toList();
}

// function to format the string shown in autocomplete options
String generateOptionString(Sections section) {
  Courses course = dummyCourses.firstWhere(
    (c) => c.courseNumber == section.courseNumber,
    orElse: () {
      // error handling 
      print("Error: Course not found for course number: ${section.courseNumber}");
      return Courses(courseNumber: -1, className: 'Unknown Course');
    },
  );
  
  return '${course.courseNumber} - ${course.className} (${section.sectionNumber})';
}

/* Not currently in use functions since splitting of Courses into Courses and Sections

// functions to extract unique values from a list of courses (currently provided by test_data)
List<String> extractUniqueClassNames(List<Courses> courses) {
  return courses.map((course) => course.className).toSet().toList();
}

List<String> extractUniqueCourseNumbers(List<Sections> sections) {
  return sections.map((section) => section.courseNumber).toSet().toList();
}

List<String> extractUniqueSectionNumbers(List<Sections> sections) {
   return sections.map((section) => section.sectionNumber).toSet().toList();
}

List<String> extractUniqueProfessorNames(List<Sections> sections) {
  return sections.map((section) => section.professorName).toSet().toList();
}

List<String> extractUniqueBuildings(List<Sections> sections) {
  return sections.map((section) => section.building).toSet().toList();
}

List<String> extractUniqueRoomNumbers(List<Sections> sections) {
  return sections.map((section) => section.roomNumber).toSet().toList();
}
*/


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
        if (textEditingValue.text == '') {
          return options;
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
        // close the dialog when the option is selected
        Navigator.of(context).pop(); 
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

