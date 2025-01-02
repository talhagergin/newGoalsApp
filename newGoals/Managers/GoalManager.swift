import Foundation
import UserNotifications

class GoalManager: ObservableObject {
    @Published var goals: [Goal] = []
    private let saveKey = "SavedGoals"
    
    @Published var sharedGoals: [GoalShare] = []
    @Published var motivationPosts: [MotivationPost] = []
    
    init() {
        loadGoals()
        setupNotifications()
    }
    
    var archivedGoals: [Goal] {
        goals.filter { $0.isArchived }
    }
    
    var activeGoals: [Goal] {
        goals.filter { !$0.isArchived }
    }
    
    func addGoal(_ goal: Goal) {
        goals.append(goal)
        saveGoals()
    }
    
    func updateGoal(_ goal: Goal) {
        if let index = goals.firstIndex(where: { $0.id == goal.id }) {
            goals[index] = goal
            saveGoals()
        }
    }
    
    func deleteGoal(_ goal: Goal) {
        goals.removeAll { $0.id == goal.id }
        saveGoals()
        cancelReminders(for: goal)
    }
    
    func archiveGoal(_ goal: Goal) {
        var updatedGoal = goal
        updatedGoal.isArchived = true
        updateGoal(updatedGoal)
    }
    
    func completionPercentage() -> Double {
        guard !goals.isEmpty else { return 0 }
        
        let totalProgress = goals.reduce(0.0) { sum, goal in
            if goal.isCompleted {
                return sum + 1.0
            } else {
                return sum + (Double(goal.currentAmount) / Double(goal.targetAmount))
            }
        }
        
        return (totalProgress / Double(goals.count)) * 100
    }
    
    // MARK: - Notifications
    private func setupNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                if success {
                    print("Bildirim izni alındı")
                } else if let error = error {
                    print("Bildirim izni alınamadı: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func scheduleReminder(for goal: Goal, date: Date, message: String) {
        let reminder = Reminder(goalId: goal.id, date: date, message: message, isEnabled: true)
        var updatedGoal = goal
        updatedGoal.reminders.append(reminder)
        
        let content = UNMutableNotificationContent()
        content.title = "Hedef Hatırlatıcısı: \(goal.title)"
        content.body = message
        content.sound = .default
        content.badge = 1
        
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        let request = UNNotificationRequest(identifier: reminder.id.uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim planlanamadı: \(error.localizedDescription)")
            } else {
                print("Bildirim başarıyla planlandı: \(date)")
            }
        }
        
        updateGoal(updatedGoal)
    }
    
    func cancelReminders(for goal: Goal) {
        let identifiers = goal.reminders.map { $0.id.uuidString }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    // MARK: - Persistence
    private func saveGoals() {
        if let encoded = try? JSONEncoder().encode(goals) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadGoals() {
        if let data = UserDefaults.standard.data(forKey: saveKey),
           let decoded = try? JSONDecoder().decode([Goal].self, from: data) {
            goals = decoded
        }
    }
} 