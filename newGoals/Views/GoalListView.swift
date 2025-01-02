import SwiftUI

struct GoalListView: View {
    let goals: [Goal]
    @ObservedObject var goalManager: GoalManager
    
    var body: some View {
        List(goals) { goal in
            NavigationLink(destination: GoalDetailView(goal: goal, goalManager: goalManager)) {
                GoalRowView(goal: goal)
            }
        }
        .listStyle(.inset)
    }
}

struct GoalRowView: View {
    let goal: Goal
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: goal.category.icon)
                    .foregroundColor(.accentColor)
                Text(goal.title)
                    .font(.headline)
                Spacer()
                if goal.isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            ProgressView(value: Double(goal.currentAmount) / Double(goal.targetAmount))
                .tint(.green)
            
            Text("\(goal.currentAmount)/\(goal.targetAmount)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
} 