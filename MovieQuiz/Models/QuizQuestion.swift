import Foundation

struct QuizQuestion: Hashable {
    let image: Data
    let text: String
    let correctAnswer: Bool
}
