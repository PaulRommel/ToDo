//
//  TaskListRouter.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

protocol TaskListRouterProtocol: AnyObject {
    static func createModule() -> UIViewController
    func presentTaskDetail(from view: (any TaskListViewProtocol)?, for task: Task)
    func shareText(_ text: String, from view: (any TaskListViewProtocol)?)  // Добавляем этот метод
}

final class TaskListRouter: TaskListRouterProtocol {
    
    static func createModule() -> UIViewController {
        let view = TaskListViewController()
        let presenter = TaskListPresenter()
        let interactor = TaskListInteractor()
        let router = TaskListRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        interactor.presenter = presenter
        
        let navigationController = UINavigationController(rootViewController: view)
        return navigationController
    }
    
    func presentTaskDetail(from view: (any TaskListViewProtocol)?, for task: Task) {
        let detailVC = TaskDetailRouter.createModule(with: task)
        
        guard let viewController = view as? UIViewController else {
            return
        }
        
        viewController.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func shareText(_ text: String, from view: (any TaskListViewProtocol)?) {
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let viewController = view as? UIViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = viewController.view
                popover.sourceRect = CGRect(x: viewController.view.bounds.midX,
                                            y: viewController.view.bounds.midY,
                                            width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            viewController.present(activityVC, animated: true)
        }
    }
}
