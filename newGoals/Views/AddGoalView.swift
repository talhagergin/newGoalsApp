import SwiftUI

struct AddGoalView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var goalManager: GoalManager
    
    @State private var title = ""
    @State private var category = Goal.GoalCategory.personal
    @State private var description = ""
    @State private var dueDate = Date()
    @State private var targetAmount = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Hedef Detayları") {
                    TextField("Hedef Adı", text: $title)
                    
                    Picker("Kategori", selection: $category) {
                        ForEach(Goal.GoalCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    
                    TextEditor(text: $description)
                        .frame(height: 100)
                }
                
                Section("Hedef Bilgileri") {
                    DatePicker("Bitiş Tarihi", selection: $dueDate, displayedComponents: .date)
                    
                    TextField("Hedef Miktar", text: $targetAmount)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("Yeni Hedef")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet") {
                        saveGoal()
                        dismiss()
                    }
                    .disabled(title.isEmpty || targetAmount.isEmpty)
                }
            }
        }
    }
    
    private func saveGoal() {
        let goal = Goal(
            title: title,
            category: category,
            description: description,
            dueDate: dueDate,
            progress: 0,
            targetAmount: Int(targetAmount) ?? 0,
            currentAmount: 0,
            isCompleted: false
        )
        goalManager.addGoal(goal)
    }
} 