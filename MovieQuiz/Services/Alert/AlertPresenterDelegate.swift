import UIKit

protocol AlertPresenterDelegate: AnyObject {
    var alertModel: AlertModel? { get }
    var viewControllerForPresenting: UIViewController? { get }
}
