import UIKit

class AlertPresenter: AlertPresenterProtocol {
    
    weak var delegate: AlertPresenterDelegate?
    
    func presentAlert() {
        guard
            let alertModel = delegate?.alertModel,
            let viewController = delegate?.viewControllerForPresenting
        else { return }
        let alert = UIAlertController(
            title: alertModel.title,
            message: alertModel.message,
            preferredStyle: .alert)
        let action = UIAlertAction(title: alertModel.buttonText, style: .default) { _ in
            alertModel.completion() }
        alert.addAction(action)
        viewController.present(alert, animated: true, completion: nil)
    }
    
}

