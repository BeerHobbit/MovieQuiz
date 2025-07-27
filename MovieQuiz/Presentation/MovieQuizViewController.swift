import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate, AlertPresenterDelegate {
    
    // MARK: - AlertPresenterDelegate
    
    var alertModel: AlertModel?
    var viewControllerForPresenting: UIViewController? { self }
    
    // MARK: - @IB Outlets
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    // MARK: - Private Properties
    
    private var correctAnswers: Int = 0
    private var dataIsLoaded: Bool = false
    private let presenter = MovieQuizPresenter()
    private var currentQuestion: QuizQuestion?
    private var questionFactory: QuestionFactoryProtocol?
    private var alertPresenter: AlertPresenterProtocol?
    private var statisticService: StatisticServiceProtocol?
    
    // MARK: - View Life Cycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        configureDependencies()
        loadDataAndFirstQuestion()
    }
    
    // MARK: - QuestionFactoryDelegate
    
    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question else { return }
        currentQuestion = question
        let viewModel = presenter.convert(model: question)
        
        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }
    
    func didLoadDataFromServer(){
        showLoadingIndicator(false)
        questionFactory?.requestNextQuestion()
        dataIsLoaded = true
    }
    
    func didFailToLoadData(with error: Error) {
        showLoadingIndicator(false)
        showNetworkError()
        dataIsLoaded = false
    }
    
    // MARK: - Setup Methods
    
    private func setupFonts() {
        noButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        yesButton.titleLabel?.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        questionTitleLabel.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        indexLabel.font = UIFont(name: "YSDisplay-Medium", size: 20) ?? UIFont.systemFont(ofSize: 20, weight: .medium)
        questionLabel.font = UIFont(name: "YSDisplay-Bold", size: 23) ?? UIFont.systemFont(ofSize: 23, weight: .bold)
    }
    
    private func setupViews() {
        previewImage.layer.cornerRadius = 20
        noButton.layer.cornerRadius = 15
        yesButton.layer.cornerRadius = 15
        activityIndicator.hidesWhenStopped = true
    }
    
    private func configureUI() {
        setupFonts()
        setupViews()
    }
    
    private func configureDependencies() {
        let questionFactory = QuestionFactory(
            moviesLoader: MoviesLoader(),
            delegate: self
        )
        self.questionFactory = questionFactory
        
        let alertPresenter = AlertPresenter()
        alertPresenter.delegate = self
        self.alertPresenter = alertPresenter
        
        statisticService = StatisticService()
    }
    
   private func loadDataAndFirstQuestion() {
       showLoadingIndicator(true)
       questionFactory?.loadData()
   }
    
    // MARK: - Private Methods
    
    private func show(quiz step: QuizStepModel) {
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    private func showAnswerResult(isCorrect: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        correctAnswers = isCorrect ? correctAnswers + 1 : correctAnswers
        changeStateButtons(isEnabled: false)
        showLoadingIndicator(true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self else { return }
            self.showNextQuestionOrResults()
            self.previewImage.layer.borderWidth = 0
            self.changeStateButtons(isEnabled: true)
            self.showLoadingIndicator(false)
        }
    }
    
    private func showNextQuestionOrResults() {
        if presenter.isLastQuestion() {
            let alertContent = setupResultAlertContent()
            alertModel = setupAlertModel(from: alertContent)
            alertPresenter?.presentAlert()
        } else {
            presenter.switchToNextQuestion()
            questionFactory?.requestNextQuestion()
        }
    }
    
    private func setupResultAlertContent() -> AlertContentModel {
        guard let statisticService else {
            return AlertContentModel(title: "", text: "", buttonText: "")
        }
        
        statisticService.store(correct: correctAnswers, total: presenter.questionsAmount)
        let gamesCount = statisticService.gamesCount
        let correct = statisticService.bestGame.correct
        let total = statisticService.bestGame.total
        let date = statisticService.bestGame.date.dateTimeString
        let totalAccuracy = String(format: "%.2f", statisticService.totalAccuracy)
        
        let text = """
            Ваш результат \(correctAnswers)/\(presenter.questionsAmount)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(correct)/\(total) (\(date))
            Cредняя точность: \(totalAccuracy)%
            """
        
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
                self.presenter.resetQuestionIndex()
                self.correctAnswers = 0
                if self.dataIsLoaded {
                    self.questionFactory?.requestNextQuestion()
                } else {
                    self.loadDataAndFirstQuestion()
                }
            })
        return alertModel
    }
    
    private func showNetworkError() {
        let alertContent = AlertContentModel(
            title: "Что-то пошло не так(",
            text: "Невозможно загрузить данные",
            buttonText: "Попробовать еще раз"
        )
        alertModel = setupAlertModel(from: alertContent)
        alertPresenter?.presentAlert()
    }
    
    private func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    private func handleAnswer(_ userAnswer: Bool) {
        guard let currentQuestion = currentQuestion else { return }
        showAnswerResult(isCorrect: userAnswer == currentQuestion.correctAnswer)
    }
    
    private func showLoadingIndicator(_ condition: Bool) {
        condition ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    
    // MARK: - IB Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        handleAnswer(false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        handleAnswer(true)
    }
    
}
