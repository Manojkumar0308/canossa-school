// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:canossa/online_payment/view/failure.dart';
import 'package:canossa/online_payment/view/success.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:provider/provider.dart';
import 'online_payment/view_model/online_payment_viewmodel.dart';
import 'parent_due_fee/view_model/due_fee_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_homework/view_model/add_homeWork_view_model.dart';
import 'login/view/login_screen.dart';
import 'register/view/register_verify_screen.dart';
import 'send_message/view_model/send_message_view_model.dart';
import 'student_by_filter/view/model/view_model/student_by_class_view_model.dart';
import 'student_homework/viewmodel/student_homework_viewmodel.dart';
import 'utils/common_methods.dart';
import '../../view_homework/view_model/view_homework_view_model.dart';
import 'Add_attendance/view_model/view_model.dart';
import 'Exam_result/view_model/exam_result_viewmodel.dart';
import 'admin/get_student_by_filter/view_model/view_model.dart';
import 'admin_sms_report/view_model/view_model.dart';
import 'bottomnavigation/bottomnavigation_screen.dart';
import 'dashboard/view_model/dashboard_view_model.dart';
import 'database/database_helper.dart';
import 'fee_detail/view_model/view_model.dart';
import 'forgot_password/view/password_screen.dart';
import 'leave/view_model/leave_screen_viewmodel.dart';
import 'login/view_model/login_view_model.dart';
import 'menu/view_model/menu_view_model.dart';
import 'notification/view/notification_screen.dart';
import 'notification/view/view_model/notification_refresh_data.dart';
import 'notification_report/view_model/view_model.dart';
import 'notification_services/notification_services.dart';
import 'profile/view_model/profile_view_model.dart';
import 'student_by_regNo/view_model/student_byRegNo_view_model.dart';
import 'utils/appcolors.dart';
import 'utils/navigation_service.dart';
import 'utils/routes_generator.dart';
import 'walkthrough/walkthrough_screen.dart';

import 'student_attendance/view_model/student_attendance_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Initialize the database
  await Firebase.initializeApp(); //Firebase is initialized.
//handle background messages and save notifications to a local database using NotificationDatabaseHelper.
  final dbHelper = NotificationDatabaseHelper();
  await dbHelper.init();
  FirebaseMessaging.onBackgroundMessage(firebaseBackgroundMessageHandler);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]).then(
    (value) => runApp(
      MultiProvider(
        //providers for managing different functionalities and for state management.
        providers: [
          ChangeNotifierProvider(create: (_) => NotificationRefreshProvider()),
          ChangeNotifierProvider(create: (_) => StudentProvider()),
          ChangeNotifierProvider(create: (_) => AttendanceProvider()),
          ChangeNotifierProvider(create: (_) => SendMessageViewModel()),
          ChangeNotifierProvider(create: (_) => MenuViewModel()),
          ChangeNotifierProvider(create: (_) => LoginProvider()),
          ChangeNotifierProvider(create: (_) => StudentByClassViewModel()),
          ChangeNotifierProvider(create: (_) => NotificationReportProvider()),
          ChangeNotifierProvider(create: (_) => StudentBYRegViewModel()),
          ChangeNotifierProvider(create: (_) => HomeworkProvider()),
          ChangeNotifierProvider(create: (_) => ViewHomeworkProvider()),
          ChangeNotifierProvider(create: (_) => AttendanceViewModel()),
          ChangeNotifierProvider(create: (_) => StudentHomeWorkProvider()),
          ChangeNotifierProvider(create: (_) => DashBoardViewModel()),
          ChangeNotifierProvider(create: (_) => GetStudentByRegNoAdmin()),
          ChangeNotifierProvider(create: (_) => DueFeeViewModel()),
          ChangeNotifierProvider(create: (_) => ParentFeeDetailViewModel()),
          ChangeNotifierProvider(create: (_) => ExamResultViewModel()),
          ChangeNotifierProvider(create: (_) => AdminSmsReport()),
          ChangeNotifierProvider(create: (_) => LeaveViewModel()),
          ChangeNotifierProvider(create: (_) => OnlinePaymentViewModel()),
        ],
        child: const MyApp(),
      ),
    ),
  );
}

//instance of NotificationServices class.
NotificationServices notificationServices = NotificationServices();
//instance of Database helper class.
final NotificationDatabaseHelper databaseHelper = NotificationDatabaseHelper();
//handling notifications at terminate state.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundMessageHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
//database initialization.
  await databaseHelper.init();
//notification payload coming from firebase messaging.
  NotificationData notification = NotificationData(
      id: DateTime.now().millisecondsSinceEpoch,
      title: message.data['msgtype'] ?? '',
      content: message.data['content'] ?? '',
      regno: message.data['regno'] ?? '',
      mdate: message.data['mdate'] ?? '',
      msgid: message.data['msgid'] ?? '');

  //inserting notification to sqflite database.
  await databaseHelper.insertNotification(notification);
//method to show notification.
  notificationServices.showNotificationInBackground(message);
  notificationServices.downloadStatus(
    notification.id,
    notification.mdate,
  );
  final pref = await SharedPreferences.getInstance();

  // Save regno in the variable
  pref.setString('notifyregno', message.data['regno']);
  final receivedRegNo = pref.getString('notifyregno');
  print('bck receivedRegNo: $receivedRegNo');
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // ignore: prefer_typing_uninitialized_variables
  var session;
  bool isLoading = true;
  int userID = 0;
  String? resultString;
// initial method when MyApp screen Launch.
  @override
  void initState() {
    super.initState();
    if (Platform.isAndroid) {
      checkForUpdate();
    } else {
      print('No updates available');
    }

    preference();
  }

  Future<void> checkForUpdate() async {
    try {
      final updateInfo = await InAppUpdate.checkForUpdate();
      if (updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
        print('Update available');
        update();
      }
    } catch (e) {
      print('Error checking for update: $e');
      // Handle the error, you can show a user-friendly message or take other actions.
    }
  }

  void update() async {
    try {
      await InAppUpdate.performImmediateUpdate();
    } catch (e) {
      print('Error performing immediate update: $e');
      // Handle the error, you can show a user-friendly message or take other actions.
    }
  }

  Future<void> preference() async {
    final pref = await SharedPreferences.getInstance();

    setState(() {
      session = pref.getString('userToken');
      print('session is :$session');
      if (pref.getInt('userid') != null) {
        userID = pref.getInt('userid')!;
        print('userId is :$userID');
      }

      resultString = pref.getString('resultstring');

      isLoading = false;
    });
  }

  CommonMethods commonMethods = CommonMethods();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //global key used for navigation using current context or currentState.

      title: 'School Jet',
      //routes defined here for navigation purpose.
      // theme: ThemeData(fontFamily: 'Montserrat'),
      routes: {
        'login': (context) => const LoginScreen(),
        '/notification': (context) => const NotificationScreen(),
        '/password_screen': (context) => const ChangePasswordScreen(),
        '/registerVerifyScreen': (context) => const RegVerifyScreen(),
        // '/DirectNotificationScreen': (context) =>
        //     const DirectNotificationScreen(),
        'success': (context) => const Success(),
        'failure': (context) => const Failure()
      },
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.generateRoutes,
      initialRoute: '/',
      navigatorKey: NavigationService().navigatorKey,
      home: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Appcolor.themeColor,
              ),
            )
          : userID.toString().isEmpty || userID == 0
              //if userId is 0 then go to walkthrough screen otherwise go to Bottomnavigation screen.
              ? const WalkthroughScreen()
              : const BottomNavigationScreen(),
    );
  }
}

class AppExitScope extends StatefulWidget {
  final Widget child;

  const AppExitScope({
    super.key,
    required this.child,
  });

  @override
  // ignore: library_private_types_in_public_api
  _AppExitScopeState createState() => _AppExitScopeState();
}

//class to exit the app if user press any device back button.
class _AppExitScopeState extends State<AppExitScope> {
  CommonMethods commonMethods = CommonMethods();
  DateTime? currentBackPressTime;

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: ContainerSelectionDemo(),
//     );
//   }
// }

// class ContainerSelectionDemo extends StatefulWidget {
//   @override
//   _ContainerSelectionDemoState createState() => _ContainerSelectionDemoState();
// }

// class _ContainerSelectionDemoState extends State<ContainerSelectionDemo> {
//   List<bool> containerSelection = List.generate(12, (index) => false);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Selectable Containers'),
//       ),
//       body: Center(
//         child: Wrap(
//           children: List.generate(12, (index) {
//             return GestureDetector(
//               onTap: () {
//                 if (index == 2 || index == 5 || index == 7 || index == 11) {
//                   setState(() {
//                     if (containerSelection[index]) {
//                       containerSelection = List.generate(12, (index) => false);
//                     } else {
//                       for (int i = 0; i <= index; i++) {
//                         containerSelection[i] = true;
//                       }
//                     }
//                   });
//                 }
//               },
//               child: Container(
//                 width: 50,
//                 height: 50,
//                 margin: EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: containerSelection[index] ? Colors.amber : Colors.blue,
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Center(
//                   child: Text(
//                     (index + 1).toString(),
//                     style: TextStyle(color: Colors.white),
//                   ),
//                 ),
//               ),
//             );
//           }),
//         ),
//       ),
//     );
//   }
// }
