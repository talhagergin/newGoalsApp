import SwiftUI

struct Achievement: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var iconName: String // SF Symbol adı
    var isUnlocked: Bool
    
    var icon: Image {
        Image(systemName: iconName)
    }
    
    static let achievements = [
        Achievement(
            title: "Başlangıç",
            description: "İlk hedefini oluştur",
            iconName: "star.fill",
            isUnlocked: false
        ),
        Achievement(
            title: "Azimli",
            description: "5 hedef tamamla",
            iconName: "trophy.fill",
            isUnlocked: false
        ),
        Achievement(
            title: "Uzman",
            description: "Her kategoriden hedef tamamla",
            iconName: "crown.fill",
            isUnlocked: false
        )
    ]
}

// Achievement View
struct AchievementView: View {
    let achievement: Achievement
    
    var body: some View {
        HStack {
            achievement.icon
                .font(.title)
                .foregroundColor(achievement.isUnlocked ? .yellow : .gray)
            
            VStack(alignment: .leading) {
                Text(achievement.title)
                    .font(.headline)
                Text(achievement.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if achievement.isUnlocked {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
        .opacity(achievement.isUnlocked ? 1 : 0.6)
    }
}

// Achievement List View
struct AchievementsListView: View {
    let achievements: [Achievement]
    
    var body: some View {
        List {
            ForEach(achievements) { achievement in
                AchievementView(achievement: achievement)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .navigationTitle("Başarılar")
    }
} 