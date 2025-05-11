//
//  TaskDetailRouter.swift
//  ToDo
//
//  Created by Павел Попов on 07.05.2025.
//

import UIKit

protocol TaskDetailRouterProtocol: AnyObject {
    static func createModule(with task: Task) -> UIViewController
}

class TaskDetailRouter: TaskDetailRouterProtocol {
    static func createModule(with task: Task) -> UIViewController {
        let view = TaskDetailViewController()
        let presenter = TaskDetailPresenter()
        let interactor = TaskDetailInteractor()
        let router = TaskDetailRouter()
        
        view.presenter = presenter
        presenter.view = view
        presenter.interactor = interactor
        presenter.router = router
        presenter.task = task
        //interactor.presenter = presenter
        
        return view
    }
}
