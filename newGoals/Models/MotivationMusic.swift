import Foundation
import AVFoundation
import SwiftUI

struct MotivationMusic: Identifiable, Codable {
    var id = UUID()
    var title: String
    var artist: String
    var category: MusicCategory
    var urlString: String
    var duration: TimeInterval
    var isFavorite: Bool = false
    
    enum MusicCategory: String, Codable, CaseIterable {
        case workout = "Spor"
        case focus = "Odaklanma"
        case meditation = "Meditasyon"
        case motivation = "Motivasyon"
        
        var icon: String {
            switch self {
            case .workout: return "figure.run"
            case .focus: return "brain.head.profile"
            case .meditation: return "leaf"
            case .motivation: return "bolt.heart"
            }
        }
        
        var color: Color {
            switch self {
            case .workout: return .red
            case .focus: return .blue
            case .meditation: return .green
            case .motivation: return .orange
            }
        }
    }
} 