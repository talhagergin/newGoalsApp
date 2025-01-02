import SwiftUI

struct ShareSheet: View {
    let goal: Goal
    
    var shareText: String {
        """
        🎯 Hedefim: \(goal.title)
        📝 Açıklama: \(goal.description)
        📊 İlerleme: %\(Int((Double(goal.currentAmount) / Double(goal.targetAmount)) * 100))
        """
    }
    
    var body: some View {
        ShareLink(
            item: shareText,
            preview: SharePreview(
                goal.title,
                image: Image(systemName: goal.category.icon)
            )
        )
    }
} 