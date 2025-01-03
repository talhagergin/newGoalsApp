import SwiftUI
import UniformTypeIdentifiers
import AVFoundation

struct AddMusicView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var musicManager = MusicPlayerManager.shared
    
    @State private var title = ""
    @State private var artist = ""
    @State private var category = MotivationMusic.MusicCategory.motivation
    @State private var showingFilePicker = false
    @State private var selectedURL: URL?
    @State private var showingError = false
    @State private var errorMessage = ""
    
    private func getDocumentsDirectory() -> URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    private func copyFileToDocuments(from sourceURL: URL) -> URL? {
        // Önce dosyaya güvenli erişim sağla
        guard sourceURL.startAccessingSecurityScopedResource() else {
            print("Dosyaya erişim sağlanamadı")
            return nil
        }
        
        defer {
            sourceURL.stopAccessingSecurityScopedResource()
        }
        
        let fileName = UUID().uuidString + "-" + sourceURL.lastPathComponent
        let destinationURL = getDocumentsDirectory().appendingPathComponent(fileName)
        
        do {
            // Eğer aynı isimde dosya varsa sil
            if FileManager.default.fileExists(atPath: destinationURL.path) {
                try FileManager.default.removeItem(at: destinationURL)
            }
            
            try FileManager.default.copyItem(at: sourceURL, to: destinationURL)
            return destinationURL
        } catch {
            print("Dosya kopyalama hatası: \(error.localizedDescription)")
            return nil
        }
    }
    
    private func saveMusic() {
        guard let sourceURL = selectedURL else { return }
        
        // Dosyayı Documents dizinine kopyala
        guard let destinationURL = copyFileToDocuments(from: sourceURL) else {
            showError("Dosya kopyalanamadı. Lütfen tekrar deneyin.")
            return
        }
        
        // Müzik süresini al
        do {
            let player = try AVAudioPlayer(contentsOf: destinationURL)
            let music = MotivationMusic(
                title: title,
                artist: artist,
                category: category,
                urlString: destinationURL.absoluteString,
                duration: player.duration
            )
            
            musicManager.addToPlaylist(music)
            dismiss()
        } catch {
            // Hata durumunda kopyalanan dosyayı temizle
            try? FileManager.default.removeItem(at: destinationURL)
            showError("Müzik dosyası okunamadı: \(error.localizedDescription)")
        }
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Müzik Bilgileri") {
                    TextField("Başlık", text: $title)
                    TextField("Sanatçı", text: $artist)
                    
                    Picker("Kategori", selection: $category) {
                        ForEach(MotivationMusic.MusicCategory.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                }
                
                Section {
                    Button(action: { showingFilePicker = true }) {
                        Label("Müzik Dosyası Seç", systemImage: "music.note")
                    }
                    
                    if let url = selectedURL {
                        Text(url.lastPathComponent)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Müzik Ekle")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("İptal") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Kaydet", action: saveMusic)
                        .disabled(title.isEmpty || artist.isEmpty || selectedURL == nil)
                }
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.audio],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        selectedURL = url
                        
                        // Dosya adını göster
                        if let filename = url.lastPathComponent.removingPercentEncoding {
                            print("Seçilen dosya: \(filename)")
                        }
                    }
                case .failure(let error):
                    showError("Dosya seçme hatası: \(error.localizedDescription)")
                }
            }
            .alert("Hata", isPresented: $showingError) {
                Button("Tamam", role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }
} 