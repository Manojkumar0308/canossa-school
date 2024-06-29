import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../menu/view/menu_screen.dart';
import '../menu/view_model/menu_view_model.dart';
import '../profile/view_model/profile_view_model.dart';
import 'appcolors.dart';
import 'common_methods.dart';

class CommonAppBar extends StatefulWidget {
  const CommonAppBar({super.key});

  @override
  State<CommonAppBar> createState() => _CommonAppBarState();
}

class _CommonAppBarState extends State<CommonAppBar> {
  bool tap = false;
  @override
  void initState() {
    CommonMethods.preference(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.profile;
    final students = student?.stm ?? [];
    final menuProvider = Provider.of<MenuViewModel>(context);
    return SizedBox(
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
              menuProvider.showStudentList(context, students);

              setState(() {
                tap = false;
              });
            },
            child: Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                  shape: BoxShape.circle, color: Appcolor.lightgrey),
              child: CommonMethods.selectedPhoto == null
                  ? ClipOval(
                      child: Image.asset(
                        'assets/images/user_profile.png',
                        fit: BoxFit.cover,
                      ),
                    ) // Replace with your asset image path
                  : ClipOval(
                      child: Image.network(
                        CommonMethods.selectedPhoto.toString(),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          // Handle network image loading error here
                          return ClipOval(
                            child:
                                Image.asset('assets/images/user_profile.png'),
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
                    CommonMethods.selectedName != null
                        ? 'Name:${CommonMethods.selectedName}'
                        : 'Name:N/A',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontSize: size.width * 0.03),
                  ),
                ),
                Text(
                  CommonMethods.selectedClass != null
                      ? 'Class:${CommonMethods.selectedClass}'
                      : 'Class:N/A',
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      overflow: TextOverflow.ellipsis,
                      fontSize: size.width * 0.03),
                ),
                Text(
                  CommonMethods.selectedRoll == null
                      ? 'Roll:N/A'
                      : 'Roll:${CommonMethods.selectedRoll}',
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
    );
  }
}
