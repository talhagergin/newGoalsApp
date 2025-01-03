import SwiftUI

struct GoalShareCard: View {
    let goal: Goal
    @State private var showingChallengeSheet = false
    
    var body: some View {
        VStack(spacing: 16) {
            // Hedef başlığı
            HStack {
                Image(systemName: goal.category.icon)
                    .font(.title)
                    .foregroundColor(goal.category.color)
                Text(goal.title)
                    .font(.headline)
            }
            
            // İlerleme
            VStack(spacing: 8) {
                ProgressView(value: Double(goal.currentAmount) / Double(goal.targetAmount))
                    .tint(goal.category.color)
                Text("\(goal.currentAmount)/\(goal.targetAmount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // Paylaşım butonları
            HStack(spacing: 20) {
                ShareLink(
                    item: "Hedefim: \(goal.title) - İlerleme: %\(Int((Double(goal.currentAmount) / Double(goal.targetAmount)) * 100))",
                    subject: Text("Hedef Paylaşımı"),
                    message: Text("Bu hedefe birlikte ulaşalım!")
                ) {
                    Label("Paylaş", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)
                
                Button(action: { showingChallengeSheet = true }) {
                    Label("Meydan Oku", systemImage: "flame")
                }
                .buttonStyle(.borderedProminent)
            }
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(15)
        .sheet(isPresented: $showingChallengeSheet) {
            ChallengeFriendView(goal: goal)
        }
    }
}

struct ChallengeFriendView: View {
    let goal: Goal
    @Environment(\.dismiss) private var dismiss
    @State private var friendEmail = ""
    @State private var message = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Arkadaşını Davet Et") {
                    TextField("E-posta", text: $friendEmail)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                    
                    TextField("Mesaj", text: $message, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    Text("Arkadaşın bu hedefe katılarak seninle yarışabilir!")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Meydan Oku")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gönder") {
                        // Meydan okuma gönderme işlemi
                        dismiss()
                    }
                    .disabled(friendEmail.isEmpty)
                }
            }
        }
    }
} 