import SwiftUI

// MARK: - Models
struct GoalShare: Identifiable, Codable {
    var id = UUID()
    var goalId: UUID
    var sharedWith: [String] // e-posta adresleri
    var canEdit: Bool
    var sharedDate: Date
}

struct MotivationPost: Identifiable, Codable {
    var id = UUID()
    var userId: String
    var content: String
    var date: Date
    var likes: Int
    var type: PostType
    
    enum PostType: String, Codable, CaseIterable {
        case text = "Metin"
        case quote = "Alıntı"
        case achievement = "Başarı"
        
        var icon: String {
            switch self {
            case .text: return "text.bubble"
            case .quote: return "quote.bubble"
            case .achievement: return "star"
            }
        }
        
        var color: Color {
            switch self {
            case .text: return .blue
            case .quote: return .purple
            case .achievement: return .orange
            }
        }
    }
}

// MARK: - Views
struct SharedGoalRow: View {
    let share: GoalShare
    let goal: Goal?
    
    var body: some View {
        VStack(alignment: .leading) {
            if let goal = goal {
                Text(goal.title)
                    .font(.headline)
                HStack {
                    Image(systemName: goal.category.icon)
                        .foregroundColor(goal.category.color)
                    Text(goal.category.rawValue)
                        .foregroundColor(.secondary)
                }
            } else {
                Text("Silinmiş Hedef")
                    .foregroundColor(.secondary)
            }
            
            Text("Paylaşılan: \(share.sharedDate.formatted())")
                .font(.caption)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(share.sharedWith, id: \.self) { email in
                        HStack {
                            Image(systemName: "person.circle.fill")
                            Text(email)
                        }
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(.ultraThinMaterial))
                    }
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
    }
}

struct MotivationPostView: View {
    let post: MotivationPost
    @State private var isLiked = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                VStack(alignment: .leading) {
                    Text(post.userId)
                        .font(.headline)
                    Text(post.date.formatted())
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Text(post.content)
                .font(.body)
            
            HStack {
                Button(action: { isLiked.toggle() }) {
                    HStack {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                        Text("\(post.likes + (isLiked ? 1 : 0))")
                    }
                }
                
                Spacer()
                
                Label(post.type.rawValue, systemImage: post.type.icon)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(.ultraThinMaterial)
                            .foregroundStyle(post.type.color)
                    )
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
    }
}

struct SocialFeaturesView: View {
    @ObservedObject var goalManager: GoalManager
    @State private var showingShareSheet = false
    @State private var showingNewPost = false
    @State private var newPostContent = ""
    
    var body: some View {
        List {
            Section("Hedef Arkadaşları") {
                ForEach(goalManager.sharedGoals) { share in
                    SharedGoalRow(
                        share: share,
                        goal: goalManager.goals.first { $0.id == share.goalId }
                    )
                    .listRowInsets(EdgeInsets())
                    .listRowBackground(Color.clear)
                }
            }
            
            Section("Motivasyon Duvarı") {
                Button(action: { showingNewPost = true }) {
                    Label("Yeni Gönderi", systemImage: "plus.bubble")
                }
                
                ForEach(goalManager.motivationPosts) { post in
                    MotivationPostView(post: post)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                }
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Sosyal")
        .sheet(isPresented: $showingNewPost) {
            NavigationStack {
                NewPostView(goalManager: goalManager)
            }
        }
    }
}

struct NewPostView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var goalManager: GoalManager
    @State private var content = ""
    @State private var postType: MotivationPost.PostType = .text
    
    var body: some View {
        Form {
            Section {
                Picker("Gönderi Tipi", selection: $postType) {
                    ForEach(MotivationPost.PostType.allCases, id: \.self) { type in
                        Label(type.rawValue, systemImage: type.icon)
                            .foregroundStyle(type.color)
                    }
                }
                
                TextEditor(text: $content)
                    .frame(height: 150)
            }
        }
        .navigationTitle("Yeni Gönderi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("İptal") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Paylaş") {
                    savePost()
                    dismiss()
                }
                .disabled(content.isEmpty)
            }
        }
    }
    
    private func savePost() {
        let post = MotivationPost(
            id: UUID(),
            userId: "Ben", // Gerçek uygulamada kullanıcı adı
            content: content,
            date: Date(),
            likes: 0,
            type: postType
        )
        
        var updatedPosts = goalManager.motivationPosts
        updatedPosts.insert(post, at: 0)
        goalManager.motivationPosts = updatedPosts
    }
}

#Preview {
    NavigationStack {
        SocialFeaturesView(goalManager: GoalManager())
    }
} 