import SwiftUI
import AVFoundation

struct MusicPlayerView: View {
    @StateObject private var musicManager = MusicPlayerManager.shared
    @State private var showingAddMusic = false
    @State private var selectedCategory: MotivationMusic.MusicCategory?
    
    var filteredPlaylist: [MotivationMusic] {
        if let category = selectedCategory {
            return musicManager.playlist.filter { $0.category == category }
        }
        return musicManager.playlist
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Kategori filtreleme
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    CategoryButton(title: "Tümü", icon: "music.note.list", isSelected: selectedCategory == nil) {
                        selectedCategory = nil
                    }
                    
                    ForEach(MotivationMusic.MusicCategory.allCases, id: \.self) { category in
                        CategoryButton(
                            title: category.rawValue,
                            icon: category.icon,
                            isSelected: selectedCategory == category
                        ) {
                            selectedCategory = category
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Çalma listesi
            List {
                ForEach(filteredPlaylist) { music in
                    MusicRow(music: music)
                        .swipeActions {
                            Button(role: .destructive) {
                                // Silme işlemi
                            } label: {
                                Label("Sil", systemImage: "trash")
                            }
                        }
                }
            }
            .listStyle(.plain)
            
            // Şu an çalan müzik
            if let currentMusic = musicManager.currentMusic {
                NowPlayingView(music: currentMusic)
            }
        }
        .navigationTitle("Motivasyon Müzikleri")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: { showingAddMusic = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddMusic) {
            AddMusicView()
        }
    }
}

struct CategoryButton: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption)
            }
            .padding()
            .background(isSelected ? .blue : .clear)
            .foregroundColor(isSelected ? .white : .primary)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }
}

struct MusicRow: View {
    let music: MotivationMusic
    @StateObject private var musicManager = MusicPlayerManager.shared
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(music.title)
                    .font(.headline)
                Text(music.artist)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button(action: { musicManager.toggleFavorite(music) }) {
                Image(systemName: music.isFavorite ? "heart.fill" : "heart")
                    .foregroundColor(music.isFavorite ? .red : .gray)
            }
            
            if musicManager.currentMusic?.id == music.id && musicManager.isPlaying {
                Button(action: { musicManager.pause() }) {
                    Image(systemName: "pause.circle.fill")
                        .font(.title2)
                }
            } else {
                Button(action: { musicManager.play(music) }) {
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct NowPlayingView: View {
    let music: MotivationMusic
    @StateObject private var musicManager = MusicPlayerManager.shared
    @GestureState private var isDragging = false
    @State private var sliderValue: Double = 0
    
    // Süre formatlamak için yardımcı fonksiyon
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Müzik bilgileri
            HStack {
                VStack(alignment: .leading) {
                    Text(music.title)
                        .font(.headline)
                    Text(music.artist)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
            
            // İlerleme çubuğu ve süreler
            VStack(spacing: 4) {
                Slider(
                    value: $sliderValue,
                    in: 0...max(musicManager.duration, 0.01)
                ) { isDragging in
                    if !isDragging {
                        musicManager.seek(to: sliderValue)
                    }
                }
                .tint(music.category.color)
                
                HStack {
                    Text(formatTime(sliderValue))
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text(formatTime(musicManager.duration))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .onAppear {
                sliderValue = musicManager.currentTime
            }
            .onChange(of: musicManager.currentTime) { _, newValue in
                if !isDragging {
                    sliderValue = newValue
                }
            }
            
            // Ses kontrolü
            HStack {
                Image(systemName: "speaker.fill")
                    .foregroundColor(.secondary)
                Slider(
                    value: Binding(
                        get: { Double(musicManager.volume) },
                        set: { musicManager.setVolume(Float($0)) }
                    ),
                    in: 0...1
                )
                Image(systemName: "speaker.wave.3.fill")
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
            
            // Kontroller
            HStack {
                Button(action: { musicManager.toggleShuffle() }) {
                    Image(systemName: musicManager.isShuffling ? "shuffle.circle.fill" : "shuffle")
                        .foregroundColor(musicManager.isShuffling ? .blue : .primary)
                }
                
                Spacer()
                
                Button(action: { musicManager.playPrevious() }) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }
                
                Spacer()
                
                Button(action: {
                    if musicManager.isPlaying {
                        musicManager.pause()
                    } else {
                        musicManager.resume()
                    }
                }) {
                    Image(systemName: musicManager.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                }
                
                Spacer()
                
                Button(action: { musicManager.playNext() }) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
                
                Spacer()
                
                Button(action: { musicManager.toggleRepeatMode() }) {
                    Image(systemName: musicManager.repeatMode.icon)
                        .foregroundColor(musicManager.repeatMode != .none ? .blue : .primary)
                }
            }
            .font(.title3)
        }
        .padding()
        .background(.ultraThinMaterial)
    }
} 