import Foundation
import SwiftChess

enum AppDifficulty: Int, CaseIterable {
    case easy, medium, hard

    var title: String {
        switch self {
        case .easy: return "Leicht"
        case .medium: return "Mittel"
        case .hard: return "Schwer"
        }
    }

    var aiDifficulty: AIConfiguration.Difficulty {
        switch self {
        case .easy: return .easy
        case .medium: return .medium
        case .hard: return .hard
        }
    }

    var winPoints: Int {
        switch self {
        case .easy: return 10
        case .medium: return 20
        case .hard: return 30
        }
    }
}
