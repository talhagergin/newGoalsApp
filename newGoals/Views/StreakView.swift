import SwiftUI

struct StreakView: View {
    let consecutiveDays: Int
    @State private var isAnimating = false
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "flame.fill")
                .font(.title2)
                .foregroundColor(.orange)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
            
            VStack(alignment: .leading) {
                Text("\(consecutiveDays) Gün")
                    .font(.headline)
                Text("Kesintisiz İlerleme!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(12)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5).repeatForever()) {
                isAnimating = true
            }
        }
    }
} 