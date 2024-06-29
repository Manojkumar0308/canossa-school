import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../menu/view/menu_screen.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import '../../utils/commonAppBar.dart';
import '../../utils/common_methods.dart';
import '../view_model/due_fee_viewmodel.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class ParentDueFeeScreen extends StatefulWidget {
  const ParentDueFeeScreen({super.key});

  @override
  State<ParentDueFeeScreen> createState() => _ParentDueFeeScreenState();
}

class _ParentDueFeeScreenState extends State<ParentDueFeeScreen> {
  int? schoolId;
  int? sessionId;
  String? mobno;
  Stm? selectedStudent;
  bool tap = false;
  bool isLoading = true;
  String? userType;
  String? attendanceStudentPhoto;
  String? attendanceStudentName;
  String? attendanceStudentClass;
  String? attendanceStudentRoll;
  String? attendanceRegNo;
  String? selectedPhoto;
  String? selectedName;
  String? selectedClass;
  String? selectedRoll;
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    final pref = await SharedPreferences.getInstance();
    schoolId = pref.getInt('schoolid');
    userType = pref.getString('userType');

    sessionId = pref.getInt('sessionid');

    mobno = pref.getString('mobno');

    selectedName = pref.getString('attendanceStudentName');
    selectedPhoto = pref.getString('attendanceStudentPhoto');
    selectedClass = pref.getString('attendanceStudentClass');
    selectedRoll = pref.getString('attendanceStudentRoll');

    attendanceRegNo = pref.getString('attendanceRegNo');

    final studentProvider =
        // ignore: use_build_context_synchronously
        Provider.of<StudentProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    studentProvider.fetchStudentData(
        mobno.toString(), schoolId.toString(), sessionId.toString(), context);
    final duefeeproviderforapi =
        // ignore: use_build_context_synchronously
        Provider.of<DueFeeViewModel>(context, listen: false);
    duefeeproviderforapi.requiredData();

    await duefeeproviderforapi.fetchStudentDueFee(attendanceRegNo.toString());
  }

  void _showStudentList(BuildContext context, List<Stm> students) {
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
                      splashColor: Appcolor.themeColor,
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
                        selectedRoll = pref.getString('attendanceStudentRoll');
                        attendanceRegNo = pref.getString('attendanceRegNo');
                        final duefeeproviderforapi =
                            // ignore: use_build_context_synchronously
                            Provider.of<DueFeeViewModel>(context,
                                listen: false);
                        await duefeeproviderforapi
                            .fetchStudentDueFee(attendanceRegNo.toString());
                        // Notify the builder to rebuild the DataTable
                        setState(() {});

                        setState(() {
                          tap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                        });
                        setState(() {
                          tap = true;
                          isLoading = true;
                        });

                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    final duefeeprovider = Provider.of<DueFeeViewModel>(context);
    final size = MediaQuery.of(context).size;
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.profile;
    final students = student?.stm ?? [];
    final menuProvider = Provider.of<MenuViewModel>(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 70,
        titleSpacing: 2,
        backgroundColor: Appcolor.themeColor,
        title: InkWell(
          onTap: () {
            _showStudentList(context, students);
          },
          child: SizedBox(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                IconButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MenuScreen()),
                      );
                    },
                    icon: const Icon(Icons.arrow_back)),
                GestureDetector(
                  onTap: () {
                    _showStudentList(context, students);

                    setState(() {
                      tap = false;
                    });
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Appcolor.lightgrey),
                    child: selectedPhoto == null
                        ? ClipOval(
                            child: Image.asset(
                              'assets/images/user_profile.png',
                              fit: BoxFit.cover,
                            ),
                          ) // Replace with your asset image path
                        : ClipOval(
                            child: Image.network(
                              selectedPhoto.toString(),
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                // Handle network image loading error here
                                return ClipOval(
                                  child: Image.asset(
                                      'assets/images/user_profile.png'),
                                ); // Replace with your error placeholder image
                              },
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 3.0),
                        child: Text(
                          selectedName != null
                              ? 'Name:$selectedName'
                              : 'Name:N/A',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              overflow: TextOverflow.ellipsis,
                              fontSize: size.width * 0.03),
                        ),
                      ),
                      Text(
                        selectedClass != null
                            ? 'Class:$selectedClass'
                            : 'Class:N/A',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontSize: size.width * 0.03),
                      ),
                      Text(
                        selectedRoll == null
                            ? 'Roll:N/A'
                            : 'Roll:$selectedRoll',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontSize: size.width * 0.03),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
              ],
            ),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: menuProvider.bytesImage != null
                ? Image.memory(
                    menuProvider.bytesImage!,
                    height: size.height * 0.08,
                    width: size.width * 0.08,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: duefeeprovider.isLoading
          ? Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Loading....',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  duefeeprovider.isLoading
                      ? const SizedBox.shrink()
                      : const SizedBox(
                          height: 20,
                        ),
                  duefeeprovider.studentDueFeeList.isEmpty
                      ? const Center(
                          child: Text(
                            'No due fee record found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: duefeeprovider.studentDueFeeList.length,
                          itemBuilder: ((context, index) => Padding(
                                padding: const EdgeInsets.only(
                                    top: 8.0, left: 15, right: 15),
                                child: Container(
                                  margin: EdgeInsets.zero,
                                  height: size.height * 0.08,
                                  child: Card(
                                    margin: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: size.width * 0.04,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Colors.red,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Text(
                                                  'Installments:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          size.width * 0.03),
                                                ),
                                                Text(
                                                  duefeeprovider
                                                      .studentDueFeeList[index]
                                                      .installments
                                                      .toString(),
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.width * 0.03),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'Due Amount:',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize:
                                                          size.width * 0.03),
                                                ),
                                                Text(
                                                  ' \u{20B9}${duefeeprovider.studentDueFeeList[index].amount}',
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.width * 0.03),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        const Spacer(),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Image.asset(
                                            'assets/images/charges.png',
                                            height: size.width * 0.10,
                                            width: size.width * 0.10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              )),
                        ),
                  // SingleChildScrollView(
                  //     scrollDirection: Axis.horizontal,
                  //     child: Padding(
                  //       padding: const EdgeInsets.all(10.0),
                  //       child: SizedBox(
                  //         child: Padding(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 15.0),
                  //           child: DataTable(
                  //               headingRowColor:
                  //                   MaterialStateColor.resolveWith(
                  //                 (states) {
                  //                   return Colors.greenAccent;
                  //                 },
                  //               ),
                  //               border: TableBorder.all(
                  //                   color: Colors.blueGrey),
                  //               columns: const [
                  //                 DataColumn(
                  //                   label: Expanded(
                  //                     child: Text(
                  //                       'Net Amount',
                  //                       textAlign: TextAlign.center,
                  //                       style: TextStyle(fontSize: 12),
                  //                     ),
                  //                   ),
                  //                 ),
                  //                 DataColumn(
                  //                   label: Expanded(
                  //                     child: Text(
                  //                       'Intervals',
                  //                       textAlign: TextAlign.center,
                  //                       style: TextStyle(fontSize: 12),
                  //                     ),
                  //                   ),
                  //                 ),
                  //               ],
                  //               rows: duefeeprovider.studentDueFeeList
                  //                   .map((dueFee) {
                  //                 return DataRow(cells: [
                  //                   DataCell(
                  //                     Center(
                  //                       child: Text(
                  //                           '\u{20B9}${dueFee.amount}'),
                  //                     ),
                  //                   ),
                  //                   DataCell(
                  //                     Center(
                  //                       child: Text(
                  //                         dueFee.installments
                  //                             .toString(),
                  //                       ),
                  //                     ),
                  //                   ),
                  //                 ]);
                  //               }).toList()),
                  //         ),
                  //       ),
                  //     ),
                  //   ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}
