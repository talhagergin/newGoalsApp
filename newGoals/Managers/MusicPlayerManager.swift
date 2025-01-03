import AVFoundation
import Combine

class MusicPlayerManager: ObservableObject {
    static let shared = MusicPlayerManager()
    private var audioPlayer: AVAudioPlayer?
    
    @Published var currentMusic: MotivationMusic?
    @Published var isPlaying = false
    @Published var currentTime: TimeInterval = 0
    @Published var duration: TimeInterval = 0
    @Published var playlist: [MotivationMusic] = []
    
    private var timer: Timer?
    
    @Published var isShuffling = false
    @Published var repeatMode: RepeatMode = .none
    @Published var volume: Float = 1.0
    
    enum RepeatMode {
        case none, one, all
        
        var icon: String {
            switch self {
            case .none: return "repeat"
            case .one: return "repeat.1"
            case .all: return "repeat.circle"
            }
        }
    }
    init() {
        loadPlaylist()
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Audio session hatası: \(error.localizedDescription)")
        }
    }
    
    func play(_ music: MotivationMusic) {
        guard let url = URL(string: music.urlString) else {
            print("Geçersiz URL: \(music.urlString)")
            return
        }
        
        do {
            // URL'i kontrol et
            guard FileManager.default.fileExists(atPath: url.path) else {
                print("Dosya bulunamadı: \(url.path)")
                return
            }
            
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            currentMusic = music
            isPlaying = true
            duration = audioPlayer?.duration ?? 0
            
            // Ses seviyesini ayarla
            audioPlayer?.volume = volume
            
            startTimer()
        } catch {
            print("Müzik çalma hatası: \(error.localizedDescription)")
        }
    }
    
    func pause() {
        audioPlayer?.pause()
        isPlaying = false
        stopTimer()
    }
    
    func resume() {
        audioPlayer?.play()
        isPlaying = true
        startTimer()
    }
    
    func stop() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentTime = 0
        stopTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self,
                  let player = self.audioPlayer else {
                self?.stopTimer()
                return
            }
            
            self.currentTime = player.currentTime
            
            if player.currentTime >= player.duration {
                self.stop()
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    func addToPlaylist(_ music: MotivationMusic) {
        playlist.append(music)
        savePlaylist()
    }
    
    func toggleFavorite(_ music: MotivationMusic) {
        if let index = playlist.firstIndex(where: { $0.id == music.id }) {
            playlist[index].isFavorite.toggle()
            savePlaylist()
        }
    }
    
    private func savePlaylist() {
        if let encoded = try? JSONEncoder().encode(playlist) {
            UserDefaults.standard.set(encoded, forKey: "SavedPlaylist")
        }
    }
    
    private func loadPlaylist() {
        if let data = UserDefaults.standard.data(forKey: "SavedPlaylist"),
           let decoded = try? JSONDecoder().decode([MotivationMusic].self, from: data) {
            playlist = decoded
        }
    }
    
    // Şarkıyı belirli bir zamana atla
    func seek(to time: TimeInterval) {
        audioPlayer?.currentTime = time
        currentTime = time
    }
    
    // Ses seviyesini ayarla
    func setVolume(_ value: Float) {
        volume = value
        audioPlayer?.volume = value
    }
    
    // Tekrar modunu değiştir
    func toggleRepeatMode() {
        switch repeatMode {
        case .none: repeatMode = .one
        case .one: repeatMode = .all
        case .all: repeatMode = .none
        }
    }
    
    // Karıştırmayı aç/kapa
    func toggleShuffle() {
        isShuffling.toggle()
    }
    
    // Sonraki şarkıya geç
    func playNext() {
        guard let currentMusic = currentMusic,
              let currentIndex = playlist.firstIndex(where: { $0.id == currentMusic.id }) else {
            return
        }
        
        var nextIndex: Int
        
        if isShuffling {
            nextIndex = Int.random(in: 0..<playlist.count)
        } else {
            nextIndex = currentIndex + 1
            if nextIndex >= playlist.count {
                nextIndex = 0
            }
        }
        
        play(playlist[nextIndex])
    }
    
    // Önceki şarkıya geç
    func playPrevious() {
        guard let currentMusic = currentMusic,
              let currentIndex = playlist.firstIndex(where: { $0.id == currentMusic.id }) else {
            return
        }
        
        var previousIndex: Int
        
        if isShuffling {
            previousIndex = Int.random(in: 0..<playlist.count)
        } else {
            previousIndex = currentIndex - 1
            if previousIndex < 0 {
                previousIndex = playlist.count - 1
            }
        }
        
        play(playlist[previousIndex])
    }
    
    // Şarkı bittiğinde ne yapılacağını kontrol et
    private func handlePlaybackFinished() {
        switch repeatMode {
        case .none:
            playNext()
        case .one:
            if let current = currentMusic {
                play(current)
            }
        case .all:
            playNext()
        }
    }
} 
