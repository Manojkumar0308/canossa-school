
import UIKit
import Flutter
import Easebuzz

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate,PayWithEasebuzzCallback {
var payResult:FlutterResult!
override func application(
_ application: UIApplication,
didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?
) -> Bool {
self.initializeFlutterChannelMethod()
return super.application(application, didFinishLaunchingWithOptions: launchOptions)
}
// Initialise flutter channel
func initializeFlutterChannelMethod() {
GeneratedPluginRegistrant.register(with: self)
guard let controller = window?.rootViewController as? FlutterViewController else {
fatalError("rootViewController is not type FlutterViewController")
}

let methodChannel = FlutterMethodChannel(name: "easebuzz",
binaryMessenger: controller)
methodChannel.setMethodCallHandler({
[weak self] (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
guard call.method == "payWithEasebuzz" else {
result(FlutterMethodNotImplemented)
return
}
self?.payResult = result;
self?.initiatePaymentAction(call: call);
})
}

// Initiate payment action and call payment gateway
func initiatePaymentAction(call:FlutterMethodCall) {
if let orderDetails = call.arguments as? [String:String]{
let payment = Payment.init(customerData: orderDetails)
let paymentValid = payment.isValid().validity
if !paymentValid {
print("Invalid records")
} else{
PayWithEasebuzz.setUp(pebCallback: self )
PayWithEasebuzz.invokePaymentOptionsView(paymentObj: payment, isFrom: self)
}
}else{
// handle error
let dict = self.setErrorResponseDictError("Empty error", errorMessage: "Invalid validation", result: "Invalid request")
self.payResult(dict)
}
}

// payment call callback and handle response
func PEBCallback(data: [String : AnyObject]) {
if data.count > 0 {
self.payResult(data)
}else{
let dict = self.setErrorResponseDictError("Empty error", errorMessage: "Empty payment response", result: "payment_failed")
self.payResult(dict)
}
}

// Create error response dictionary that the time of something went wrong
func setErrorResponseDictError(_ error: String?, errorMessage: String?, result: String?) -> [AnyHashable : Any]? {
var dict: [AnyHashable : Any] = [:]
var dictChild: [AnyHashable : Any] = [:]
dictChild["error"] = "\(error ?? "")"
dictChild["error_msg"] = "\(errorMessage ?? "")"
dict["result"] = "\(result ?? "")"
dict["payment_response"] = dictChild
return dict
}

}
