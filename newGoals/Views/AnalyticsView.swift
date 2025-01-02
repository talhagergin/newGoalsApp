import SwiftUI
import Charts

struct AnalyticsView: View {
    @ObservedObject var goalManager: GoalManager
    
    var mostSuccessfulCategory: String {
        let categoryCounts = Dictionary(grouping: goalManager.goals.filter { $0.isCompleted }) { $0.category }
        let sortedCategories = categoryCounts.sorted { $0.value.count > $1.value.count }
        return sortedCategories.first?.key.rawValue ?? "Henüz yok"
    }
    
    var averageCompletionTime: String {
        let completedGoals = goalManager.goals.filter { $0.isCompleted }
        guard !completedGoals.isEmpty else { return "Henüz yok" }
        
        let totalDays = completedGoals.reduce(0.0) { sum, goal in
            let interval = goal.dueDate.timeIntervalSince(Date())
            return sum + abs(interval) / (24 * 3600) // Günlere çevir
        }
        
        let average = totalDays / Double(completedGoals.count)
        return String(format: "%.1f gün", average)
    }
    
    var longestStreak: String {
        var currentStreak = 0
        var maxStreak = 0
        let sortedGoals = goalManager.goals.sorted { $0.dueDate < $1.dueDate }
        
        for goal in sortedGoals {
            if goal.isCompleted {
                currentStreak += 1
                maxStreak = max(maxStreak, currentStreak)
            } else {
                currentStreak = 0
            }
        }
        
        return "\(maxStreak) hedef"
    }
    
    var body: some View {
        List {
            Section("Kategori Analizi") {
                CategoryPieChart(goals: goalManager.goals)
                    .frame(height: 200)
            }
            
            Section("Aylık İlerleme") {
                MonthlyProgressChart(goals: goalManager.goals)
                    .frame(height: 200)
            }
            
            Section("Başarı İstatistikleri") {
                VStack(alignment: .leading, spacing: 12) {
                    StatRow(title: "En Başarılı Kategori", value: mostSuccessfulCategory)
                    StatRow(title: "Ortalama Tamamlama Süresi", value: averageCompletionTime)
                    StatRow(title: "En Uzun Hedef Serisi", value: longestStreak)
                }
                .padding(.vertical, 8)
            }
        }
        .navigationTitle("İstatistikler")
    }
}

struct CategoryPieChart: View {
    let goals: [Goal]
    
    var body: some View {
        Chart {
            ForEach(Goal.GoalCategory.allCases, id: \.self) { category in
                let count = goals.filter { $0.category == category }.count
                SectorMark(
                    angle: .value("Hedef Sayısı", count),
                    innerRadius: .ratio(0.618),
                    angularInset: 1.5
                )
                .foregroundStyle(category.color)
                .annotation(position: .overlay) {
                    if count > 0 {
                        Text("\(count)")
                            .font(.caption)
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct MonthlyProgressChart: View {
    let goals: [Goal]
    
    var monthlyData: [(month: Date, completed: Int, total: Int)] {
        let calendar = Calendar.current
        let currentDate = Date()
        let startOfYear = calendar.date(from: calendar.dateComponents([.year], from: currentDate))!
        
        return (0...11).map { month in
            let monthDate = calendar.date(byAdding: .month, value: month, to: startOfYear)!
            let monthGoals = goals.filter {
                calendar.isDate($0.dueDate, equalTo: monthDate, toGranularity: .month)
            }
            let completed = monthGoals.filter { $0.isCompleted }.count
            return (monthDate, completed, monthGoals.count)
        }
    }
    
    var body: some View {
        Chart {
            ForEach(monthlyData, id: \.month) { item in
                BarMark(
                    x: .value("Ay", item.month, unit: .month),
                    y: .value("Hedef", item.total)
                )
                .foregroundStyle(.gray.opacity(0.3))
                
                BarMark(
                    x: .value("Ay", item.month, unit: .month),
                    y: .value("Tamamlanan", item.completed)
                )
                .foregroundStyle(.green)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .month)) { value in
                if let date = value.as(Date.self) {
                    AxisValueLabel {
                        Text(date, format: .dateTime.month(.narrow))
                    }
                }
            }
        }
    }
}

struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
    }
}

#Preview {
    NavigationStack {
        AnalyticsView(goalManager: GoalManager())
    }
} 