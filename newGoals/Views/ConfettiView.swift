import SwiftUI

struct ConfettiView: View {
    @State private var particles: [(Double, Double, Color)] = []
    @State private var timer: Timer?
    let colors: [Color] = [.red, .blue, .green, .yellow, .purple, .orange]
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                for (x, y, color) in particles {
                    let rect = CGRect(x: x * size.width, y: y * size.height, width: 5, height: 5)
                    context.fill(Path(ellipseIn: rect), with: .color(color))
                }
            }
        }
        .onAppear {
            startConfetti()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    private func startConfetti() {
        // Başlangıç parçacıkları
        for _ in 0..<50 {
            particles.append((
                Double.random(in: 0...1),
                Double.random(in: -0.1...0),
                colors.randomElement() ?? .red
            ))
        }
        
        // Animasyon timer'ı
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            withAnimation {
                // Parçacıkları hareket ettir
                for i in particles.indices {
                    particles[i].1 += 0.01
                    particles[i].0 += Double.random(in: -0.02...0.02)
                }
                
                // Ekrandan çıkan parçacıkları temizle
                particles.removeAll { $0.1 > 1.2 }
                
                // Yeni parçacıklar ekle
                if particles.count < 50 {
                    particles.append((
                        Double.random(in: 0...1),
                        Double.random(in: -0.1...0),
                        colors.randomElement() ?? .red
                    ))
                }
            }
        }
    }
} 