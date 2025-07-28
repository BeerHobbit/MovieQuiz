import UIKit

final class MovieQuizViewController: UIViewController, MovieQuizViewControllerProtocol {
    
    // MARK: - @IB Outlets
    
    @IBOutlet private weak var questionTitleLabel: UILabel!
    @IBOutlet private weak var indexLabel: UILabel!
    @IBOutlet private weak var previewImage: UIImageView!
    @IBOutlet private weak var questionLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    
    // MARK: - Private Properties
    
    private var presenter: MovieQuizPresenter?
    
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureDependencies()
        configureUI()
    }
    
    
    // MARK: - Setup Methods
    
    private func configureDependencies() {
        presenter = MovieQuizPresenter(viewController: self)
    }
    
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
    
    
    // MARK: - Public Methods
    
    func show(quiz step: QuizStepModel) {
        previewImage.image = step.image
        questionLabel.text = step.question
        indexLabel.text = step.questionNumber
    }
    
    func highlightImageBorder(isCorrectAnswer: Bool) {
        previewImage.layer.masksToBounds = true
        previewImage.layer.borderWidth = 8
        previewImage.layer.borderColor = isCorrectAnswer ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
    }
    
    func hideImageBorder() {
        previewImage.layer.borderWidth = 0
    }
    
    func changeStateButtons(isEnabled: Bool) {
        yesButton.isEnabled = isEnabled
        noButton.isEnabled = isEnabled
    }
    
    func showLoadingIndicator(_ condition: Bool) {
        condition ? activityIndicator.startAnimating() : activityIndicator.stopAnimating()
    }
    
    
    // MARK: - IB Actions
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        presenter?.userAnswer(isYes: false)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        presenter?.userAnswer(isYes: true)
    }
    
}
