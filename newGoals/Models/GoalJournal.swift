import Foundation
import SwiftUI

// MARK: - Models
struct JournalEntry: Identifiable, Codable {
    var id = UUID()
    var goalId: UUID
    var date: Date
    var content: String
    var mood: Mood
    var attachments: [Attachment]
}

// MARK: - Enums
extension JournalEntry {
    enum Mood: String, Codable, CaseIterable {
        case great = "Harika"
        case good = "İyi"
        case neutral = "Normal"
        case bad = "Kötü"
        case terrible = "Çok Kötü"
        
        var icon: String {
            switch self {
            case .great: return "😄"
            case .good: return "🙂"
            case .neutral: return "😐"
            case .bad: return "😕"
            case .terrible: return "😢"
            }
        }
    }
    
    struct Attachment: Identifiable, Codable {
        var id = UUID()
        var type: AttachmentType
        var urlString: String
        
        var url: URL? {
            URL(string: urlString)
        }
    }
}

extension JournalEntry.Attachment {
    enum AttachmentType: String, Codable {
        case image = "Resim"
        case document = "Belge"
        case link = "Bağlantı"
        
        var icon: String {
            switch self {
            case .image: return "photo"
            case .document: return "doc"
            case .link: return "link"
            }
        }
    }
}

// MARK: - Views
struct JournalEntryView: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HeaderView(entry: entry)
            ContentView(entry: entry)
            AttachmentsView(attachments: entry.attachments)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 10).fill(.ultraThinMaterial))
    }
}

private extension JournalEntryView {
    struct HeaderView: View {
        let entry: JournalEntry
        
        var formattedDate: String {
            let calendar = Calendar.current
            if calendar.isDateInToday(entry.date) {
                return "Bugün, " + entry.date.formatted(date: .omitted, time: .shortened)
            } else if calendar.isDateInYesterday(entry.date) {
                return "Dün, " + entry.date.formatted(date: .omitted, time: .shortened)
            } else {
                return entry.date.formatted(date: .long, time: .shortened)
            }
        }
        
        var body: some View {
            HStack {
                Text(formattedDate)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text(entry.mood.icon)
                    .font(.title2)
            }
        }
    }
    
    struct ContentView: View {
        let entry: JournalEntry
        
        var body: some View {
            Text(entry.content)
                .font(.body)
        }
    }
    
    struct AttachmentsView: View {
        let attachments: [JournalEntry.Attachment]
        
        var body: some View {
            if !attachments.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(attachments) { attachment in
                            AttachmentView(attachment: attachment)
                        }
                    }
                }
            }
        }
    }
}

struct AttachmentView: View {
    let attachment: JournalEntry.Attachment
    
    var body: some View {
        HStack {
            Image(systemName: attachment.type.icon)
            if let url = attachment.url {
                Link(destination: url) {
                    Text(url.lastPathComponent)
                        .lineLimit(1)
                }
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Capsule().fill(.secondary.opacity(0.2)))
    }
}

struct JournalListView: View {
    let entries: [JournalEntry]
    
    var sortedEntries: [JournalEntry] {
        entries.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        List {
            ForEach(sortedEntries) { entry in
                JournalEntryView(entry: entry)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color.clear)
            }
        }
        .listStyle(.plain)
        .overlay {
            if entries.isEmpty {
                ContentUnavailableView(
                    "Günlük Girişi Yok",
                    systemImage: "square.and.pencil",
                    description: Text("Henüz bir günlük girişi eklenmemiş")
                )
            }
        }
    }
}

// MARK: - Add Entry View
struct AddJournalEntryView: View {
    @Environment(\.dismiss) private var dismiss
    let goal: Goal
    let goalManager: GoalManager
    let onSave: (Goal) -> Void
    
    @State private var content = ""
    @State private var mood: JournalEntry.Mood = .neutral
    @State private var showingAttachmentPicker = false
    @State private var attachments: [JournalEntry.Attachment] = []
    
    var body: some View {
        Form {
            moodSection
            contentSection
            attachmentsSection
        }
        .navigationTitle("Yeni Günlük Girişi")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            toolbarButtons
        }
    }
}

private extension AddJournalEntryView {
    var moodSection: some View {
        Section("Duygu Durumu") {
            Picker("Nasıl Hissediyorsun?", selection: $mood) {
                ForEach(JournalEntry.Mood.allCases, id: \.self) { mood in
                    Text("\(mood.icon) \(mood.rawValue)").tag(mood)
                }
            }
        }
    }
    
    var contentSection: some View {
        Section("Günlük Girişi") {
            TextEditor(text: $content)
                .frame(height: 150)
        }
    }
    
    var attachmentsSection: some View {
        Section("Ekler") {
            Button(action: { showingAttachmentPicker = true }) {
                Label("Dosya Ekle", systemImage: "paperclip")
            }
            
            ForEach(attachments) { attachment in
                AttachmentView(attachment: attachment)
            }
        }
    }
    
    @ToolbarContentBuilder
    var toolbarButtons: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button("İptal") { dismiss() }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button("Kaydet") {
                saveJournalEntry()
                dismiss()
            }
            .disabled(content.isEmpty)
        }
    }
    
    private func saveJournalEntry() {
        let entry = JournalEntry(
            id: UUID(),
            goalId: goal.id,
            date: Date(),
            content: content,
            mood: mood,
            attachments: attachments
        )
        
        var updatedGoal = goal
        updatedGoal.journals.append(entry)
        goalManager.updateGoal(updatedGoal)
        onSave(updatedGoal)
    }
} 
