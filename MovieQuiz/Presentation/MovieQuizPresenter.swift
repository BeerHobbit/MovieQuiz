import UIKit

final class MovieQuizPresenter {
    
    let questionsAmount: Int = 10
    
    private var currentQuestionIndex: Int = 0

    func convert(model: QuizQuestion) -> QuizStepModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let questionStep = QuizStepModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    func resetQuestionIndex() {
        currentQuestionIndex = 0
    }
    
    
    
}

