import SwiftUI

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    let goalManager: GoalManager
    
    @State private var reminderDate = Date()
    @State private var reminderMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Hatırlatıcı Detayları") {
                    DatePicker("Tarih", selection: $reminderDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.graphical)
                    
                    TextField("Mesaj", text: $reminderMessage, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Button("Test Bildirimi Gönder") {
                        sendTestNotification()
                    }
                }
            }
            .navigationTitle("Hatırlatıcı Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        goalManager.scheduleReminder(for: goal, date: reminderDate, message: reminderMessage)
                        dismiss()
                    }
                    .disabled(reminderMessage.isEmpty)
                }
            }
        }
    }
    
    private func sendTestNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Test Bildirimi"
        content.body = "Bu bir test bildirimidir"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Test bildirimi gönderilemedi: \(error.localizedDescription)")
            } else {
                print("Test bildirimi 5 saniye sonra gönderilecek")
            }
        }
    }
} 