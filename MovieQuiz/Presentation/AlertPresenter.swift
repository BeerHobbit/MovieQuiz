import UIKit

final class AlertPresenter: AlertPresenterProtocol {
    
    // MARK: - Public Properties
    
    weak var delegate: AlertPresenterDelegate?
    
    // MARK: - Public Methods
    
    func presentAlert() {
        guard
            let alertModel = delegate?.alertModel,
            let viewController = delegate?.viewControllerForPresenting
        else { return }
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert
        )
        alert.view.accessibilityIdentifier = "Game results"
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion()
        }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}

