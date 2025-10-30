import Foundation
import UserNotifications
import RealmSwift // We need ObjectId here

class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization() {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { success, error in
            if success {
                print("Notification authorization granted.")
            } else if let error = error {
                print("Notification authorization error: \(error.localizedDescription)")
            }
        }
    }
    
    // THE FIX IS HERE: We no longer accept a Realm object.
    // We accept simple, thread-safe types.
    func scheduleNotification(plantID: ObjectId, plantName: String, on date: Date) {
        // Ensure the date is in the future
        guard date > Date() else {
            removeNotification(forPlantID: plantID)
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "Time to Water!"
        content.body = "Your plant, \(plantName), is thirsty. Don't forget to water it today."
        content.sound = .default
        
        // We now get the hour and minute from the user's settings to make it more user-friendly
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date)
        dateComponents.hour = 9 // Default to 9 AM, we can make this configurable later
        dateComponents.minute = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: plantID.stringValue, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification for \(plantName): \(error.localizedDescription)")
            } else {
                print("Successfully scheduled notification for \(plantName) at \(dateComponents)")
            }
        }
    }
    
    // THE FIX IS HERE: This method also uses the ID.
    func removeNotification(forPlantID plantID: ObjectId) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [plantID.stringValue])
        print("Removed pending notification for plant ID \(plantID.stringValue)")
    }
}
