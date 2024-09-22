import Cocoa
import UserNotifications

class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    func applicationDidFinishLaunching(_ notification: Notification) {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        print("UNUserNotificationCenter delegate set to AppDelegate.")
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        print("userNotificationCenter(_:willPresent:withCompletionHandler:) called.")
        // Present the notification even when the app is in the foreground
        completionHandler([.banner, .list, .sound])
    }
}
