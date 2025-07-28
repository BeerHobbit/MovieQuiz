import XCTest
@testable import MovieQuiz

final class MovieQuizViewControllerMock: MovieQuizViewControllerProtocol {
    
    func changeStateButtons(isEnabled: Bool) {}
    
    func hideImageBorder() {}
    
    func present(_ viewControllerToPresent: UIViewController, animated flag: Bool, completion: (() -> Void)?) {}
    
    func show(quiz step: MovieQuiz.QuizStepModel) {}
    
    func highlightImageBorder(isCorrectAnswer: Bool) {}
    
    func showLoadingIndicator(_ condition: Bool) {}
    
}
