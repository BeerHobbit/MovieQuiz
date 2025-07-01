import UIKit

final class StatisticService {
    
    // MARK: - Private Properties
    
    private let storage: UserDefaults = .standard
    
    private enum Keys: String {
        case correctAnswersTotal
        case questionsTotal
        case gamesCount
        case correct
        case total
        case date
    }
    
    private var correctAnswersTotal: Int {
        get {
            storage.integer(forKey: Keys.correctAnswersTotal.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.correctAnswersTotal.rawValue)
        }
    }
    
    private var questionsTotal: Int {
        get {
            storage.integer(forKey: Keys.questionsTotal.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.questionsTotal.rawValue)
        }
    }
    
}

extension StatisticService: StatisticServiceProtocol {
    
    //MARK: - Public Properties
    
    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }
    
    var bestGame: GameResult {
        get {
            GameResult(
                correct: storage.integer(forKey: Keys.correct.rawValue),
                total: storage.integer(forKey: Keys.total.rawValue),
                date: storage.object(forKey: Keys.date.rawValue) as? Date ?? Date()
                )
        }
        set {
            storage.set(newValue.correct, forKey: Keys.correct.rawValue)
            storage.set(newValue.total, forKey: Keys.total.rawValue)
            storage.set(newValue.date, forKey: Keys.date.rawValue)
        }
    }
    
    var totalAccuracy: Double {
        guard gamesCount != 0 else { return 0 }
        return Double(correctAnswersTotal) / Double(questionsTotal) * 100
    }
    
    //MARK: - Public Methods
    
    func store(correct count: Int, total amount: Int) {
        correctAnswersTotal += count
        questionsTotal += amount
        gamesCount += 1
        let currentGame = GameResult(
            correct: count,
            total: amount,
            date: Date()
        )
        currentGame.isBeeter(than: bestGame) ? bestGame = currentGame : ()
    }

}
