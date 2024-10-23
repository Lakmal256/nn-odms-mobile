import UIKit
import Flutter
import FirebaseCore
import UserNotifications

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()
    registerForNotification()
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
  func registerForNotification(){
    UNUserNotificationCenter.current()
        .requestAuthorization(options : [.alert, .sound, .badge]){ granted, error in
        print("Permission granted : \(granted)")
    }
  }
}
