import 'dart:io';

import 'package:canossa/online_payment/view/failure.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:weipl_checkout_flutter/weipl_checkout_flutter.dart';

import '../../host_service/host_services.dart';
import '../../utils/common_methods.dart';
import '../../utils/navigation_service.dart';
import '../view/online_payment_screen.dart';
import '../view/success.dart';

class OnlinePaymentViewModel extends ChangeNotifier {
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  Future<dynamic> navigateTo(String routeName, {dynamic arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  void goBack() {
    return navigatorKey.currentState!.pop();
  }

  String? baseUrl;
  String? card_id;
  String? txn_status;
  String? txn_msg;
  String? txn_amt;
  String? successCode;
  String? BankTransactionID;
  String? returnedHash;
  String? tpsl_txn_id;
  Map<dynamic, dynamic> toastValue = {};
  bool _paynimoCalled = false;
  bool get paynimoCalled => _paynimoCalled;
  late List<bool> selectedCardCheckboxes = [];
  HostService hostService = HostService();
  Map<String, dynamic> data = {};
  List responseData = [];
  bool isLoading = false;
  String? keys;
  String? paymentsalt;
  String? easebuzzbaseUrl;
  String accesskey = '';
  String? tranid;
  String? mail;
  String? hash;
  String? submerchantid;
  int? numericClass;
  String? paynimoMerchantId;
  String? amt;
  String? monthIntervals;
  Map<String, dynamic> decodedResponse = {};
  Map<Object?, dynamic> detailedResponse = {};
  Map<String, dynamic> responseGetOnlineResponse = {};
  static MethodChannel channel = const MethodChannel("easebuzz");
  String? paymentConfirmation;

  Future<void> onlineFeeDetail(
      BuildContext context, String regno, int stuid, int sessid) async {
    final pref = await SharedPreferences.getInstance();
    baseUrl = pref.getString('apiurl');
    final url = Uri.parse(baseUrl.toString() + hostService.onlineFeeDetail);
    print(url);
    final headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8',
    };
    final body =
        jsonEncode({"regno": regno, "stuid": stuid, "sessionid": sessid});
    print('Fee Submissiondetail body: $body');
    try {
      isLoading = true;
      responseData = [];
      notifyListeners();
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        isLoading = false;

        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse != null) {
          data = decodedResponse;
          responseData = data['ofeelist'];
          print('response online fee detail---->>>${response.body}');
          selectedCardCheckboxes = List.generate(
            responseData.length,
            (index) {
              if (responseData[index]['paid'] == true) {
                return true;
              } else {
                return false;
              }
            },
          );
          notifyListeners();
          print(responseData);
        } else {
          // Handle the case where decodedResponse is null
          print("Decoded response is null");
        }
      } else {
        isLoading = false;
        // ignore: use_build_context_synchronously
        CommonMethods().showSnackBar(context, "Something went wrong");
      }

      notifyListeners();
    } catch (e) {
      isLoading = false;
      print(e.toString());
      // ignore: use_build_context_synchronously
      CommonMethods().showSnackBar(context, 'Error occurred');
      notifyListeners();
    }
  }

  Stream<List<dynamic>> onlineFeeDetailStream(
      BuildContext context, String regno, int stuid, int sessid) async* {
    final pref = await SharedPreferences.getInstance();
    baseUrl = pref.getString('apiurl');
    final url = Uri.parse(baseUrl.toString() + hostService.onlineFeeDetail);
    final headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8',
    };
    final body =
        jsonEncode({"regno": regno, "stuid": stuid, "sessionid": sessid});

    try {
      isLoading = true;
      responseData = [];
      notifyListeners();
      final response = await http.post(url, body: body, headers: headers);

      if (response.statusCode == 200) {
        isLoading = false;

        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse != null) {
          data = decodedResponse;
          responseData = data['ofeelist'];

          selectedCardCheckboxes = List.generate(
            responseData.length,
            (index) {
              if (responseData[index]['paid'] == true) {
                return true;
              } else {
                return false;
              }
            },
          );
          yield responseData;
          print('yielded $responseData'); // Emit the response data
        } else {
          // Handle the case where decodedResponse is null
          print("Decoded response is null");
        }
      } else {
        isLoading = false;
        CommonMethods().showSnackBar(context, "Something went wrong");
      }

      notifyListeners();
    } catch (e) {
      isLoading = false;
      print(e.toString());
      CommonMethods().showSnackBar(context, 'Error occurred');
      notifyListeners();
    }
  }

  //get gateway detail api

  Future<void> getGateWayDetail(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final sessionId = pref.getInt('sessionid');
    print(DateTime.now());
    final stuId = pref.getInt('StuId');
    final token = pref.getString('userToken');
    final schoolId = pref.getInt('schoolid');
    notifyListeners();
    baseUrl = pref.getString('apiurl');
    final url = Uri.parse(baseUrl.toString() + hostService.getGatewayDet);
    print(url);
    final headers = {
      "Content-Type":
          "application/x-www-form-urlencoded", // or "application/json" depending on the server
      "Accept": "application/json",
    };
    final body = {
      "stuid": stuId.toString(),
      "sessionid": sessionId.toString(),
      "token": token.toString(),
      "schoolid": schoolId.toString()
    };
    print('get gatewayDetail  body: $body');

    try {
      final response = await http.post(url, body: body, headers: headers);
      print('response of getgatewaydetail is: ${response.body}');

      if (response.statusCode == 200) {
        if (response != null) {
          decodedResponse = jsonDecode(response.body);
          print('decodedResponse is :$decodedResponse');
          if (decodedResponse != null) {
            keys = decodedResponse['key'];

            easebuzzbaseUrl = decodedResponse['baseurl'];
            print('decodedResponse is $decodedResponse');
            if (decodedResponse['submerchantid'] != null &&
                decodedResponse['submerchantid'].toString().isNotEmpty) {
              submerchantid = decodedResponse['submerchantid'];
              notifyListeners();
            }

            if (decodedResponse['numricclass'] != null) {
              numericClass = decodedResponse['numricclass'];
              notifyListeners();
            }

            notifyListeners();
          } else {
            // Handle the case where decodedResponse is null
            print("Decoded response is null");
          }
        }
      } else {
        // ignore: use_build_context_synchronously
        CommonMethods().showSnackBar(context, "Something went wrong");
      }

      notifyListeners();
    } catch (e) {
      print(e.toString());
      // ignore: use_build_context_synchronously
      CommonMethods().showSnackBar(context, 'Error occurred');
      notifyListeners();
    }
  }

  Future<void> getTransactionId(
      BuildContext context,
      String interval,
      double amount,
      String installment1,
      String installment2,
      String installment3,
      String installment4) async {
    final pref = await SharedPreferences.getInstance();
    final sessionId = pref.getInt('sessionid');

    final stuId = pref.getInt('StuId');
    final classId = pref.getInt('classId');
    print('class id is : $classId');
    notifyListeners();
    baseUrl = pref.getString('apiurl');
    final url = Uri.parse(baseUrl.toString() + hostService.getTransId);
    print(url);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    var headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "Transaction_id": DateTime.now().millisecondsSinceEpoch,
      "Transaction_date": formattedDate,
      "stuid": stuId,
      "Intervals": interval,
      "Remark": "",
      "Receipt_no": 0,
      "sessionid": sessionId,
      "amount": amount,
      "Bal_amt": 0.0,
      "PayMode": "",
      "BankId": 0,
      "ETransDetail": "",
      "UpdatedBy": 0,
      "UpdatedOn": "",
      "feesubmissiontype": "",
      "prev_bal": 0.0,
      "discount": 0.0,
      "latefee": 0.0,
      "numericclass": numericClass,
      "convamt": "sample string 20",
      "classid": classId,
      "installment1": installment1,
      "installment2": installment2,
      "installment3": installment3,
      "installment4": installment4,
    });
    print('get Transaction id body is:$body');
    try {
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        if (response != null) {
          var result = jsonDecode(response.body);
          print('get Transaction id response $result');

          if (result['tranid'] != null ||
              result['tranid'].toString().isNotEmpty) {
            tranid = result['tranid'].toString();
          } else {
            print('txnid is null');
          }
          if (result['email'] != null &&
              result['email'].toString().isNotEmpty) {
            mail = result['email'];
            print('mail is :$mail');
          } else {
            print('email is null');
          }

          if (result['hash'] != null || result['hash'].toString().isNotEmpty) {
            hash = result['hash'];
          } else {
            print('txnid is null');
          }

          if (result['amount'] != null) {
            amt = result['amount'].toString();
            notifyListeners();
          } else {
            print('amount is null');
          }

          print(result);
        }
      }
    } catch (e) {
      print(e.toString());
      // ignore: use_build_context_synchronously
      CommonMethods().showSnackBar(context, "Something went wrong");
    }
  }

  //main payment method
  Future<void> initiatePayment(
      double amounttopay, String name, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final phoneNumber = pref.getString('mobno');
    try {
      String key = keys.toString();
      String txnid = tranid.toString();
      num amount = amounttopay;
      String productinfo = "Fee";
      String firstname = name;
      String email = mail ?? "test@b.com";
      String phone = phoneNumber.toString();

      String udf1 = "";
      String udf2 = "";
      String udf3 = "";
      String udf4 = "";
      String udf5 = "";
      String udf6 = "";
      String udf7 = "";
      String udf8 = "";
      String udf9 = "";
      String udf10 = "";
      // Convert amount to string
      String amountString = amount.toString();
      String phonenumber = phone.toString();
      print(key);
      // Concatenate the parameters for hashing
      // final hashString =
      //     "$key|$txnid|$amountString|$productinfo|$firstname|$email|$udf1|$udf2|$udf3|$udf4|$udf5|$udf6|$udf7|$udf8|$udf9|$udf10|$salt";
      // print("hashString:$hashString");

      // // Generate SHA-512 hash
      // hash = generateSHA512Hash(hashString);
      print("hash:$hash");
      final url = Uri.parse("$easebuzzbaseUrl/payment/initiateLink");
      print(url);

      //RequestData....
      final requestData = {
        "key": key,
        "txnid": txnid,
        "amount": amountString,
        "productinfo": productinfo,
        "firstname": firstname,
        "phone": int.parse(phone).toString(),
        "email": email,
        "surl": "https://medium.com/@easebuzz",
        "furl":
            "https://www.youtube.com/results?search_query=easebuzz+payment+gateway+integration+flutter",
        "hash": hash,
        "show_payment_mode": "NB,CC,DAP,MW,UPI,OM,EMI",
        "sub_merchant_id": submerchantid
      };
      print("body:$requestData");
      final headers = {
        "Content-Type":
            "application/x-www-form-urlencoded", // or "application/json" depending on the server
        "Accept": "application/json",
      };
      final response =
          await http.post(url, body: requestData, headers: headers);
      print('Response of initiatedpayment is: $response');

      if (response.statusCode == 200) {
        // Handle successful payment initiation
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Process the response as needed
        print("Payment initiated successfully. Response: $responseData");
        accesskey = responseData['data'];
        String payMode = "production";
        Object parameters = {
          "access_key": responseData['data'],
          "pay_mode": payMode
        };
        print('Parameters are: $parameters');
        final paymentResponse =
            await channel.invokeMethod("payWithEasebuzz", parameters);
        detailedResponse = paymentResponse['payment_response'];

        if (kDebugMode) {
          print('payment response :$detailedResponse');
        }
        if (paymentResponse['result'] == 'payment_successfull') {
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Success()),
          );
        } else {
          Fluttertoast.showToast(
              msg: "User cancelled transaction",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 12.0);
        }
      } else {
        // Handle errors
        print("Error initiating payment: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

//method to send transaction of failure or success payment to the server.
  getResponseOnlineTransaction(
      String status,
      String txnid,
      String interval,
      String easepayid,
      String bankRefNum,
      double amount,
      String bankcode,
      String statuscode,
      String returnedHash,
      BuildContext context) async {
    NavigationService service = NavigationService();

    // Fluttertoast.showToast(msg: 'Get ResponseApi Called');
    final pref = await SharedPreferences.getInstance();
    final sessionId = pref.getInt('sessionid');

    final stuId = pref.getInt('StuId');
    notifyListeners();
    baseUrl = pref.getString('apiurl');
    final classID = pref.getInt('classId');
    try {
      final url = Uri.parse(
          baseUrl.toString() + hostService.getResponseOnlineTransactionUrl);

      final body = jsonEncode({
        "status": status,
        "stuid": stuId,
        "txnid": txnid,
        "classid": classID,
        "interval": interval,
        "easepayid": easepayid,
        "bank_ref_num": bankRefNum,
        "amount": amount,
        "bankcode": bankcode,
        "statuscode": statuscode,
        "sessionid": sessionId,
        "hash": returnedHash,
        "numericclass": numericClass
      });
      // Fluttertoast.showToast(
      //     msg: body, toastLength: Toast.LENGTH_LONG, timeInSecForIosWeb: 4);
      print('getResponseOnlineTransaction body is :$body');
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        responseGetOnlineResponse = json.decode(response.body);

        print('Response is:$responseGetOnlineResponse');
        if (responseGetOnlineResponse['resultcode'] == 0) {
          // Future.delayed(const Duration(seconds: 5), () {
          //   // service.routeTo('/failure', arguments: 'just chill');
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Success()),
          );
          // });
        } else {
          // Future.delayed(const Duration(seconds: 5), () {
          //   // service.routeTo('/failure', arguments: 'just chill');
          // ignore: use_build_context_synchronously
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const Failure()),
          );
          // });
        }

        // Fluttertoast.showToast(msg: response.body);
      } else {
        // Handle errors
        print("Error initiating payment: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }

  String generateSHA512Hash(String input) {
    var bytes = utf8.encode(input);
    var digest = sha512.convert(bytes);
    return digest.toString();
  }

  //payment gateway paynimo
  Future<void> paynimoFun(BuildContext context) async {
    // toastValue = {};
    // successCode = null;

    final pref = await SharedPreferences.getInstance();
    final stuId = pref.getInt('StuId');
    WeiplCheckoutFlutter wlCheckoutFlutter = WeiplCheckoutFlutter();

    String deviceID = ""; // initialize variable

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
        "enableInstrumentDeRegistration": true,
        "enableMerTxnDetails": true
      },
      "consumerData": {
        "deviceId": deviceID,
        "token": hash,
        "paymentMode": "all",
        "merchantLogoUrl":
            "https://www.paynimo.com/CompanyDocs/company-logo-vertical.png", //provided merchant logo will be displayed
        "merchantId": keys,
        "currency": "INR",
        "consumerId": stuId,
        "consumerMobileNo": "",
        "consumerEmailId": "",
        "txnId": tranid, //Unique merchant transaction ID
        "items": [
          {"itemId": "first", "amount": amt, "comAmt": "0"}
        ],
        "customStyle": {
          "PRIMARY_COLOR_CODE": "#45beaa", //merchant primary color code
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

    wlCheckoutFlutter.on(WeiplCheckoutFlutter.wlResponse, handleResponse);
    wlCheckoutFlutter.open(reqJson);

    if (responseGetOnlineResponse.containsKey('resultstring')) {
      paymentConfirmation = responseGetOnlineResponse['resultstring'];
      print(paymentConfirmation);

      if (paymentConfirmation == "success") {
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
      }
    } else {
      print('Key "resultstring" not found in responseGetOnlineResponse');
    }

    // await Future.delayed(Duration(seconds: 10));
  }

  void handleResponse(Map<dynamic, dynamic> response) async {
    final pref = await SharedPreferences.getInstance();

    print('after transaction response is :->>>$response');
    toastValue = response;
    print('toastValue is --->> $toastValue');
    successCode = response['msg'];
    if (successCode != null) {
      List<String> resultList = successCode!.replaceAll('|', ',').split(',');
      print('resultList is -->$resultList');
      txn_status = resultList[0];
      notifyListeners();
      txn_msg = resultList[1];

      tpsl_txn_id = resultList[5];
      txn_amt = resultList[6];
      card_id = resultList[10];
      BankTransactionID = resultList[12];
      returnedHash = resultList[15];
      notifyListeners();
    } else {}

    print('successCode is---->>>$successCode');

    // Fluttertoast.showToast(
    //     msg: '$response', fontSize: 12, textColor: Colors.white);
    // getResponseOnlineTransaction(
    //   txn_msg.toString(),
    //   tranid.toString(),
    //   monthIntervals.toString(),
    //   tpsl_txn_id.toString(),
    //   BankTransactionID.toString(),
    //   double.parse(txn_amt.toString()),
    //   "",
    //   txn_status.toString(),
    //   returnedHash.toString(),
    // );

    notifyListeners();

    // showAlertDialog(context, "WL SDK Response", "$response");
  }

  void intervals(String interval) {
    monthIntervals = interval;
    print('monthIntervals are :$monthIntervals');
    notifyListeners();
  }

  void showAlertDialog(context, String s, String t) {}
}
