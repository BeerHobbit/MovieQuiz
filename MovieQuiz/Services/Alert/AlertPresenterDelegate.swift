import UIKit

protocol AlertPresenterDelegate: AnyObject {
    var viewControllerForPresenting: MovieQuizViewControllerProtocol? { get }
}
