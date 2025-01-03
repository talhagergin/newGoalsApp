import SwiftUI

struct MotivationNote: View {
    @State private var showingNote = false
    @State private var currentQuote: String = ""
    
    let motivationalQuotes = [
        "Her gün bir adım!",
        "Küçük ilerlemeler büyük başarılar getirir",
        "Bugün dünden daha iyisin!",
        "Hedefine bir adım daha yakınsın",
        "Vazgeçme, devam et!",
        "Sen yapabilirsin!",
        "İlerleme mükemmellikten daha önemlidir"
    ]
    
    var body: some View {
        VStack {
            if showingNote {
                Text(currentQuote)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(10)
                    .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            showRandomQuote()
        }
    }
    
    private func showRandomQuote() {
        currentQuote = motivationalQuotes.randomElement() ?? ""
        withAnimation {
            showingNote = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            withAnimation {
                showingNote = false
            }
            
            // 10 saniye sonra yeni bir alıntı göster
            DispatchQueue.main.asyncAfter(deadline: .now() + 7) {
                showRandomQuote()
            }
        }
    }
} 