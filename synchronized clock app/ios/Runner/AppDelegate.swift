import Flutter
import UIKit
import flutter_local_notifications
import flutter_background_service
import permission_handler
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // تسجيل الحزم مع تطبيق Flutter
    GeneratedPluginRegistrant.register(with: self)
    
    // تهيئة الإشعارات المحلية
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
      if granted {
        print("Permission granted for notifications")
      } else {
        print("Permission denied for notifications")
      }
    }
    
    // تهيئة خدمات الخلفية (مثل flutter_background_service)
    FlutterBackgroundServicePlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    // تهيئة إذن البلوتوث إذا كنت تستخدمه
    PermissionHandlerPlugin.setPluginRegistrantCallback { registry in
      GeneratedPluginRegistrant.register(with: registry)
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
