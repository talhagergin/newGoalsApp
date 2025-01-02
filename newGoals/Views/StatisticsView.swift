import SwiftUI
import Charts

struct StatisticsView: View {
    @ObservedObject var goalManager: GoalManager
    
    var body: some View {
        List {
            Section("Kategori Dağılımı") {
                Chart {
                    ForEach(Goal.GoalCategory.allCases, id: \.self) { category in
                        let count = goalManager.goals.filter { $0.category == category }.count
                        BarMark(
                            x: .value("Kategori", category.rawValue),
                            y: .value("Hedef Sayısı", count)
                        )
                        .foregroundStyle(category.color)
                    }
                }
                .frame(height: 200)
            }
            
            Section("Tamamlanma Oranları") {
                ForEach(Goal.GoalCategory.allCases, id: \.self) { category in
                    let goals = goalManager.goals.filter { $0.category == category }
                    let completed = goals.filter { $0.isCompleted }.count
                    let total = goals.count
                    
                    HStack {
                        Text(category.emoji + " " + category.rawValue)
                        Spacer()
                        Text("\(completed)/\(total)")
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .navigationTitle("İstatistikler")
    }
} 