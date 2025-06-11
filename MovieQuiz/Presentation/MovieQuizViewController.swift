import UIKit

final class MovieQuizViewController: UIViewController {
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    private var currentQuestionIndex = 0
    private var correctAnswers = 0
    private let questions: [QuizQuestion] = [
        QuizQuestion(
            image: "The Godfather",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Dark Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Kill Bill",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Avengers",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Deadpool",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "The Green Knight",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: true),
        QuizQuestion(
            image: "Old",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "The Ice Age Adventures of Buck Wild",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Tesla",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false),
        QuizQuestion(
            image: "Vivarium",
            text: "Рейтинг этого фильма больше чем 6?",
            correctAnswer: false)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23) ?? UIFont.systemFont(ofSize: 23, weight: .bold)
        let firstQuestion = questions[currentQuestionIndex]
        let viewModel = convert(model: firstQuestion)
        show(quiz: viewModel)
    }
    
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionStep = QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questions.count)"
        )
        return questionStep
    }
    private func show(quiz step: QuizStepViewModel) {
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    private func showAnswerResult(isCorrect: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        correctAnswers = isCorrect ? correctAnswers + 1 : correctAnswers
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.showNextQuestionOrResults()
        }
    }
    private func showNextQuestionOrResults() {
        if currentQuestionIndex == questions.count - 1 {
            let viewModel = QuizResultViewModel(
                title: "Этот раунд окончен",
                text: "Ваш результат \(correctAnswers)/\(questions.count)",
                buttonText: "Сыграть еще раз")
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1
            let nextQuestion = questions[currentQuestionIndex]
            let viewModel = convert(model: nextQuestion)
            show(quiz: viewModel)
            previewImage.layer.borderWidth = 0
        }
    }
    private func show(quiz result: QuizResultViewModel) {
        let alert = UIAlertController(
            title: result.title,
            message: result.text,
            preferredStyle: .alert)
        let action = UIAlertAction(title: result.buttonText, style: .default) { _ in
            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            let firstQuestion = self.questions[self.currentQuestionIndex]
            let viewModel = self.convert(model: firstQuestion)
            self.show(quiz: viewModel)
        }
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        let userAnswer = false
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        let userAnswer = true
        let currentQuestion = questions[currentQuestionIndex]
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
}

fileprivate struct QuizQuestion {
    let image: String
    let text: String
    let correctAnswer: Bool
}

fileprivate struct QuizStepViewModel {
    let image: UIImage
    let question: String
    let questionNumber: String
}

fileprivate struct QuizResultViewModel {
    let title: String
    let text: String
    let buttonText: String
}
