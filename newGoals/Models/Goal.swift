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
    private var _isCompleted: Bool = false
    var tags: Set<String> = []
    var isArchived: Bool = false
    var reminders: [Reminder] = []
    var subGoals: [SubGoal] = []
    var parentGoalId: UUID?
    var journals: [JournalEntry] = []
    var recurringReminders: [ReminderSchedule] = []
    
    init(
        title: String,
        category: GoalCategory,
        description: String,
        dueDate: Date,
        progress: Double = 0,
        targetAmount: Int,
        currentAmount: Int = 0
    ) {
        self.id = UUID()
        self.title = title
        self.category = category
        self.description = description
        self.dueDate = dueDate
        self.progress = progress
        self.targetAmount = targetAmount
        self.currentAmount = currentAmount
        self._isCompleted = false
        self.tags = []
        self.isArchived = false
        self.reminders = []
        self.subGoals = []
        self.parentGoalId = nil
        self.journals = []
        self.recurringReminders = []
    }
    
    var isCompleted: Bool {
        get {
            currentAmount >= targetAmount || _isCompleted
        }
        set {
            _isCompleted = newValue
        }
    }
    
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

extension Goal {
    func calculateStreak(using goals: [Goal]) -> Int {
        let calendar = Calendar.current
        var currentStreak = 0
        let sortedGoals = goals
            .filter { $0.category == self.category }
            .sorted { $0.dueDate > $1.dueDate }
        
        var currentDate = calendar.startOfDay(for: Date())
        
        for goal in sortedGoals {
            let goalDate = calendar.startOfDay(for: goal.dueDate)
            
            // Eğer hedef tamamlanmışsa ve tarih ardışıksa
            if goal.isCompleted && calendar.isDate(goalDate, inSameDayAs: currentDate) {
                currentStreak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
            } else {
                break
            }
        }
        
        return currentStreak
    }
} 