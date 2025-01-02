import SwiftUI

struct TagInputView: View {
    @Binding var tags: Set<String>
    @Binding var newTag: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Tag'leri gösteren ScrollView
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(Array(tags), id: \.self) { tag in
                        TagView(tag: tag) {
                            tags.remove(tag)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
            
            // Yeni tag ekleme alanı
            HStack {
                TextField("Yeni Etiket", text: $newTag)
                    .textFieldStyle(.roundedBorder)
                
                Button("Ekle") {
                    if !newTag.isEmpty {
                        tags.insert(newTag)
                        newTag = ""
                    }
                }
                .disabled(newTag.isEmpty)
            }
        }
    }
}

struct TagView: View {
    let tag: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(.subheadline)
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.secondary)
                    .font(.caption)
            }
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(.ultraThinMaterial)
        )
    }
}

#Preview {
    TagInputView(tags: .constant(["Önemli", "Acil", "Kişisel"]), newTag: .constant(""))
        .padding()
} 