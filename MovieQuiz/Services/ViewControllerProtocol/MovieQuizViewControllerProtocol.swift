import UIKit

protocol MovieQuizViewControllerProtocol: AnyObject {
    func show(quiz step: QuizStepModel)
    func highlightImageBorder(isCorrectAnswer: Bool)
    func showLoadingIndicator(_ condition: Bool)
    func changeStateButtons(isEnabled: Bool)
    func hideImageBorder()
    func present(
        _ viewControllerToPresent: UIViewController,
        animated flag: Bool,
        completion: (() -> Void)?
    )
}

