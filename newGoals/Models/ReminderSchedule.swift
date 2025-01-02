import Foundation
import UserNotifications
import SwiftUI

struct ReminderSchedule: Identifiable, Codable {
    var id = UUID()
    var goalId: UUID
    var frequency: Frequency
    var time: Date
    var daysOfWeek: Set<DayOfWeek>
    var message: String
    var isEnabled: Bool
    
    enum Frequency: String, Codable, CaseIterable {
        case daily = "Günlük"
        case weekly = "Haftalık"
        case monthly = "Aylık"
        
        var description: String {
            switch self {
            case .daily: return "Her gün"
            case .weekly: return "Her hafta"
            case .monthly: return "Her ay"
            }
        }
    }
    
    enum DayOfWeek: Int, Codable, CaseIterable {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
        
        var name: String {
            switch self {
            case .sunday: return "Pazar"
            case .monday: return "Pazartesi"
            case .tuesday: return "Salı"
            case .wednesday: return "Çarşamba"
            case .thursday: return "Perşembe"
            case .friday: return "Cuma"
            case .saturday: return "Cumartesi"
            }
        }
        
        var shortName: String {
            switch self {
            case .sunday: return "Paz"
            case .monday: return "Pzt"
            case .tuesday: return "Sal"
            case .wednesday: return "Çar"
            case .thursday: return "Per"
            case .friday: return "Cum"
            case .saturday: return "Cmt"
            }
        }
    }
}

extension GoalManager {
    func scheduleRecurringReminder(_ schedule: ReminderSchedule) {
        let content = UNMutableNotificationContent()
        content.title = "Hedef Hatırlatıcısı"
        content.body = schedule.message
        content.sound = .default
        
        var components = Calendar.current.dateComponents([.hour, .minute], from: schedule.time)
        
        switch schedule.frequency {
        case .daily:
            components.weekday = nil
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            scheduleNotification(content: content, trigger: trigger, identifier: schedule.id.uuidString)
            
        case .weekly:
            for weekday in schedule.daysOfWeek {
                components.weekday = weekday.rawValue
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
                let identifier = "\(schedule.id)-\(weekday.rawValue)"
                scheduleNotification(content: content, trigger: trigger, identifier: identifier)
            }
            
        case .monthly:
            components.day = Calendar.current.component(.day, from: schedule.time)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
            scheduleNotification(content: content, trigger: trigger, identifier: schedule.id.uuidString)
        }
    }
    
    private func scheduleNotification(content: UNNotificationContent, trigger: UNCalendarNotificationTrigger, identifier: String) {
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Tekrarlayan bildirim planlanamadı: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelRecurringReminder(_ schedule: ReminderSchedule) {
        switch schedule.frequency {
        case .weekly:
            let identifiers = schedule.daysOfWeek.map { "\(schedule.id)-\($0.rawValue)" }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
        case .daily, .monthly:
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [schedule.id.uuidString])
        }
    }
}

// MARK: - Views
struct RecurringReminderView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    @ObservedObject var goalManager: GoalManager
    
    @State private var frequency: ReminderSchedule.Frequency = .daily
    @State private var selectedTime = Date()
    @State private var selectedDays: Set<ReminderSchedule.DayOfWeek> = []
    @State private var message = ""
    
    var body: some View {
        Form {
            Section("Hatırlatıcı Detayları") {
                Picker("Sıklık", selection: $frequency) {
                    ForEach(ReminderSchedule.Frequency.allCases, id: \.self) { freq in
                        Text(freq.rawValue).tag(freq)
                    }
                }
                
                DatePicker("Saat", selection: $selectedTime, displayedComponents: .hourAndMinute)
                
                if frequency == .weekly {
                    WeekdayPicker(selectedDays: $selectedDays)
                }
                
                TextField("Mesaj", text: $message, axis: .vertical)
                    .lineLimit(3...6)
            }
        }
        .navigationTitle("Tekrarlayan Hatırlatıcı")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("İptal") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Kaydet") {
                    saveReminder()
                    dismiss()
                }
                .disabled(message.isEmpty || (frequency == .weekly && selectedDays.isEmpty))
            }
        }
    }
    
    private func saveReminder() {
        let schedule = ReminderSchedule(
            id: UUID(),
            goalId: goal.id,
            frequency: frequency,
            time: selectedTime,
            daysOfWeek: selectedDays,
            message: message,
            isEnabled: true
        )
        
        goalManager.scheduleRecurringReminder(schedule)
        
        var updatedGoal = goal
        updatedGoal.recurringReminders.append(schedule)
        goalManager.updateGoal(updatedGoal)
    }
}

struct WeekdayPicker: View {
    @Binding var selectedDays: Set<ReminderSchedule.DayOfWeek>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Günler")
                .font(.headline)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 10) {
                ForEach(ReminderSchedule.DayOfWeek.allCases, id: \.self) { day in
                    DayButton(day: day, isSelected: selectedDays.contains(day)) {
                        if selectedDays.contains(day) {
                            selectedDays.remove(day)
                        } else {
                            selectedDays.insert(day)
                        }
                    }
                }
            }
        }
        .padding(.vertical)
    }
}

struct DayButton: View {
    let day: ReminderSchedule.DayOfWeek
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(day.shortName)
                .font(.caption)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .background(isSelected ? Color.accentColor : Color.secondary.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
} 