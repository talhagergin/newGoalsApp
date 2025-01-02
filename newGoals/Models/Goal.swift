import SwiftUI

struct Goal: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var category: GoalCategory
    var description: String
    var dueDate: Date
    var progress: Double
    var targetAmount: Int
    var currentAmount: Int
    var isCompleted: Bool
    var tags: Set<String> = []
    var isArchived: Bool = false
    var reminders: [Reminder] = []
    var subGoals: [SubGoal] = []
    var parentGoalId: UUID?
    var journals: [JournalEntry] = []
    var recurringReminders: [ReminderSchedule] = []
    
    enum GoalCategory: String, Codable, CaseIterable {
        case health = "Sağlık"
        case education = "Eğitim"
        case career = "Kariyer"
        case personal = "Kişisel"
        case financial = "Finansal"
        
        var icon: String {
            switch self {
            case .health: return "heart.fill"
            case .education: return "book.fill"
            case .career: return "briefcase.fill"
            case .personal: return "person.fill"
            case .financial: return "dollarsign.circle.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .health: return .red
            case .education: return .blue
            case .career: return .purple
            case .personal: return .orange
            case .financial: return .green
            }
        }
        
        var emoji: String {
            switch self {
            case .health: return "🏃‍♂️"
            case .education: return "📚"
            case .career: return "💼"
            case .personal: return "⭐️"
            case .financial: return "💰"
            }
        }
    }
    
    // Equatable protokolü için özel karşılaştırma fonksiyonu
    static func == (lhs: Goal, rhs: Goal) -> Bool {
        lhs.id == rhs.id &&
        lhs.title == rhs.title &&
        lhs.category == rhs.category &&
        lhs.description == rhs.description &&
        lhs.dueDate == rhs.dueDate &&
        lhs.progress == rhs.progress &&
        lhs.targetAmount == rhs.targetAmount &&
        lhs.currentAmount == rhs.currentAmount &&
        lhs.isCompleted == rhs.isCompleted &&
        lhs.tags == rhs.tags &&
        lhs.isArchived == rhs.isArchived &&
        lhs.reminders == rhs.reminders
    }
    
    var isSubGoalsCompleted: Bool {
        !subGoals.isEmpty && subGoals.allSatisfy { $0.isCompleted }
    }
}

struct SubGoal: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var isCompleted: Bool
} 