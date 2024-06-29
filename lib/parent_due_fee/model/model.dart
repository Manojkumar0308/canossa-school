// class StudentDataDueFee {
//   final int stuid;
//   final String stuname;
//   final double netAmt;
//   final String Installments;
//   final double currBal;
//
//   StudentDataDueFee({
//     required this.stuid,
//     required this.stuname,
//     required this.netAmt,
//     required this.Installments,
//     required this.currBal,
//   });
//
//   factory StudentDataDueFee.fromJson(Map<String, dynamic> json) {
//     return StudentDataDueFee(
//       stuid: json['stuid'],
//       stuname: json['stuname'],
//       netAmt: json['NetAmt'] != null
//           ? (json['NetAmt'] is num ? json['NetAmt'].toDouble() : 0.0)
//           : 0.0,
//       Installments: json['Installments'],
//       currBal: json['curr_bal'] != null
//           ? (json['curr_bal'] is num ? json['curr_bal'].toDouble() : 0.0)
//           : 0.0,
//     );
//   }
// }
// To parse this JSON data, do
//
//     final studentDataDueFee = studentDataDueFeeFromJson(jsonString);

import 'dart:convert';

List<StudentDataDueFee> studentDataDueFeeFromJson(String str) => List<StudentDataDueFee>.from(json.decode(str).map((x) => StudentDataDueFee.fromJson(x)));

String studentDataDueFeeToJson(List<StudentDataDueFee> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class StudentDataDueFee {
  int? stuid;
  String? regNo;
  String? stuName;
  String? className;
  String? sectionName;
  String? contactno;
  String? installments;
  double? amount;

  StudentDataDueFee({
    this.stuid,
    this.regNo,
    this.stuName,
    this.className,
    this.sectionName,
    this.contactno,
    this.installments,
    this.amount,
  });

  factory StudentDataDueFee.fromJson(Map<String, dynamic> json) => StudentDataDueFee(
    stuid: json["stuid"],
    regNo: json["RegNo"],
    stuName: json["StuName"],
    className: json["class_name"],
    sectionName: json["section_name"],
    contactno: json["contactno"],
    installments: json["Installments"],
    amount: json["Amount"],
  );

  Map<String, dynamic> toJson() => {
    "stuid": stuid,
    "RegNo": regNo,
    "StuName": stuName,
    "class_name": className,
    "section_name": sectionName,
    "contactno": contactno,
    "Installments": installments,
    "Amount": amount,
  };
}
