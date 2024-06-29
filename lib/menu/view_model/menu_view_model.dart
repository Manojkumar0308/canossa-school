import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import '../model/menu_model.dart';

class MenuViewModel extends ChangeNotifier {
  bool? permissionUrlResult;
  bool avatarTap = false;
  String? selectedPhoto;
  String? selectedName;
  String? selectedClass;
  String? classSection;
  String? selectedRoll;
  bool isLoading = false;
  bool fileExists = false;
  String? logo;
  Uint8List? bytesImage;
  //for  Teacher  Grid item text and images are:
  final List<Item> itemsTeacher = [
    Item(text: "Add Homework", imageUrl: "assets/images/homework.png"),
    Item(text: "Homework Report", imageUrl: "assets/images/homework.png"),
    Item(text: "Send Notification", imageUrl: "assets/images/notification.png"),
    Item(text: "Add Attendance", imageUrl: "assets/images/attendance.png"),
    Item(text: "Events", imageUrl: "assets/images/attendance_calendar.jpg"),
    Item(text: "Student By Reg No", imageUrl: "assets/images/student.png"),
    Item(
        text: "Student By Class",
        imageUrl: "assets/images/student_by_class.png"),
    Item(text: "Gallery", imageUrl: "assets/images/gallery.png"),
  ];
//for students Grid item text and images are.
  final List<Item> studentMenu = [
    Item(text: "View Homework", imageUrl: "assets/images/homework.png"),
    Item(text: "Attendance", imageUrl: "assets/images/attendance.png"),
    Item(text: "Fee Submission", imageUrl: "assets/images/online_fee.png"),
    Item(text: "Events", imageUrl: "assets/images/attendance_calendar.jpg"),
    Item(text: "Fees", imageUrl: "assets/images/fees.png"),
    Item(text: "Due Fee", imageUrl: "assets/images/due_fee.png"),
    Item(text: "Exam Result", imageUrl: "assets/images/exam_result.png"),
    Item(
        text: "Notifications",
        imageUrl: "assets/images/notification_report.png"),
  ];
  final List<Item> adminMenu = [
    Item(text: "Send Notification", imageUrl: "assets/images/notification.png"),
    Item(text: "Student By Reg No", imageUrl: "assets/images/student.png"),
    Item(
        text: "Student By Class",
        imageUrl: "assets/images/student_by_class.png"),
    Item(text: "Sms Report", imageUrl: "assets/images/notification_report.png"),
  ];

// instance of TeacherInfo class present in model class.
  TeacherInfo? _teacherInfo;
  TeacherInfo? get teacherInfo => _teacherInfo;
  HostService hostService = HostService();

  Future<void> fetchTeacherInfo(String mobNo) async {
    try {
      logo = null;
      bytesImage = null;
      isLoading = true;

      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      final url =
          Uri.parse(baseurl.toString() + hostService.teacherInfo + mobNo);
      print('teacher info url:$url');

      final response = await http.get(url);
      print('teacher info response:$response');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['logo'] != null) {
          logo = data['logo'];
          print('logo is:$logo');
          bytesImage = const Base64Decoder().convert(logo.toString());
          notifyListeners();
        }

        print('bytes image is:$bytesImage');
        print('data is:$data');
        pref.setInt('teacherId', data['tid']);

        _teacherInfo = TeacherInfo.fromJson(data);

        isLoading = false;
        notifyListeners();
      } else {
        isLoading = false;
        notifyListeners();

        // Handle API error
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      // Handle any exceptions that occurred during the API call
      print('Error during API call: $e');
    }
  }

  Future<void> getTeacherPermission() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      final tid = pref.getInt('teacherId');
      final tname = pref.getString('teacherName');
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
      };
      final requestBody = jsonEncode(
          {"tid": tid, "tname": tname, "permission_name": "attendance"});
      final url =
          Uri.parse(baseurl.toString() + hostService.getTeacherPermissionUrl);
      print('teacher permission url:$url');
      final response =
          await http.post(url, body: requestBody, headers: headers);
      print('teacher permission response:$response');
      if (response.statusCode == 200) {
        permissionUrlResult = json.decode(response.body);
        print('permissionUrl value is-->>$permissionUrlResult');
      } else {
        print('Something went wrong');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  void removepref() async {
    final pref = await SharedPreferences.getInstance();

    pref.remove('attendanceRegNo');
    pref.remove('attendanceStudentName');
    pref.remove('attendanceStudentClass');
    pref.remove('attendanceStudentRoll');
    pref.remove('attendanceStudentPhoto');
    notifyListeners();
  }

  Future<void> checkFileExistence(String path) async {
    try {
      final response = await http.get(Uri.parse(path));

      if (response.statusCode == 200) {
        // The file exists

        fileExists = true;
        notifyListeners();
      } else if (response.statusCode == 404) {
        // The file does not exist

        fileExists = false;
        notifyListeners();
      }
    } catch (e) {
      // Handle network or other errors
      print('Error: $e');
    }
  }

  void showStudentList(BuildContext context, List<Stm> students) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Select Student',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: (BuildContext context, int index) {
                final student = students[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 0),
                      dense: true,
                      leading: student.photo != null &&
                              student.photo.toString().isNotEmpty
                          ? CircleAvatar(
                              radius: 20,
                              backgroundColor: Appcolor.lightgrey,
                              backgroundImage:
                                  NetworkImage(student.photo.toString()),
                            )
                          : const CircleAvatar(
                              radius: 20,
                              backgroundColor: Appcolor.lightgrey,
                              backgroundImage:
                                  AssetImage('assets/images/user_profile.png'),
                            ),
                      title: Text(
                        student.stuName ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                      onTap: () async {
                        final pref = await SharedPreferences.getInstance();
                        //onTap particular student listtile first remove the previous stored data.
                        pref.remove('attendanceRegNo');
                        pref.remove('attendanceStudentName');
                        pref.remove('attendanceStudentClass');
                        pref.remove('attendanceStudentRoll');
                        pref.remove('attendanceStudentPhoto');
                        pref.remove('classId');
                        pref.remove('sectionId');
                        pref.remove('attendanceStudentSection');
                        pref.remove('StuId');
                        /*after removing the following data by selecting student again following
                        details of a student is saving again in sharedPreferences */
                        pref.setString(
                            'attendanceRegNo', student.regNo.toString());
                        if (student.stuName != null) {
                          pref.setString('attendanceStudentName',
                              student.stuName.toString());
                        } else {
                          pref.setString('attendanceStudentName', 'N/A');
                        }

                        if (student.className != null) {
                          pref.setString('attendanceStudentClass',
                              student.className.toString());
                        } else {
                          pref.setString('attendanceStudentClass', 'N/A');
                        }
                        if (student.stuId != null) {
                          pref.setInt('StuId', student.stuId!);
                        } else {
                          pref.setInt('StuId', 0);
                        }

                        if (student.rollNo != null) {
                          pref.setString('attendanceStudentRoll',
                              student.rollNo.toString());
                        } else {
                          pref.setString('attendanceStudentRoll', 'N/A');
                        }

                        if (student.photo != null &&
                            student.photo.toString().isNotEmpty) {
                          pref.setString('attendanceStudentPhoto',
                              student.photo.toString());
                        }
                        // else {
                        //   pref.setString('attendanceStudentPhoto',
                        //       'https://source.unsplash.com/random/?city,night');
                        // }
                        pref.setInt('classId', student.classId!);
                        pref.setInt('sectionId', student.sectionId!);
                        selectedName = pref.getString('attendanceStudentName');
                        selectedPhoto =
                            pref.getString('attendanceStudentPhoto');
                        selectedClass =
                            pref.getString('attendanceStudentClass');
                        classSection =
                            pref.getString('attendanceStudentSection');
                        selectedRoll = pref.getString('attendanceStudentRoll');

                        // set the bool value to true.
                        avatarTap = true;
                        //calling selectstudent method from studentProvider class.
                        // ignore: use_build_context_synchronously
                        Provider.of<StudentProvider>(context, listen: false)
                            .selectStudent(index);
                        notifyListeners();
                        // for exit the dialog box

                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                        notifyListeners();
                      },
                    ),
                    const Divider(
                      color: Colors.white,
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  void updateSelectedPhoto(String? selectedPhoto) async {
    final pref = await SharedPreferences.getInstance();
    final studentDashBoardPhoto = pref.getString('attendanceStudentPhoto');
    if (studentDashBoardPhoto.toString().isNotEmpty) {
      selectedPhoto = studentDashBoardPhoto;
      notifyListeners();
    } else {
      selectedPhoto = null;
      notifyListeners();
    }
  }
}
