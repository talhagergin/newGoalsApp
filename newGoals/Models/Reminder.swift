import Foundation
import UserNotifications

struct Reminder: Identifiable, Codable, Equatable {
    var id = UUID()
    var goalId: UUID
    var date: Date
    var message: String
    var isEnabled: Bool
    
    // Equatable protokolü için özel karşılaştırma fonksiyonu
    static func == (lhs: Reminder, rhs: Reminder) -> Bool {
        lhs.id == rhs.id &&
        lhs.goalId == rhs.goalId &&
        lhs.date == rhs.date &&
        lhs.message == rhs.message &&
        lhs.isEnabled == rhs.isEnabled
    }
}

// GoalManager'a eklenecek fonksiyonlar
extension GoalManager {
    func scheduleReminder(for goal: Goal, date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Hedef Hatırlatıcısı"
        content.body = "\(goal.title) hedefini unutma!"
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: goal.id.uuidString, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
} 