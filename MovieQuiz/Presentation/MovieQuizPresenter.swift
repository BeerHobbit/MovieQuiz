import UIKit

final class MovieQuizPresenter: AlertPresenterDelegate, QuestionFactoryDelegate {
    
    // MARK: - AlertPresenterDelegate
    
    var alertModel: AlertModel?
    var viewControllerForPresenting: MovieQuizViewControllerProtocol? { self.viewController }
    
    
    // MARK: - Private Properties
    private weak var viewController: MovieQuizViewControllerProtocol?
    
    private var questionFactory: QuestionFactoryProtocol?
    private var statisticService: StatisticServiceProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var currentQuestion: QuizQuestion?
    private var dataIsLoaded: Bool = false
    private let questionsAmount: Int = 10
    private var currentQuestionIndex: Int = 0
    private var correctAnswers: Int = 0
    
    
    // MARK: - Initializer
    
    init(viewController: MovieQuizViewControllerProtocol) {
        self.viewController = viewController
        
        statisticService = StatisticService()
        alertPresenter = AlertPresenter(delegate: self)
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        questionFactory?.loadData()
        viewController.showLoadingIndicator(true)
    }
    
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.viewController?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer() {
        viewController?.showLoadingIndicator(false)
        questionFactory?.requestNextQuestion()
        dataIsLoaded = true
    }
    
    func didFailToLoadData() {
        proceedToNetworkError()
        dataIsLoaded = false
    }
    
    
    // MARK: - Public Methods
    
    func userAnswer(isYes: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        let givenAnswer = isYes
        proceedWithAnswer(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
    
    func convert(model: QuizQuestion) -> QuizStepModel {
        let image = UIImage(data: model.image) ?? UIImage()
        let questionStep = QuizStepModel(
            image: image,
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
        return questionStep
    }
    
    
    // MARK: - Private Methods
    
    private func didAnswer(isCorrectAnswer: Bool) {
        if isCorrectAnswer {
            correctAnswers += 1
        }
    }
    
    private func switchToNextQuestion() {
        currentQuestionIndex += 1
    }
    
    private func isLastQuestion() -> Bool {
        currentQuestionIndex == questionsAmount - 1
    }
    
    private func proceedWithAnswer(isCorrect: Bool) {
        didAnswer(isCorrectAnswer: isCorrect)
        
        viewController?.highlightImageBorder(isCorrectAnswer: isCorrect)
        viewController?.changeStateButtons(isEnabled: false)
        viewController?.showLoadingIndicator(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.proceedToNextQuestionOrResults()
            
            self.viewController?.hideImageBorder()
            self.viewController?.changeStateButtons(isEnabled: true)
            self.viewController?.showLoadingIndicator(false)
        }
    }
    
    private func proceedToNextQuestionOrResults() {
        if self.isLastQuestion() {
            proceedToResults()
        } else {
            self.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func restartGame() {
        currentQuestionIndex = 0
        correctAnswers = 0
        if dataIsLoaded {
            questionFactory?.requestNextQuestion()
        } else {
            questionFactory?.loadData()
        }
    }
    
    private func makeResultMessage() -> String {
        guard let statisticService else { return "" }
        
        statisticService.store(correct: correctAnswers, total: questionsAmount)
        let gamesCount = statisticService.gamesCount
        let correct = statisticService.bestGame.correct
        let total = statisticService.bestGame.total
        let date = statisticService.bestGame.date.dateTimeString
        let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
        
        let resultMessage = """
            Ваш результат: \(correctAnswers)/\(questionsAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(correct)/\(total) (\(date))
            Cредняя точность: \(totalAccuracy)%
            """
        
        return resultMessage
    }
    
    
    //MARK: - Private Alert Methods
    
    private func setupResultAlertContent() -> AlertContentModel {
        let text = makeResultMessage()
        let alertContent = AlertContentModel(
            title: "Этот раунд окончен!",
            text: text,
            buttonText: "Сыграть еще раз")
        return alertContent
    }
    
    private func setupAlertModel(from alertContent: AlertContentModel) -> AlertModel {
        let alertModel = AlertModel(
            title: alertContent.title,
            message: alertContent.text,
            buttonText: alertContent.buttonText,
            completion: { [weak self] in
                guard let self else { return }
                self.restartGame()
            }
        )
        return alertModel
    }
    
    private func proceedToResults() {
        let alertContent = setupResultAlertContent()
        alertModel = setupAlertModel(from: alertContent)
        alertPresenter?.presentAlert()
    }
    
    private func proceedToNetworkError() {
        let alertContent = AlertContentModel(
            title: "Что-то пошло не так(",
            text: "Невозможно загрузить данные",
            buttonText: "Попробовать еще раз"
        )
        alertModel = setupAlertModel(from: alertContent)
        alertPresenter?.presentAlert()
    }
    
}
