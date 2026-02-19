import Foundation

final class ScoreStore {
    static let shared = ScoreStore()
    private init() {}

    private let totalKey = "totalPoints"

    var totalPoints: Int {
        UserDefaults.standard.integer(forKey: totalKey)
    }

    @discardableResult
    func addWin(points: Int) -> Int {
        let newValue = totalPoints + points
        UserDefaults.standard.set(newValue, forKey: totalKey)
        return newValue
    }

    func reset() {
        UserDefaults.standard.set(0, forKey: totalKey)
    }
}
