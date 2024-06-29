import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weipl_checkout_flutter/weipl_checkout_flutter.dart';
import '../../login/view/login_screen.dart';
import '../../menu/view/menu_screen.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../view_model/online_payment_viewmodel.dart';
import 'failure.dart';
import 'success.dart';

class OnlinePaymentScreen extends StatefulWidget {
  const OnlinePaymentScreen({super.key});

  @override
  State<OnlinePaymentScreen> createState() => _OnlinePaymentScreenState();
}

class _OnlinePaymentScreenState extends State<OnlinePaymentScreen> {
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
  int? stuId;
  int? classId;
  double amount = 0.0;
  String addedInterval = '';
  int selectedIndex = -1;
  List<String> selectedUnpaidIntervals = [];
  List<String> setValues = [];
  String? stringList;
  String? installment1;
  String? installment2;
  String? installment3;
  String? installment4;
  String? newStringList;
  double cu_amt = 0.0;
  int? selectedContainerIndex;
  String? monthIntervals;

  String? card_id;
  String? txn_status;
  String? txn_msg;
  String? txn_amt;
  String? successCode;
  String? BankTransactionID;
  String? returnedHash;
  String? tpsl_txn_id;
  static MethodChannel channel = const MethodChannel("easebuzz");
  void refreshUI() {
    setState(() {
      // Any UI update logic here
    });
  }

  preference() async {
    final menuProvider = Provider.of<MenuViewModel>(context, listen: false);
    final pref = await SharedPreferences.getInstance();
    schoolId = pref.getInt('schoolid');
    userType = pref.getString('userType');

    sessionId = pref.getInt('sessionid');

    mobno = pref.getString('mobno');

    selectedName = pref.getString('attendanceStudentName');
    menuProvider.updateSelectedPhoto(selectedPhoto);
    selectedClass = pref.getString('attendanceStudentClass');
    selectedRoll = pref.getString('attendanceStudentRoll');

    attendanceRegNo = pref.getString('attendanceRegNo');
    stuId = pref.getInt('StuId');
    print('student id is :$stuId');
    print('session id is :$sessionId');

    final studentProvider =
        // ignore: use_build_context_synchronously
        Provider.of<StudentProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    studentProvider.fetchStudentData(
        mobno.toString(), schoolId.toString(), sessionId.toString(), context);
    final onlinepaymentProviders =
        // ignore: use_build_context_synchronously
        Provider.of<OnlinePaymentViewModel>(context, listen: false);

    if (stuId != null && sessionId != null) {
      addedInterval = '';
      // ignore: use_build_context_synchronously
      onlinepaymentProviders.onlineFeeDetail(
          context, attendanceRegNo.toString(), stuId!, sessionId!);

      // ignore: use_build_context_synchronously
      onlinepaymentProviders.getGateWayDetail(context);
    }
    cu_amt = 0.0;
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
                        setValues = [];
                        cu_amt = 0.0;
                        final pref = await SharedPreferences.getInstance();
                        //onTap particular student listtile first remove the previous stored data.
                        pref.remove('attendanceRegNo');
                        pref.remove('attendanceStudentName');
                        pref.remove('attendanceStudentClass');
                        pref.remove('attendanceStudentRoll');
                        pref.remove('attendanceStudentPhoto');
                        pref.remove('classId');
                        pref.remove('sectionId');
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
                        if (student.stuId != null) {
                          pref.setInt('StuId', student.stuId!);
                        } else {
                          pref.setInt('StuId', 0);
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
                        stuId = pref.getInt('StuId');
                        classId = pref.getInt('classId');

                        setState(() {
                          tap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                        });
                        setState(() {
                          tap = true;
                          isLoading = true;
                        });
                        final onlinepaymentProviders =
                            // ignore: use_build_context_synchronously
                            Provider.of<OnlinePaymentViewModel>(context,
                                listen: false);
                        if (stuId != null && sessionId != null) {
                          // ignore: use_build_context_synchronously
                          onlinepaymentProviders.onlineFeeDetail(context,
                              attendanceRegNo.toString(), stuId!, sessionId!);
                          // ignore: use_build_context_synchronously
                          onlinepaymentProviders.getGateWayDetail(context);
                        }

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
  void initState() {
    preference();

    super.initState();
  }

  int selectedRowIndex = -1;
  bool selectedContainer = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.profile;
    final students = student?.stm ?? [];
    final menuProvider = Provider.of<MenuViewModel>(context);
    final onlinepaymentProviders =
        // ignore: use_build_context_synchronously
        Provider.of<OnlinePaymentViewModel>(context);

    return RefreshIndicator(
      displacement: 150,
      backgroundColor: Colors.black,
      color: Colors.blue,
      strokeWidth: 3,
      triggerMode: RefreshIndicatorTriggerMode.onEdge,
      onRefresh: () async {
        cu_amt = 0.0;
        await Future.delayed(const Duration(milliseconds: 1500))
            .then((value) => preference());
      },
      child: WillPopScope(
        onWillPop: () {
          return CommonMethods().onwillPop(context);
        },
        child: Scaffold(
            backgroundColor: Appcolor.lightgrey,
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
                              MaterialPageRoute(
                                  builder: (_) => const MenuScreen()),
                            );
                          },
                          icon: const Icon(Icons.arrow_back)),
                      GestureDetector(
                        onTap: () {
                          _showStudentList(context, students);
                          // setValues = [];
                          // cu_amt = 0.0;
                          setState(() {
                            tap = false;
                          });
                        },
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Appcolor.lightgrey),
                          child: selectedPhoto == null
                              ? ClipOval(
                                  child: Image.asset(
                                    'assets/images/user_profile.png',
                                    fit: BoxFit.cover,
                                  ),
                                ) // Replace with your asset image path
                              : ClipOval(
                                  child: Image.network(
                                    selectedPhoto!,
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
                      Expanded(
                        child: Padding(
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
                  child: Center(
                      child: Text(
                    'Prev Bal: \u20B9${onlinepaymentProviders.isLoading ? 0.0 : onlinepaymentProviders.data["prev_bal"] ?? 0.0}',
                    style: TextStyle(
                        fontSize: size.width * 0.03,
                        fontWeight: FontWeight.bold),
                  )),
                  // menuProvider.bytesImage != null
                  //     ? Image.memory(
                  //         menuProvider.bytesImage!,
                  //         height: size.height * 0.08,
                  //         width: size.width * 0.08,
                  //       )
                  //     : const SizedBox.shrink(),
                ),
              ],
            ),
            bottomNavigationBar: InkWell(
              child: Container(
                height: setValues.isNotEmpty
                    ? size.height * 0.08
                    : size.height * 0.07,
                color: setValues.isNotEmpty ? Appcolor.lightgrey : Colors.grey,
                child: setValues.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(right: 5.0),
                              child: Container(
                                child: Row(
                                  children: [
                                    Text(
                                      setValues.isNotEmpty ? ' \u20B9' : '',
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      setValues.isNotEmpty ? '$cu_amt' : '',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Container(
                                height: size.height,
                                width: 1.2,
                                color: Colors.grey,
                              ),
                            ),
                            // Image.asset(
                            //   'assets/images/star.png',
                            //   height: 18,
                            //   width: 18,
                            // ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: Container(
                                child: const Text(
                                    'Note: Platform charges will be applied *',
                                    style: TextStyle(
                                        color: Colors.grey,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),

                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 5.0),
                              child: Container(
                                height: size.height,
                                width: 1.2,
                                color: Colors.grey,
                              ),
                            ),

                            Flexible(
                              child: InkWell(
                                onTap: () async {
                                  final pref =
                                      await SharedPreferences.getInstance();
                                  if (onlinepaymentProviders
                                          .decodedResponse['resultcode'] ==
                                      0) {
                                    Fluttertoast.showToast(
                                        msg: "Please Login Again",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 2,
                                        backgroundColor: Colors.black,
                                        textColor: Colors.white,
                                        fontSize: 12.0);
                                    pref.clear();

                                    // ignore: use_build_context_synchronously
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) => const LoginScreen()),
                                    );
                                  } else {
                                    if (setValues.isNotEmpty) {
                                      print('newstringList is $newStringList');
                                      // ignore: use_build_context_synchronously
                                      await onlinepaymentProviders
                                          .getTransactionId(
                                              context,
                                              stringList.toString(),
                                              cu_amt,
                                              installment1.toString(),
                                              installment2.toString(),
                                              installment3.toString(),
                                              installment4.toString());
                                      print('installment1: $installment1');
                                      print('installment2: $installment2');
                                      print('installment3: $installment3');
                                      print('installment4: $installment4');

                                      // // ignore: use_build_context_synchronously
                                      // await onlinepaymentProviders
                                      //     .initiatePayment(cu_amt,
                                      //         selectedName.toString(), context);
                                      // if (onlinepaymentProviders
                                      //             .detailedResponse["status"] ==
                                      //         "success" ||
                                      //     onlinepaymentProviders
                                      //             .detailedResponse["status"] ==
                                      //         "failure") {
                                      //   Future.delayed(const Duration(seconds: 3),
                                      //       () {
                                      //     onlinepaymentProviders.getResponseOnlineTransaction(
                                      //         onlinepaymentProviders
                                      //             .detailedResponse["status"]
                                      //             .toString(),
                                      // onlinepaymentProviders
                                      //     .detailedResponse["txnid"]
                                      //     .toString(),
                                      //         newStringList.toString(),
                                      //         onlinepaymentProviders
                                      //             .detailedResponse["easepayid"]
                                      //             .toString(),
                                      //         onlinepaymentProviders
                                      //             .detailedResponse[
                                      //                 "bank_ref_num"]
                                      //             .toString(),
                                      //         double.parse(onlinepaymentProviders
                                      //             .detailedResponse["amount"]),
                                      //         onlinepaymentProviders
                                      //             .detailedResponse["bankcode"]
                                      //             .toString(),
                                      //         onlinepaymentProviders
                                      //             .detailedResponse["status"]
                                      //             .toString(),
                                      //         onlinepaymentProviders
                                      //             .detailedResponse["hash"]);
                                      //   });
                                      // }

                                      //paynimo integration
                                      // await processPayment();

                                      onlinepaymentProviders
                                          .intervals(newStringList.toString());
                                      print('newStringList is :$newStringList');

                                      // ignore: use_build_context_synchronously
                                      final pref =
                                          await SharedPreferences.getInstance();
                                      final stuId = pref.getInt('StuId');
                                      WeiplCheckoutFlutter wlCheckoutFlutter =
                                          WeiplCheckoutFlutter();

                                      String deviceID =
                                          ""; // initialize variable

                                      if (Platform.isAndroid) {
                                        deviceID =
                                            "AndroidSH2"; // Android-specific deviceId, supported options are "AndroidSH1" & "AndroidSH2"
                                      } else if (Platform.isIOS) {
                                        deviceID =
                                            "iOSSH2"; // iOS-specific deviceId, supported options are "iOSSH1" & "iOSSH2"
                                      }

                                      // String trnsId = tranid.toString();
                                      // String amount = amt.toString();
                                      // String accnm = "";
                                      // String StuId = stuId.toString();
                                      // String salt = "7725254645IANOLX";
                                      // final hash = "$keys|$trnsId|$amount|$accnm|$StuId|"
                                      //     "|"
                                      //     "|"
                                      //     "|"
                                      //     "|"
                                      //     "|"
                                      //     "|"
                                      //     "|"
                                      //     "|"
                                      //     "|"
                                      //     "|"
                                      //     "|$salt";
                                      // print('hashValue is :$hash');
                                      // String encryptedHash = generateSHA512Hash(hash);
                                      // print('real hash value :$encryptedHash');

                                      var reqJson = {
                                        "features": {
                                          "enableAbortResponse": true,
                                          "enableExpressPay": true,
                                          "enableInstrumentDeRegistration":
                                              true,
                                          "enableMerTxnDetails": true
                                        },
                                        "consumerData": {
                                          "deviceId": deviceID,
                                          "token": onlinepaymentProviders.hash,
                                          "paymentMode": "all",
                                          "merchantLogoUrl":
                                              "https://www.paynimo.com/CompanyDocs/company-logo-vertical.png", //provided merchant logo will be displayed
                                          "merchantId":
                                              onlinepaymentProviders.keys,
                                          "currency": "INR",
                                          "consumerId": stuId,
                                          "consumerMobileNo": "",
                                          "consumerEmailId": "",
                                          "txnId": onlinepaymentProviders
                                              .tranid, //Unique merchant transaction ID
                                          "items": [
                                            {
                                              "itemId": "first",
                                              "amount":
                                                  onlinepaymentProviders.amt,
                                              "comAmt": "0"
                                            }
                                          ],
                                          "customStyle": {
                                            "PRIMARY_COLOR_CODE":
                                                "#45beaa", //merchant primary color code
                                            "SECONDARY_COLOR_CODE":
                                                "#FFFFFF", //provide merchant's suitable color code
                                            "BUTTON_COLOR_CODE_1":
                                                "#2d8c8c", //merchant"s button background color code
                                            "BUTTON_COLOR_CODE_2":
                                                "#FFFFFF" //provide merchant's suitable color code for button text
                                          }
                                        }
                                      };
                                      print('reqjson is :$reqJson');

                                      wlCheckoutFlutter.on(
                                          WeiplCheckoutFlutter.wlResponse,
                                          handleResponse);
                                      wlCheckoutFlutter.open(reqJson);

                                      if (onlinepaymentProviders
                                          .responseGetOnlineResponse
                                          .containsKey('resultstring')) {
                                        onlinepaymentProviders
                                                .paymentConfirmation =
                                            onlinepaymentProviders
                                                    .responseGetOnlineResponse[
                                                'resultstring'];
                                        print(onlinepaymentProviders
                                            .paymentConfirmation);

                                        if (onlinepaymentProviders
                                                .paymentConfirmation ==
                                            "success") {
                                          print('payment success');

                                          // ignore: use_build_context_synchronously
                                          // Future.delayed(const Duration(seconds: 5), () {
                                          //   Navigator.pushReplacement(
                                          //     context,
                                          //     MaterialPageRoute(builder: (_) => const Success()),
                                          //   );
                                          // });
                                        } else {
                                          print('payment failed');

                                          // ignore: use_build_context_synchronously

                                          // Future.delayed(const Duration(seconds: 5), () {
                                          //   Navigator.pushReplacement(
                                          //     context,
                                          //     MaterialPageRoute(builder: (_) => const Failure()),
                                          //   );
                                          // });
                                        }
                                      } else {
                                        print(
                                            'Key "resultstring" not found in responseGetOnlineResponse');
                                      }

                                      // await onlinepaymentProviders
                                      //     .getResponseOnlineTransaction(
                                      //         onlinepaymentProviders.txn_msg
                                      //             .toString(),
                                      //         onlinepaymentProviders.tranid
                                      //             .toString(),
                                      //         newStringList.toString(),
                                      //         onlinepaymentProviders.card_id
                                      //             .toString(),
                                      //         "",
                                      //         double.parse(onlinepaymentProviders
                                      //             .amt
                                      //             .toString()),
                                      //         "",
                                      //         onlinepaymentProviders.txn_status
                                      //             .toString(),
                                      //         onlinepaymentProviders.returnedHash
                                      //             .toString());
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Please select month",
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 2,
                                          backgroundColor: Colors.black,
                                          textColor: Colors.white,
                                          fontSize: 12.0);
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10.0),
                                  child: Container(
                                    height: size.height * 0.05,
                                    width: size.width,
                                    decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(30),
                                        gradient: Appcolor.sliderGradient),
                                    child: const Center(
                                      child: Text(
                                        'Pay',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'Pay',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
              ),
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: onlinepaymentProviders.isLoading
                    ? SizedBox(
                        height: size.height,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                color: Colors.black,
                                child: Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Loading....',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      LoadingAnimationWidget.twistingDots(
                                        leftDotColor: const Color(0xFFFAFAFA),
                                        rightDotColor: const Color(0xFFEA3799),
                                        size: 30,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      )
                    : onlinepaymentProviders.responseData.isEmpty ||
                            onlinepaymentProviders.data == null ||
                            onlinepaymentProviders.data.isEmpty
                        ? SizedBox(
                            height: size.height,
                            child: const Center(
                              child: Text(
                                'No Data Found',
                                style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ),
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 10,
                              ),
                              ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemCount:
                                    onlinepaymentProviders.responseData.length,
                                itemBuilder: (_, index) {
                                  final interval = onlinepaymentProviders
                                      .responseData[index];

                                  // Check if the interval is paid
                                  bool isPaid = interval['paid'];

                                  // Check if the interval is selected

                                  bool isSelected =
                                      setValues.contains(interval['interval']);
                                  print('isSelected thing vslue :$isSelected');

                                  print(onlinepaymentProviders
                                      .responseData.length);
                                  print(onlinepaymentProviders
                                      .selectedCardCheckboxes.length);
                                  if (onlinepaymentProviders
                                          .selectedCardCheckboxes.isEmpty ||
                                      index >=
                                          onlinepaymentProviders
                                              .selectedCardCheckboxes.length) {
                                    print(
                                        'selectedCardCheckboxes is empty or index is out of bounds');
                                    return const SizedBox
                                        .shrink(); // or return an empty widget
                                  }

                                  print(
                                      'selectedCardCheckboxes[$index]: ${onlinepaymentProviders.selectedCardCheckboxes[index]}');
                                  return onlinepaymentProviders
                                                  .responseData[index]
                                              ['interval'] ==
                                          ""
                                      ? Container()
                                      : Padding(
                                          padding:
                                              const EdgeInsets.only(top: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Card(
                                                margin: EdgeInsets.zero,
                                                elevation: 5,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                                child: Container(
                                                  height: onlinepaymentProviders
                                                              .responseData
                                                              .length ==
                                                          1
                                                      ? size.height * 0.45
                                                      : onlinepaymentProviders
                                                                  .responseData
                                                                  .length ==
                                                              2
                                                          ? size.height * 0.35
                                                          : onlinepaymentProviders
                                                                      .responseData
                                                                      .length ==
                                                                  3
                                                              ? size.height *
                                                                  0.22
                                                              : size.height *
                                                                  0.18,
                                                  width: size.width * 0.42,
                                                  decoration: BoxDecoration(
                                                      gradient:
                                                          onlinepaymentProviders
                                                                              .responseData[
                                                                          index]
                                                                      [
                                                                      'paid'] ==
                                                                  true
                                                              ? Appcolor
                                                                  .sliderGradient
                                                              : Appcolor
                                                                  .redGradient,
                                                      borderRadius:
                                                          const BorderRadius
                                                                  .only(
                                                              topLeft: Radius
                                                                  .circular(10),
                                                              bottomLeft: Radius
                                                                  .circular(
                                                                      10))),
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 2.0,
                                                        vertical: 2.0),
                                                    child: Column(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Month',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  size.width *
                                                                      0.035,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                        Text(
                                                          onlinepaymentProviders
                                                                  .responseData[
                                                              index]['interval'],
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize:
                                                                  size.width *
                                                                      0.03,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: InkWell(
                                                  onTap: () {
                                                    setValues = [];
                                                    setState(() {
                                                      selectedContainerIndex =
                                                          index;
                                                      print(
                                                          'Selected index: $selectedContainerIndex');

                                                      // if (selectedContainerIndex ==
                                                      //     2) {
                                                      //   setState(() {
                                                      //     installment1 =
                                                      //         "April,May,June";
                                                      //     installment2 = "";
                                                      //     installment3 = "";
                                                      //     installment4 = "";
                                                      //   });
                                                      // } else if (selectedContainerIndex ==
                                                      //     5) {
                                                      //   setState(() {
                                                      //     installment1 =
                                                      //         "April,May,June";
                                                      //     installment2 =
                                                      //         "July,August,September";
                                                      //     installment3 = "";
                                                      //     installment4 = "";
                                                      //   });
                                                      // } else if (selectedContainerIndex ==
                                                      //     8) {
                                                      //   setState(() {
                                                      //     installment1 =
                                                      //         "April,May,June";
                                                      //     installment2 =
                                                      //         "July,August,September";
                                                      //     installment3 =
                                                      //         "October,November,December";

                                                      //     installment4 = "";
                                                      //   });
                                                      // } else if (selectedContainerIndex ==
                                                      //     12) {
                                                      //   setState(() {
                                                      //     installment1 =
                                                      //         "April,May,June";
                                                      //     installment2 =
                                                      //         "July,August,September";
                                                      //     installment3 =
                                                      //         "October,November,December";
                                                      //     installment4 =
                                                      //         "January,February,March";
                                                      //   });
                                                      // } else {
                                                      //   installment1 = "";
                                                      //   installment2 = "";
                                                      //   installment3 = "";
                                                      //   installment4 = "";
                                                      // }
                                                      onlinepaymentProviders
                                                                  .selectedCardCheckboxes[
                                                              index] =
                                                          !onlinepaymentProviders
                                                                  .selectedCardCheckboxes[
                                                              index];

                                                      if (onlinepaymentProviders
                                                              .selectedCardCheckboxes[
                                                          index]) {
                                                        // for (int i = 0;
                                                        //     i <=
                                                        //         selectedContainerIndex!;
                                                        //     i++) {

                                                        cu_amt = onlinepaymentProviders
                                                                .responseData[
                                                            index]['Cu_amount'];
                                                        // }

                                                        // Add all unpaid intervals before the selected one
                                                        for (int i = 0;
                                                            i <= index;
                                                            i++) {
                                                          if (!onlinepaymentProviders
                                                                  .responseData[
                                                              i]['paid']) {
                                                            setValues.add(
                                                                onlinepaymentProviders
                                                                        .responseData[i]
                                                                    [
                                                                    'interval']);
                                                          }
                                                        }
                                                      } else {
                                                        setState(() {
                                                          for (int i = 0;
                                                              i <=
                                                                  onlinepaymentProviders
                                                                      .responseData
                                                                      .length;
                                                              i++) {
                                                            if (i <
                                                                    onlinepaymentProviders
                                                                        .selectedCardCheckboxes
                                                                        .length &&
                                                                !onlinepaymentProviders
                                                                        .responseData[
                                                                    i]['paid']) {
                                                              onlinepaymentProviders
                                                                      .selectedCardCheckboxes[
                                                                  i] = false;
                                                              setValues = [];
                                                            }
                                                            setValues = [];
                                                          }
                                                        });
                                                        // Remove all intervals above the selected one
                                                      }

                                                      // Remove duplicates
                                                      setValues = setValues
                                                          .toSet()
                                                          .toList();
                                                      print(setValues);

                                                      // Convert to a comma-separated string
                                                      stringList =
                                                          setValues.join(",");

                                                      print(
                                                          'stringList is $stringList');
                                                      newStringList =
                                                          "$stringList,";
                                                      print(
                                                          'newstringList is $newStringList');
                                                    });
                                                  },
                                                  child: Card(
                                                    margin: EdgeInsets.zero,
                                                    elevation: 5,
                                                    shape:
                                                        const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        bottomRight:
                                                            Radius.circular(10),
                                                        topRight:
                                                            Radius.circular(10),
                                                      ),
                                                    ),
                                                    child: Container(
                                                      clipBehavior: Clip.none,
                                                      height: onlinepaymentProviders
                                                                  .responseData
                                                                  .length ==
                                                              1
                                                          ? size.height * 0.45
                                                          : onlinepaymentProviders
                                                                      .responseData
                                                                      .length ==
                                                                  2
                                                              ? size.height *
                                                                  0.35
                                                              : onlinepaymentProviders
                                                                          .responseData
                                                                          .length ==
                                                                      3
                                                                  ? size.height *
                                                                      0.22
                                                                  : size.height *
                                                                      0.18,
                                                      decoration: BoxDecoration(
                                                          color: isSelected
                                                              ? Colors.amber
                                                              : Colors.white,
                                                          borderRadius:
                                                              const BorderRadius
                                                                      .only(
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10))),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Installments',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      size.width *
                                                                          0.04,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Row(
                                                              children: [
                                                                Container(
                                                                  decoration: BoxDecoration(
                                                                      color: Colors
                                                                          .lightBlue,
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              5)),
                                                                  child:
                                                                      Padding(
                                                                    padding: const EdgeInsets
                                                                            .symmetric(
                                                                        horizontal:
                                                                            10.0,
                                                                        vertical:
                                                                            5.0),
                                                                    child: Text(
                                                                        ' \u20B9${onlinepaymentProviders.responseData[index]['amount']}',
                                                                        style: TextStyle(
                                                                            fontSize: size.width *
                                                                                0.028,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold)),
                                                                  ),
                                                                ),
                                                                const Spacer(),
                                                                Image.asset(
                                                                  'assets/images/money.png',
                                                                  height: 30,
                                                                  width: 30,
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Text(
                                                              'Amount to be Paid:',
                                                              style: TextStyle(
                                                                  fontSize:
                                                                      size.width *
                                                                          0.03,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Expanded(
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                children: [
                                                                  Expanded(
                                                                    child:
                                                                        Container(
                                                                      height: size
                                                                              .height *
                                                                          0.035,
                                                                      decoration: BoxDecoration(
                                                                          gradient: Appcolor
                                                                              .pinkGradient,
                                                                          borderRadius:
                                                                              BorderRadius.circular(5)),
                                                                      child:
                                                                          Center(
                                                                        child: Text(
                                                                            ' \u20B9${onlinepaymentProviders.responseData[index]['Cu_amount']}',
                                                                            style: TextStyle(
                                                                                fontSize: size.width * 0.028,
                                                                                color: Colors.white,
                                                                                fontWeight: FontWeight.bold)),
                                                                      ),
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 10,
                                                                  ),
                                                                  Text(
                                                                      'Status: ',
                                                                      style: TextStyle(
                                                                          fontSize: size.width *
                                                                              0.03,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  Container(
                                                                    decoration: BoxDecoration(
                                                                        gradient: onlinepaymentProviders.responseData[index]['paid'] ==
                                                                                true
                                                                            ? Appcolor
                                                                                .sliderGradient
                                                                            : Appcolor
                                                                                .redGradient,
                                                                        borderRadius:
                                                                            BorderRadius.circular(5)),
                                                                    child:
                                                                        Padding(
                                                                      padding: const EdgeInsets
                                                                              .symmetric(
                                                                          horizontal:
                                                                              10.0,
                                                                          vertical:
                                                                              2.0),
                                                                      child: Text(
                                                                          onlinepaymentProviders.responseData[index]['paid'] == true
                                                                              ? 'Paid'
                                                                              : 'Unpaid',
                                                                          style: TextStyle(
                                                                              fontSize: size.width * 0.028,
                                                                              color: Colors.white,
                                                                              fontWeight: FontWeight.bold)),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                },
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          ),
              ),
            )),
      ),
    );
  }

  void handleResponse(Map<dynamic, dynamic> response) async {
    final pref = await SharedPreferences.getInstance();
    final onlinepaymentProviders =
        // ignore: use_build_context_synchronously
        Provider.of<OnlinePaymentViewModel>(context, listen: false);

    print('after transaction response is :->>>$response');

    // print('toastValue is --->> $toastValue');
    successCode = response['msg'];
    if (successCode != null) {
      List<String> resultList = successCode!.replaceAll('|', ',').split(',');
      print('resultList is -->$resultList');
      txn_status = resultList[0];

      txn_msg = resultList[1];

      tpsl_txn_id = resultList[5];
      txn_amt = resultList[6];
      card_id = resultList[10];
      BankTransactionID = resultList[12];
      returnedHash = resultList[15];
    } else {}

    print('successCode is---->>>$successCode');

    // Fluttertoast.showToast(
    //     msg: '$response', fontSize: 12, textColor: Colors.white);
    // ignore: use_build_context_synchronously
    onlinepaymentProviders.getResponseOnlineTransaction(
        txn_msg.toString(),
        onlinepaymentProviders.tranid.toString(),
        onlinepaymentProviders.monthIntervals.toString(),
        tpsl_txn_id.toString(),
        BankTransactionID.toString(),
        double.parse(txn_amt.toString()),
        "",
        txn_status.toString(),
        returnedHash.toString(),
        context);

    // showAlertDialog(context, "WL SDK Response", "$response");
  }
}
