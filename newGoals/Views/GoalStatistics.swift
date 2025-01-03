import SwiftUI
import Charts

struct GoalStatistics: View {
    let goal: Goal
    
    var weeklyProgress: [(day: String, amount: Int)] {
        let calendar = Calendar.current
        let today = Date()
        let weekDays = (0..<7).map { dayOffset in
            calendar.date(byAdding: .day, value: -dayOffset, to: today)!
        }.reversed()
        
        return weekDays.map { date in
            let dayName = date.formatted(.dateTime.weekday(.narrow))
            let amount = goal.currentAmount // Burada gerçek günlük ilerlemeyi kullanmalısınız
            return (dayName, amount)
        }
    }
    
    var averageProgress: String {
        let average = Double(goal.currentAmount) / Double(daysFromStart)
        return String(format: "%.1f", average)
    }
    
    var daysFromStart: Int {
        let calendar = Calendar.current
        return calendar.numberOfDaysBetween(goal.dueDate, and: Date()) ?? 1
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // İlerleme grafiği
            Chart {
                ForEach(weeklyProgress, id: \.day) { progress in
                    BarMark(
                        x: .value("Gün", progress.day),
                        y: .value("İlerleme", progress.amount)
                    )
                    .foregroundStyle(goal.category.color.gradient)
                }
            }
            .frame(height: 200)
            
            // İstatistik kartları
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                StatCard(title: "Günlük Ort.", value: averageProgress)
                StatCard(title: "Toplam", value: "\(goal.currentAmount)")
                StatCard(title: "Kalan", value: "\(goal.targetAmount - goal.currentAmount)")
            }
            
            // Başarı oranı
            VStack(alignment: .leading) {
                Text("Başarı Oranı")
                    .font(.headline)
                HStack {
                    Text("%\(Int((Double(goal.currentAmount) / Double(goal.targetAmount)) * 100))")
                        .font(.title)
                        .foregroundColor(goal.category.color)
                    Spacer()
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .font(.title2)
                        .foregroundColor(goal.category.color)
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(12)
        }
        .padding()
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.title2)
                .bold()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
    }
}

extension Calendar {
    func numberOfDaysBetween(_ from: Date, and to: Date) -> Int? {
        let fromDate = startOfDay(for: from)
        let toDate = startOfDay(for: to)
        let numberOfDays = dateComponents([.day], from: fromDate, to: toDate)
        return numberOfDays.day
    }
} 