import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {
        requestPermission()
    }
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("Notification permission error: \(error)")
            }
        }
    }
    
    func schedule(_ reminder: Reminder) {
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()
        content.title = reminder.title
        content.body = reminder.body.isEmpty ? reminder.category : reminder.body
        content.sound = .default
        content.badge = 1
        content.categoryIdentifier = "REMINDER_CATEGORY"
        content.userInfo = ["reminderID": reminder.id.uuidString]
        
        let trigger = makeTrigger(for: reminder)
        
        let request = UNNotificationRequest(
            identifier: reminder.notificationID,
            content: content,
            trigger: trigger
        )
        
        center.add(request) { error in
            if let error = error {
                print("Failed to schedule notification: \(error)")
            }
        }
    }
    
    private func makeTrigger(for reminder: Reminder) -> UNNotificationTrigger {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: reminder.date)
        
        switch reminder.repeatType {
        case .none:
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        case .daily:
            let dailyComponents = DateComponents(hour: components.hour, minute: components.minute)
            return UNCalendarNotificationTrigger(dateMatching: dailyComponents, repeats: true)
        case .weekly:
            var weeklyComponents = DateComponents()
            weeklyComponents.weekday = calendar.component(.weekday, from: reminder.date)
            weeklyComponents.hour = components.hour
            weeklyComponents.minute = components.minute
            return UNCalendarNotificationTrigger(dateMatching: weeklyComponents, repeats: true)
        case .monthly:
            var monthlyComponents = DateComponents()
            monthlyComponents.day = components.day
            monthlyComponents.hour = components.hour
            monthlyComponents.minute = components.minute
            return UNCalendarNotificationTrigger(dateMatching: monthlyComponents, repeats: true)
        case .yearly:
            var yearlyComponents = DateComponents()
            yearlyComponents.month = components.month
            yearlyComponents.day = components.day
            yearlyComponents.hour = components.hour
            yearlyComponents.minute = components.minute
            return UNCalendarNotificationTrigger(dateMatching: yearlyComponents, repeats: true)
        case .custom:
            return UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        }
    }
    
    func cancel(id: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    func rescheduleAll(_ reminders: [Reminder]) {
        cancelAll()
        for reminder in reminders where !reminder.isCompleted {
            schedule(reminder)
        }
    }
}
