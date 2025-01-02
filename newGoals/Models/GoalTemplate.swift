import Foundation
import SwiftUI

struct GoalTemplate: Identifiable, Codable {
    var id = UUID()
    var name: String
    var category: Goal.GoalCategory
    var description: String
    var suggestedDurationInDays: Int
    var recommendedSubGoals: [String]
    
    var suggestedDuration: TimeInterval {
        TimeInterval(suggestedDurationInDays * 24 * 3600)
    }
    
    static let templates = [
        GoalTemplate(
            id: UUID(),
            name: "Kitap Okuma Alışkanlığı",
            category: .education,
            description: "Düzenli kitap okuma alışkanlığı edinme",
            suggestedDurationInDays: 30,
            recommendedSubGoals: [
                "Okuma listesi oluştur",
                "Günlük okuma saati belirle",
                "Okuma günlüğü tut"
            ]
        ),
        GoalTemplate(
            id: UUID(),
            name: "Spor Alışkanlığı",
            category: .health,
            description: "Düzenli egzersiz yapma alışkanlığı edinme",
            suggestedDurationInDays: 60,
            recommendedSubGoals: [
                "Spor programı hazırla",
                "Spor malzemelerini temin et",
                "Günlük egzersiz rutini oluştur"
            ]
        ),
        GoalTemplate(
            id: UUID(),
            name: "Yeni Dil Öğrenme",
            category: .education,
            description: "Yabancı dil öğrenme hedefi",
            suggestedDurationInDays: 90,
            recommendedSubGoals: [
                "Öğrenme kaynakları belirle",
                "Günlük kelime hedefi koy",
                "Pratik yapma planı oluştur"
            ]
        ),
        GoalTemplate(
            id: UUID(),
            name: "Birikim Yapma",
            category: .financial,
            description: "Düzenli tasarruf alışkanlığı edinme",
            suggestedDurationInDays: 180,
            recommendedSubGoals: [
                "Bütçe planı oluştur",
                "Tasarruf hedefi belirle",
                "Otomatik ödeme planı kur"
            ]
        )
    ]
}

// Template kullanarak yeni hedef oluşturma view'ı
struct GoalTemplateView: View {
    let template: GoalTemplate
    @ObservedObject var goalManager: GoalManager
    @Environment(\.dismiss) private var dismiss
    @State private var targetAmount = ""
    
    var body: some View {
        Form {
            Section("Hedef Detayları") {
                Text(template.name)
                    .font(.headline)
                Text(template.description)
                    .foregroundColor(.secondary)
                
                HStack {
                    Image(systemName: template.category.icon)
                        .foregroundColor(template.category.color)
                    Text(template.category.rawValue)
                }
                
                Text("Önerilen Süre: \(template.suggestedDurationInDays) gün")
            }
            
            Section("Alt Hedefler") {
                ForEach(template.recommendedSubGoals, id: \.self) { subGoal in
                    Text(subGoal)
                }
            }
            
            Section("Hedef Miktarı") {
                TextField("Hedef Miktar", text: $targetAmount)
                    .keyboardType(.numberPad)
            }
        }
        .navigationTitle("Şablon Kullan")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Oluştur") {
                    createGoal()
                }
                .disabled(targetAmount.isEmpty)
            }
        }
    }
    
    private func createGoal() {
        let goal = Goal(
            title: template.name,
            category: template.category,
            description: template.description,
            dueDate: Date().addingTimeInterval(template.suggestedDuration),
            progress: 0,
            targetAmount: Int(targetAmount) ?? 0,
            currentAmount: 0,
            isCompleted: false,
            subGoals: template.recommendedSubGoals.map { SubGoal(title: $0, isCompleted: false) }
        )
        
        goalManager.addGoal(goal)
        dismiss()
    }
}

// Şablon listesi view'ı
struct GoalTemplatesListView: View {
    @ObservedObject var goalManager: GoalManager
    
    var body: some View {
        List {
            ForEach(GoalTemplate.templates) { template in
                NavigationLink(destination: GoalTemplateView(template: template, goalManager: goalManager)) {
                    VStack(alignment: .leading) {
                        Text(template.name)
                            .font(.headline)
                        
                        HStack {
                            Image(systemName: template.category.icon)
                                .foregroundColor(template.category.color)
                            Text(template.category.rawValue)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("\(template.recommendedSubGoals.count) alt hedef")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Hedef Şablonları")
    }
} 
