import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBeeter(than another: GameResult) -> Bool {
        self.correct > another.correct
    }
}
