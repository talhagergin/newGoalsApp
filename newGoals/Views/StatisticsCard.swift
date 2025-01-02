import SwiftUI

struct StatisticsCard: View {
    let completionPercentage: Double
    
    var body: some View {
        VStack(spacing: 10) {
            Text("Yıllık İlerleme")
                .font(.headline)
            
            ZStack {
                // Arka plan halkası
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 15)
                
                // İlerleme halkası
                Circle()
                    .trim(from: 0, to: completionPercentage / 100)
                    .stroke(
                        Color.green,
                        style: StrokeStyle(
                            lineWidth: 15,
                            lineCap: .round
                        )
                    )
                    .rotationEffect(.degrees(-90))
                
                // Yüzde gösterimi
                Text(String(format: "%.1f%%", completionPercentage))
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.green)
            }
            .frame(width: 120, height: 120)
            .padding()
            .animation(.spring(), value: completionPercentage)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(.ultraThinMaterial)
        )
        .padding()
    }
} 